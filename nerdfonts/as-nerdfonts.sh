#!/usr/bin/env bash
#
# as-nerdfonts.sh
# Install a choice of Nerd Fonts by downloading the font archive directly from
# the Nerd Fonts GitHub releases and refreshing the font cache.
#
# Can be run standalone or via the global auto-setup.sh.
#   https://github.com/ryanoasis/nerd-fonts

set -uo pipefail

# Load shared helpers (distro selection/persistence, package installation).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# Fonts offered in the menu. Each entry is the release asset name (without the
# .zip extension), which matches the Nerd Fonts patched-font family name.
NERDFONTS=(
  FiraCode
  Hack
  JetBrainsMono
  Meslo
  SourceCodePro
  UbuntuMono
  RobotoMono
  CascadiaCode
)

FONT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"

# ensure_tools
# Make sure the utilities we need (curl, unzip, fc-cache) are available.
ensure_tools() {
  local missing=()
  command -v curl >/dev/null 2>&1 || missing+=(curl)
  command -v unzip >/dev/null 2>&1 || missing+=(unzip)
  command -v fc-cache >/dev/null 2>&1 || missing+=(fontconfig)

  if [[ ${#missing[@]} -gt 0 ]]; then
    as_load_distro
    as_pkg_install "${missing[@]}"
  fi
}

# install_font <name>
# Download and install a single Nerd Font by release asset name.
install_font() {
  local name="$1"
  local url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${name}.zip"
  local tmp

  echo "downloading $name Nerd Font..."
  tmp="$(mktemp -d)"
  if ! curl -fsSL -o "$tmp/$name.zip" "$url"; then
    echo "error: failed to download $name from $url" >&2
    rm -rf "$tmp"
    return 1
  fi

  mkdir -p "$FONT_DIR"
  unzip -o "$tmp/$name.zip" -d "$FONT_DIR/$name" \
    -x "*.txt" "*.md" >/dev/null
  rm -rf "$tmp"
  echo "installed $name to $FONT_DIR/$name"
}

main() {
  echo "nerdfonts setup"
  ensure_tools

  echo "Select a Nerd Font to install:"
  local i
  for i in "${!NERDFONTS[@]}"; do
    printf "  %d) %s\n" "$((i + 1))" "${NERDFONTS[$i]}"
  done

  local choice
  read -r -p "Enter choice [1-${#NERDFONTS[@]}]: " choice
  if ! [[ "$choice" =~ ^[0-9]+$ ]] || \
     (( choice < 1 || choice > ${#NERDFONTS[@]} )); then
    echo "invalid choice, skipping nerdfonts" >&2
    return 1
  fi

  install_font "${NERDFONTS[$((choice - 1))]}"

  echo "refreshing font cache..."
  fc-cache -f "$FONT_DIR" >/dev/null

  echo "nerdfonts setup complete"
}

main "$@"
