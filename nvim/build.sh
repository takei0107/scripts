#!/bin/bash

set -e
set -u

# use tmp directory
tmp_dir=/tmp/nvim-build/$(date "+%Y%m%d%H%M%S")
echo "tmp directory: $tmp_dir"
mkdir -p "$tmp_dir"

# git clone
git clone --branch master --single-branch --depth 1 https://github.com/neovim/neovim.git "$tmp_dir"
cd "$tmp_dir"

# build
make distclean
make deps
make CMAKE_BUILD_TYPE=RelWithDebInfo
make install

# print info
echo ""
type nvim
echo ""
nvim --version
