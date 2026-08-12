#!/usr/bin/env bash
#
# as-asdf.sh
# Install asdf (v0.16+, the Go binary) version manager and wire it into the
# bash and fish shells.
#
# Can be run standalone or via the global auto-setup.sh.
#   https://asdf-vm.com/guide/getting-started.html

set -uo pipefail

# Load shared helpers (distro selection/persistence, package installation).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

ASDF_DATA_DIR="${ASDF_DATA_DIR:-$HOME/.asdf}"

# install_dependencies
# asdf needs git at runtime to fetch plugins.
install_dependencies() {
  case "$AS_DISTRO" in
    arch) as_pkg_install git ;;
    debian) as_pkg_install git ;;
    *)
      echo "error: unsupported distro '$AS_DISTRO'" >&2
      return 1
      ;;
  esac
}

# install_asdf_binary
# Download the latest asdf release binary and place it on the PATH.
install_asdf_binary() {
  local arch asdf_arch tmp url

  arch="$(uname -m)"
  case "$arch" in
    x86_64) asdf_arch="amd64" ;;
    aarch64 | arm64) asdf_arch="arm64" ;;
    *)
      echo "error: unsupported architecture '$arch'" >&2
      return 1
      ;;
  esac

  # Find the latest linux tarball for this architecture.
  url="$(curl -fsSL https://api.github.com/repos/asdf-vm/asdf/releases/latest \
    | grep -o "https://[^\"]*-linux-${asdf_arch}\.tar\.gz" \
    | head -n1)"

  if [[ -z "$url" ]]; then
    echo "error: could not find an asdf release for arch '$asdf_arch'" >&2
    return 1
  fi

  tmp="$(mktemp -d)"
  echo "downloading asdf from $url"
  curl -fsSL -o "$tmp/asdf.tar.gz" "$url"
  tar -xzf "$tmp/asdf.tar.gz" -C "$tmp"
  sudo install -m 0755 "$tmp/asdf" /usr/local/bin/asdf
  rm -rf "$tmp"
}

# add_line_if_missing <file> <line>
# Append a line to a config file only if it isn't already present.
add_line_if_missing() {
  local file="$1" line="$2"
  mkdir -p "$(dirname "$file")"
  touch "$file"
  if ! grep -qxF "$line" "$file"; then
    printf '\n%s\n' "$line" >> "$file"
    echo "updated $file"
  fi
}

configure_shells() {
  local config_home="${XDG_CONFIG_HOME:-$HOME/.config}"

  # bash: add the shims dir to PATH and enable completions.
  add_line_if_missing "$HOME/.bashrc" \
    'export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"'
  add_line_if_missing "$HOME/.bashrc" '. <(asdf completion bash)'

  # fish: add the shims dir to PATH and generate completions.
  add_line_if_missing "$config_home/fish/config.fish" \
    'set -gx PATH $HOME/.asdf/shims $PATH'
  if command -v asdf >/dev/null 2>&1; then
    mkdir -p "$config_home/fish/completions"
    asdf completion fish > "$config_home/fish/completions/asdf.fish"
  fi
}

main() {
  echo "asdf setup"

  if command -v asdf >/dev/null 2>&1; then
    echo "asdf is already installed, skipping install"
  else
    as_load_distro
    install_dependencies
    install_asdf_binary
  fi

  mkdir -p "$ASDF_DATA_DIR"
  configure_shells

  echo "asdf setup complete"
  echo "restart your shell, then add plugins with: asdf plugin add <name>"
}

main "$@"
