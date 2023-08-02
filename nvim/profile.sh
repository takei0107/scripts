#!/bin/bash

set -e
set -u

VIM=${1:-nvim}

if ! [[ "$VIM" = "vim" || "$VIM" = "nvim" ]]; then
  echo "arg is 'vim' or 'nvim'"
  exit 1
fi

#check vim path
vim_path=$(which "$VIM")
if [[ $? -ne 0 ]]; then
  echo "missing vim path: $VIM"
  exit 1
fi

# check GOPATH
go_path=$(go env GOPATH)
if [[ -z $go_path ]]; then
  echo "missing go env: GOPATH"
  echo "check go env or install go"
  exit 1
fi
cmd="$go_path"/bin/vim-startuptime

# install vim-startuptime
if ! type "$cmd" > /dev/null 2>&1; then
  echo "missing cmd: vim-startuptime"

  package="github.com/rhysd/vim-startuptime@latest"
  echo "install: $package"

  go install "$package"

  ls -l "$cmd"
  echo ""
fi

# profile
echo "profile start"
echo ""
echo "profiler: $cmd"
echo "vimpath : $vim_path"
echo ""
"$cmd" --vimpath "$vim_path" --count 100
echo ""
echo "profile end"
