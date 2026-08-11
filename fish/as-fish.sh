#!/usr/bin/env bash
#
# as-fish.sh
# Install the fish shell, optionally setting it as the default login shell.
#
# Can be run standalone or via the global auto-setup.sh.
#   https://fishshell.com/docs/current/index.html

set -uo pipefail

# Load shared helpers (distro selection/persistence, package installation).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# maybe_set_default_shell
# Offer to make fish the current user's default login shell.
maybe_set_default_shell() {
  local fish_bin answer
  fish_bin="$(command -v fish)"

  if [[ "${SHELL:-}" == "$fish_bin" ]]; then
    echo "fish is already your default shell"
    return 0
  fi

  read -r -p "Set fish as your default shell? [y/N]: " answer
  case "$answer" in
    [yY] | [yY][eE][sS])
      # Ensure fish is a valid login shell before switching.
      if ! grep -qxF "$fish_bin" /etc/shells; then
        echo "$fish_bin" | sudo tee -a /etc/shells >/dev/null
      fi
      chsh -s "$fish_bin"
      echo "default shell set to fish (log out and back in to take effect)"
      ;;
    *)
      echo "leaving default shell unchanged"
      ;;
  esac
}

# install_config
# Copy the bundled fish configuration (files and folders) into the user's
# ~/.config/fish. Any existing config is backed up first.
install_config() {
  local src_dir="$SCRIPT_DIR/config"
  local dest_dir="${XDG_CONFIG_HOME:-$HOME/.config}/fish"

  if [[ ! -d "$src_dir" ]]; then
    echo "warning: no bundled config found at $src_dir, skipping config copy"
    return 0
  fi

  if [[ -d "$dest_dir" ]]; then
    local backup="${dest_dir}.bak.$(date +%Y%m%d%H%M%S)"
    echo "backing up existing config to $backup"
    mv "$dest_dir" "$backup"
  fi

  echo "copying fish config into $dest_dir"
  mkdir -p "$dest_dir"
  cp -a "$src_dir/." "$dest_dir/"
}

main() {
  echo "fish setup"

  if command -v fish >/dev/null 2>&1; then
    echo "fish is already installed, skipping install"
  else
    # fish is in the official repos on both Arch and Debian/Ubuntu.
    as_pkg_install fish
  fi

  install_config
  maybe_set_default_shell
  echo "fish setup complete"
}

main "$@"
