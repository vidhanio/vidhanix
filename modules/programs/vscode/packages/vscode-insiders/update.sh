#! /usr/bin/env nix
#! nix shell nixpkgs#bash nixpkgs#jq nixpkgs#nix nixpkgs#gnused --command bash
# shellcheck shell=bash

set -euo pipefail

file="modules/programs/vscode/packages/vscode-insiders/default.nix"
contents=$(<"$file")

systems=$(nix eval --json .#vscode-insiders.meta.platforms | jq -r '.[]')

version=""
commit=""
timestamp=""

for system in $systems; do
	case $system in
	x86_64-linux) os="linux-x64" ;;
	aarch64-linux) os="linux-arm64" ;;
	esac

	json=$(curl -s "https://update.code.visualstudio.com/api/update/$os/insider/latest")

	os_version=$(echo "$json" | jq -r '.name')
	os_commit=$(echo "$json" | jq -r '.version')
	os_timestamp=$(echo "$json" | jq -r '.timestamp')

	if [ -n "$version" ] && [ "$version" != "$os_version" ]; then
		echo "version mismatch for $os: $os_version != $version"
		exit 1
	fi
	version=$os_version

	if [ -n "$commit" ] && [ "$commit" != "$os_commit" ]; then
		echo "commit mismatch for $os: $os_commit != $commit"
		exit 1
	fi
	commit=$os_commit

	if [ -n "$timestamp" ] && [ "$timestamp" != "$os_timestamp" ]; then
		echo "timestamp mismatch for $os: $os_timestamp != $timestamp"
		exit 1
	fi
	timestamp=$os_timestamp

	old_hash=$(nix eval --raw .#packages."$system".vscode-insiders.src.outputHash)
	raw_hash=$(echo "$json" | jq -r '.sha256hash')
	hash=$(nix hash convert --hash-algo sha256 "$raw_hash")

	contents=${contents//"$old_hash"/"$hash"}
done

old_commit=$(nix eval --raw .#vscode-insiders.commit)
contents=${contents//"$old_commit"/"$commit"}

old_full_version=$(nix eval --raw .#vscode-insiders.version)
full_version="$version-$(date -u -d "@$((timestamp / 1000))" +%F)"
contents=${contents//"$old_full_version"/"$full_version"}

echo "$contents" >"$file"
