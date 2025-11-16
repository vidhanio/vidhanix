# shellcheck shell=bash

curl -L -o download.zip "${url:?}"

unzip download.zip
mv "${filename:?}" "${out:?}"
