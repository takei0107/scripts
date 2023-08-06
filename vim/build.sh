#!/bin/bash

set -e
set -u

echo "vim build start"

dir=""
fetch_cmd=""

if type ghq > /dev/null 2>&1; then
  # use ghq directory
  echo ""
  echo "use ghq repositories directory"
  dir=$(ghq list -p "github.com/vim/vim")
  fetch_cmd="git pull origin master"
else
  echo ""
  echo "use tmp directory"
  # use tmp directory
  dir=/tmp/vim-build/$(date "+%Y%m%d%H%M%S")
  echo "tmp directory: $dir"
  mkdir -p "$dir"
  fetch_cmd="git clone --branch master --single-branch --depth 1 https://github.com/vim/vim.git ."
fi

if [[ -z $dir || -z $fetch_cmd ]]; then
  echo "missing directory or fetch command: \$dir=$dir \$fetch_cmd=$fetch_cmd"
  exit 1
fi

cd "$dir"
$fetch_cmd

# build & install
cd ./src
make distclean
./configure --with-features=huge --enable-python3interp=yes --enable-luainterp=yes --enable-fail-if-missing --with-luajit
make
sudo make install

# version
echo ""
echo "install success!!"
echo ""
type vim
vim --version

