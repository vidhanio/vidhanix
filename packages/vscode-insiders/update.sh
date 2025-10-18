#! /usr/bin/env nix
#! nix shell nixpkgs#bash nixpkgs#jq nixpkgs#nix nixpkgs#gnused --command bash
# shellcheck shell=bash

set -euo pipefail

file="packages/vscode-insiders/package.nix"
contents=$(<"$file")

systems=$(nix eval --json .#vscode-insiders.meta.platforms | jq -r '.[]')

commit=""

for system in $systems; do
	case $system in
	x86_64-linux) os="linux-x64" ;;
	aarch64-linux) os="linux-arm64" ;;
	esac

	json=$(curl -s "https://update.code.visualstudio.com/api/update/$os/insider/latest")

	os_commit=$(echo "$json" | jq -r '.version')

	if [ -z "$commit" ]; then
		commit=$os_commit
	elif [ "$commit" != "$os_commit" ]; then
		echo "commit mismatch for $os: $os_commit != $commit"
		exit 1
	fi

	old_hash=$(nix eval --raw .#packages."$system".vscode-insiders.src.outputHash)
	raw_hash=$(echo "$json" | jq -r '.sha256hash')
	hash=$(nix hash convert --hash-algo sha256 "$raw_hash")

	contents=${contents//"$old_hash"/"$hash"}
done

old_commit=$(nix eval --raw .#vscode-insiders.commit)
contents=${contents//"$old_commit"/"$commit"}
echo "$contents" >"$file"
