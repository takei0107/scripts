#!/bin/bash

set -e
set -u

TMP_DIR=/tmp/wezterm-install/$(date "+%Y%m%d%H%M%S")

echo "*** start instaling wezterm"

if ! type gh > /dev/null 2>&1; then
  echo "missing command:gh"
  exit 1
fi

release_url=$(gh release view -R wez/wezterm --json assets --jq '[.assets|.[]|.url|match(".*\\.AppImage$")]|.[0]|.string')

if [[ -z $release_url ]]; then
  echo "wezterm release url does not found."
  exit 1
fi

echo "wezterm release url:$release_url"

mkdir -p "$TMP_DIR"
cd "$TMP_DIR"

curl -L -O "$release_url"

bin=./$(basename "$release_url")
chmod +x "$bin"

if [[ ! -x $bin ]]; then
  echo "missing wezterm exec file:$bin"
fi

sudo mv "$bin" /usr/local/bin/wezterm

echo ""
/usr/local/bin/wezterm --version
echo ""

echo "*** end instaling wezterm"
