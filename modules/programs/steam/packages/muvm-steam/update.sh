#!/usr/bin/env bash
set -euo pipefail

attribute="${UPDATE_NIX_ATTR_PATH:-muvm-steam}"

client_version=$(
  curl --fail --silent --show-error https://client-update.steamstatic.com/steam_client_publicbeta_linuxarm64 |
    awk -F '"' '$2 == "file" && $4 ~ /^bins_linuxarm64_linuxarm64[.]zip[.][[:xdigit:]]{40}$/ { sub(/^.*[.]/, "", $4); print $4 }'
)
runtime_version=$(curl --fail --silent --show-error https://repo.steampowered.com/steamrt3c/images/latest-public-beta/VERSION.txt)
test -n "$client_version"
test -n "$runtime_version"

nix-update --flake --version="$client_version" "$attribute.armClient"
nix-update --flake --version="$runtime_version" --subpackage installer "$attribute.armRuntime"
