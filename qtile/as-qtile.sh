#!/usr/bin/env bash
#
# as-qtile.sh
# Install qtile, a full-featured, hackable tiling window manager written in
# Python. Also registers an X session so it can be selected at login.
#
# Can be run standalone or via the global auto-setup.sh.
#   https://docs.qtile.org/en/stable/

set -uo pipefail

# Load shared helpers (distro selection/persistence, package installation).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

QTILE_BIN=""

install_arch() {
  # qtile is in the official repos on Arch.
  as_pkg_install qtile python-psutil
  QTILE_BIN="$(command -v qtile)"
}

install_debian() {
  # The Debian/Ubuntu apt package lags behind, so install via pip per the
  # official docs. build-essential + python headers are needed for the
  # cffi-based dependencies.
  as_pkg_install python3-pip python3-venv build-essential \
    libpangocairo-1.0-0 python3-cffi python3-xcffib libxkbcommon-dev

  echo "installing qtile via pip"
  python3 -m pip install --user --upgrade xcffib
  python3 -m pip install --user --upgrade qtile

  QTILE_BIN="$HOME/.local/bin/qtile"
}

# install_xsession
# Register qtile as a selectable X session in the display manager.
install_xsession() {
  local session_file="/usr/share/xsessions/qtile.desktop"

  if [[ -z "$QTILE_BIN" ]]; then
    QTILE_BIN="$(command -v qtile || echo "$HOME/.local/bin/qtile")"
  fi

  echo "registering qtile X session at $session_file"
  sudo tee "$session_file" >/dev/null <<EOF
[Desktop Entry]
Name=Qtile
Comment=Qtile Session
Exec=$QTILE_BIN start
Type=Application
Keywords=wm;tiling
EOF
}

# install_config
# Copy the bundled qtile configuration (files and folders) into the user's
# ~/.config/qtile. Any existing config is backed up first.
install_config() {
  local src_dir="$SCRIPT_DIR/config"
  local dest_dir="${XDG_CONFIG_HOME:-$HOME/.config}/qtile"

  if [[ ! -d "$src_dir" ]]; then
    echo "warning: no bundled config found at $src_dir, skipping config copy"
    return 0
  fi

  if [[ -d "$dest_dir" ]]; then
    local backup="${dest_dir}.bak.$(date +%Y%m%d%H%M%S)"
    echo "backing up existing config to $backup"
    mv "$dest_dir" "$backup"
  fi

  echo "copying qtile config into $dest_dir"
  mkdir -p "$dest_dir"
  cp -a "$src_dir/." "$dest_dir/"
}

main() {
  echo "qtile setup"

  if command -v qtile >/dev/null 2>&1 || [[ -x "$HOME/.local/bin/qtile" ]]; then
    echo "qtile is already installed, skipping install"
  else
    as_load_distro
    case "$AS_DISTRO" in
      arch) install_arch ;;
      debian) install_debian ;;
      *)
        echo "error: unsupported distro '$AS_DISTRO'" >&2
        return 1
        ;;
    esac
  fi

  install_xsession
  install_config
  echo "qtile setup complete"
}

main "$@"
