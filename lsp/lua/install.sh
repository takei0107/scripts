#!/bin/bash

set -e
set -u

# ls info
LS_NAME=lua-language-server
LS_SERVERS_DIR=$HOME/.local/share/language-servers
INSTALL_DIR=$LS_SERVERS_DIR/$LS_NAME

# git info
GIT_REPO=LuaLS/lua-language-server

# ls version info
latest_version=""
version_dir=""

# work directory
tmp_dir=""

# gzip output path
output_path=""

# runner script path
runner_script_path=""

exit_with_error() {
  echo "ERROR finish!"
  exit $1
}

check_dir() {
  if [[ ! -d $1 ]]; then
    echo "missing directory: $1"
    return 1
  fi
  return 0
}

make_dir() {
  echo "make directory: $1"
  mkdir -p "$1"
}

fetch_latest_version() {
  latest_version=$(gh release list --repo $GIT_REPO | grep -E "^.*\s+Latest\s+.*$" | cut -f1)
  if [[ $? -ne 0 ]]; then
    echo "fetch latest version from $GIT_REPO failed"
    return $?
  fi
  if [[ -z $latest_version ]]; then
    echo "missing latest release for $GIT_REPO"
    return 1
  fi
  version_dir=$INSTALL_DIR/$latest_version
  return 0
}

check_existance_ls() {
  if ! check_dir "$version_dir"; then
    return 0
  fi
  bin=$version_dir/bin/lua-language-server
  if [[ -f $bin ]]; then
    echo "binary: $bin aleadey exists"
    return 1
  fi
  return 0
}

make_tmp_dir() {
  tmp_dir="/tmp/ls-install/$(date '+%Y%m%d%H%M%S')"
  if ! check_dir "$tmp_dir"; then
    make_dir "$tmp_dir" 
  fi
}

download_ls() {
  if ! check_dir "$tmp_dir"; then
    echo "missing directory: $tmp_dir"
    return 1
  fi

  local gzip_file
  local arch="$(uname)"
  case $arch in
    Linux)
      gzip_file="lua-language-server-${latest_version}-linux-x64.tar.gz" ;;
    Darwin)
      gzip_file="lua-language-server-${latest_version}-darwin-arm64.tar.gz" ;;
  esac
  if [[ -z $gzip_file ]]; then
    echo "'uname' returned unexpected value: $arch"
    return 1
  fi
  local dl_url="https://github.com/${GIT_REPO}/releases/download/${latest_version}/${gzip_file}"

  output_path="$tmp_dir/$gzip_file"

  echo "download URL: $dl_url"
  echo "output PATH:  $output_path"

  curl -fL "$dl_url" > "$output_path"
  if [[ $? -ne 0 ]]; then
    echo "curl failed"
    return 1
  fi

  echo "download success"
  echo ""
  ls -l "$output_path"
}

extract_gzip() {
  if ! check_dir "$version_dir"; then
    echo "missing directory: $version_dir"
    return 1
  fi

  echo "extract gzip"
  echo "  from: $output_path"
  echo "  to:   $version_dir"

  tar xf "$output_path" -C "$version_dir"
  if [[ $? -ne 0 ]]; then
    echo "tar failed" return 1
  fi

  echo "extract success"
  echo ""
  ls -l "$version_dir/"
}

create_runner_script() {
  bin="$version_dir"/bin/lua-language-server
  if [[ ! -f $bin ]]; then
    echo "missing binary: $bin"
    return 1
  fi

  runner_script_path="$INSTALL_DIR"/runner.sh
  cat > "$runner_script_path" <<EOF
#!/bin/bash
exec "$bin" "\$@"
EOF

  chmod +x "$runner_script_path"

  echo "runner script created"
  ls -l "$runner_script_path"
}

make_link() {
  local bin_path=$HOME/.local/bin

  #TODO PATHにあるかもチェックする
  if ! check_dir "$bin_path"; then
    echo "require $bin_path in PATH"
    return 1
  fi

  local link="$bin_path"/lua-language-server

  ln -fs "$runner_script_path" "$link"
  if [[ $? -ne 0 ]]; then
    echo "ln failed"
    return 1
  fi

  ls -l "$link"
}

main() {
  # fetch latest release of lua_ls
  if ! fetch_latest_version; then
    exit_with_error $?
  fi
  echo "install version: $latest_version"

  # check existance of ls
  if ! check_existance_ls; then
    echo "please remove or clean directory: $version_dir"
    exit_with_error 1
  fi

  make_tmp_dir

  # exec download
  if ! download_ls; then
    echo "download failed"
    exit_with_error 1
  fi

  # check directory
  if ! check_dir "$version_dir"; then
    make_dir "$version_dir"
  fi
  if ! check_dir "$INSTALL_DIR"; then
    make_dir "$INSTALL_DIR"
  fi

  # extract gzip
  if ! extract_gzip; then
    echo "extract gzip failed"
    exit_with_error 1
  fi

  # create runner script
  if ! create_runner_script; then
    echo "creating runner script failed"
    exit_with_error 1
  fi

  if ! make_link; then
    echo "make symlink failed"
    exit_with_error 1
  fi
}

main
