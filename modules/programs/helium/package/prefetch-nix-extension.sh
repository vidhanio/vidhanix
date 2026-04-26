#!/usr/bin/env bash

# Check if at least one ID was provided
if [ $# -eq 0 ]; then
  echo "Usage: fetchext <ID> [<ID> ...]"
  echo "Example: fetchext nngceckbapebfimnlniiiahkandclblb"
  exit 1
fi

UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"

# Print opening for easy copy-pasting
echo "extensions = ["

for id in "$@"; do
  # Fetch CRX to calculate the hash
  url="https://clients2.google.com/service/update2/crx?response=redirect&os=linux&arch=x64&os_arch=x86_64&nacl_arch=x86-64&prod=chromiumcrx&prodchannel=stable&prodversion=120.0.0.0&acceptformat=crx3&x=id%3D${id}%26installsource%3Dondemand%26uc"

  tmpfile=$(mktemp)

  # -L follows the redirect from Google's service to the actual .crx file
  if curl -fsSL -A "$UA" "$url" -o "$tmpfile"; then
    size=$(stat -c%s "$tmpfile")

    if [ "$size" -gt 1000 ]; then
      # Generate the SRI hash
      hash=$(nix-hash --type sha256 --flat --base32 "$tmpfile")
      sri=$(nix hash convert --to sri --hash-algo sha256 "$hash")

      # Output the Nix code block
      echo "  { id = \"$id\"; hash = \"$sri\"; }"
    else
      echo "  # FAILED: ID $id returned an empty or invalid file (check ID)."
    fi
  else
    echo "  # FAILED: Could not reach Google Update servers for ID $id."
  fi

  rm -f "$tmpfile"
  # Brief sleep to avoid rate limiting if fetching many at once
  sleep 0.5
done

echo "];"
