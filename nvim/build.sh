#!/bin/bash

set -e
set -u

echo "neovim build start"

dir=""
fetch_cmd=""

if type ghq > /dev/null 2>&1; then
  # use ghq directory
  echo ""
  echo "use ghq repositories directory"
  dir=$(ghq list -p "github.com/neovim/neovim")

  # ghqリポジトリにない時はghq getする
  if [[ -z $dir ]]; then
    echo "missing neovim repository at ghq. cloning"
    ghq get "https://github.com/neovim/neovim.git"
    dir=$(ghq list -p "github.com/neovim/neovim")
  fi
  fetch_cmd="git pull origin master"
else
  echo ""
  echo "use tmp directory"
  # use tmp directory
  dir=/tmp/nvim-build/$(date "+%Y%m%d%H%M%S")
  echo "tmp directory: $dir"
  mkdir -p "$dir"
  fetch_cmd="git clone --branch master --single-branch --depth 1 https://github.com/neovim/neovim.git ."
fi

if [[ -z $dir || -z $fetch_cmd ]]; then
  echo "missing directory:$dir or fetch command:$fetch_cmd"
  exit 1
fi

cd "$dir"
pwd
$fetch_cmd

# build & install
sudo make distclean
make deps
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install

# remove auto installed parsers
echo ""
parser_dir=/usr/local/lib/nvim/parser
echo "remove treesitter parsers: ${parser_dir}/*.so"
if [[ -d $parser_dir ]]; then
  sudo rm -f "$parser_dir"/*.so
fi
echo "removed."

# version
echo ""
echo "install success!!"
echo ""
type nvim
echo ""
nvim --version
