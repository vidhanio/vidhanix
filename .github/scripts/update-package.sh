#!/usr/bin/env bash
set -euo pipefail

package="${1:?Usage: $0 PACKAGE}"
result_file="$(mktemp)"
trap 'rm -f "$result_file"' EXIT

set +e
nix run .#update-packages -- --json "$package" >"$result_file"
status=$?
set -e

cat "$result_file"
[ "$status" -eq 0 ] || exit "$status"

jq -e --arg package "$package" '
  length == 1
  and .[0].package == $package
  and .[0].failed == false
  and ((.[0].before | type) == "string")
  and ((.[0].after | type) == "string")
  and ((.[0].homepage | type) == "string")
  and .[0].before != ""
  and .[0].after != ""
' "$result_file" >/dev/null

before="$(jq -r '.[0].before' "$result_file")"
after="$(jq -r '.[0].after' "$result_file")"
homepage="$(jq -r '.[0].homepage' "$result_file")"

if [ -n "$homepage" ]; then
  package_link="[$package]($homepage)"
else
  package_link="$package"
fi

{
  printf 'before=%s\n' "$before"
  printf 'after=%s\n' "$after"
  printf 'body=%s\n' "Bumps $package_link from $before to $after"
} >>"$GITHUB_OUTPUT"
