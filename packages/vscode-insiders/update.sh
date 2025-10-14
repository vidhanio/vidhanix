#! /usr/bin/env nix
#! nix shell nixpkgs#bash nixpkgs#jq nixpkgs#nix nixpkgs#gnused --command bash
# shellcheck shell=bash

set -euo pipefail

file="packages/vscode-insiders/package.nix"
contents=$(<"$file")

hashes_json=$(
	curl -s 'https://code.visualstudio.com/sha?build=insider' |
		jq '
			.products |
				map({
					(.platform.os): {
						hash: .sha256hash,
						version: .version,
					},
				}) |
				add
		'
)

systems=$(nix eval --json .#vscode-insiders.meta.platforms | jq -r '.[]')

version=""

for system in $systems; do
	case $system in
	x86_64-linux) os="linux-x64" ;;
	aarch64-linux) os="linux-arm64" ;;
	aarch64-darwin) os="darwin-arm64" ;;
	esac

	os_version=$(echo "$hashes_json" | jq -r --arg os "$os" '.[$os].version')

	if [ -z "$version" ]; then
		version=$os_version
	elif [ "$version" != "$os_version" ]; then
		echo "version mismatch for $os: $os_version != $version"
		exit 1
	fi

	old_hash=$(nix eval --raw .#packages."$system".vscode-insiders.src.outputHash)
	raw_hash=$(echo "$hashes_json" | jq -r --arg os "$os" '.[$os].hash')
	hash=$(nix hash convert --hash-algo sha256 "$raw_hash")

	contents=${contents//"$old_hash"/"$hash"}
done

old_version=$(nix eval --raw .#vscode-insiders.version)
contents=${contents//"$old_version"/"$version"}
echo "$contents" >"$file"
