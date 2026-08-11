#!/usr/bin/env bash
#
# as-alacritty.sh
# Install Alacritty, a fast, GPU-accelerated terminal emulator.
#
# Can be run standalone or via the global auto-setup.sh.
#   https://github.com/alacritty/alacritty

set -uo pipefail

# Load shared helpers (distro selection/persistence, package installation).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# install_config
# Copy the bundled alacritty configuration into the user's ~/.config/alacritty.
# Any existing config is backed up first.
install_config() {
  local src_dir="$SCRIPT_DIR/config"
  local dest_dir="${XDG_CONFIG_HOME:-$HOME/.config}/alacritty"

  if [[ ! -d "$src_dir" ]]; then
    echo "warning: no bundled config found at $src_dir, skipping config copy"
    return 0
  fi

  if [[ -d "$dest_dir" ]]; then
    local backup="${dest_dir}.bak.$(date +%Y%m%d%H%M%S)"
    echo "backing up existing config to $backup"
    mv "$dest_dir" "$backup"
  fi

  echo "copying alacritty config into $dest_dir"
  mkdir -p "$dest_dir"
  cp -a "$src_dir/." "$dest_dir/"
}

main() {
  echo "alacritty setup"

  if command -v alacritty >/dev/null 2>&1; then
    echo "alacritty is already installed, skipping install"
  else
    # alacritty is in the official repos on both Arch and Debian/Ubuntu.
    as_pkg_install alacritty
  fi

  install_config
  echo "alacritty setup complete"
}

main "$@"
