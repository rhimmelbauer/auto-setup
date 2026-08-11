#!/usr/bin/env bash
#
# as-starship.sh
# Install Starship, the minimal, fast, cross-shell prompt, and wire it into
# the bash and fish shells.
#
# Can be run standalone or via the global auto-setup.sh.
#   https://starship.rs/

set -uo pipefail

# Load shared helpers (distro selection/persistence, package installation).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

install_starship() {
  # Arch ships starship in the official repos; elsewhere use the official
  # cross-distro install script.
  if [[ "$AS_DISTRO" == "arch" ]]; then
    as_pkg_install starship
    return
  fi

  echo "installing starship via the official install script"
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
}

# add_line_if_missing <file> <line>
# Append a line to a config file only if it isn't already present.
add_line_if_missing() {
  local file="$1" line="$2"
  mkdir -p "$(dirname "$file")"
  touch "$file"
  if ! grep -qxF "$line" "$file"; then
    printf '\n%s\n' "$line" >> "$file"
    echo "added starship init to $file"
  fi
}

configure_shells() {
  local config_home="${XDG_CONFIG_HOME:-$HOME/.config}"

  # bash
  add_line_if_missing "$HOME/.bashrc" 'eval "$(starship init bash)"'

  # fish
  add_line_if_missing "$config_home/fish/config.fish" 'starship init fish | source'
}

# install_config
# Copy the bundled starship.toml into the user's ~/.config. Any existing
# config is backed up first.
install_config() {
  local src_file="$SCRIPT_DIR/config/starship.toml"
  local dest_file="${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"

  if [[ ! -f "$src_file" ]]; then
    echo "warning: no bundled config found at $src_file, skipping config copy"
    return 0
  fi

  if [[ -f "$dest_file" ]]; then
    local backup="${dest_file}.bak.$(date +%Y%m%d%H%M%S)"
    echo "backing up existing config to $backup"
    mv "$dest_file" "$backup"
  fi

  echo "copying starship config into $dest_file"
  mkdir -p "$(dirname "$dest_file")"
  cp -a "$src_file" "$dest_file"
}

main() {
  echo "starship setup"

  if command -v starship >/dev/null 2>&1; then
    echo "starship is already installed, skipping install"
  else
    as_load_distro
    install_starship
  fi

  install_config
  configure_shells
  echo "starship setup complete"
}

main "$@"
