#!/usr/bin/env bash
#
# auto-setup.sh
# Global setup script that walks you through installing each package.
#
# Each package has its own script under <cmd>/as-<cmd>.sh and can be run
# independently. This global script walks through them in a defined order,
# announcing each package and letting you continue or skip it.

set -uo pipefail

# Directory this script lives in, so it works regardless of the caller's cwd.
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Shared helpers (distro selection/persistence, package installation).
source "$ROOT_DIR/lib/common.sh"

# Install order (as defined in ai-instructions.md).
PACKAGES=(
  caffeine
  flameshot
  feh
  pavucontrol
  speedcrunch
  jgmenu
  keymapper
  nerdfonts
  nvchad
  fish
  alacritty
  starship
  asdf
  qtile
)

# is_installed <cmd>
# Returns 0 if the package appears to already be installed.
is_installed() {
  command -v "$1" >/dev/null 2>&1
}

# ask_yes_no <question>
# Prompts until the user answers yes or no. Returns 0 for yes, 1 for no.
# A closed stdin (EOF) is treated as no so the loop can't spin forever.
ask_yes_no() {
  local question="$1"
  local answer

  while true; do
    if ! read -r -p "$question [y/n]: " answer; then
      echo
      return 1
    fi

    case "$answer" in
      [Yy] | [Yy][Ee][Ss]) return 0 ;;
      [Nn] | [Nn][Oo]) return 1 ;;
      *) echo "Please answer y or n." ;;
    esac
  done
}

# run_package <cmd>
# Runs the individual as-<cmd>.sh script for a package.
run_package() {
  local cmd="$1"
  local script="$ROOT_DIR/$cmd/as-$cmd.sh"

  if [[ ! -f "$script" ]]; then
    echo "warning: missing script $script, skipping $cmd"
    return
  fi

  bash "$script"
}

main() {
  # Prompt for the distro up front and persist it globally so every
  # individual as-<cmd>.sh script uses the right package manager.
  as_select_distro

  for cmd in "${PACKAGES[@]}"; do
    echo
    echo "Next package: $cmd"

    if ! ask_yes_no "Continue with $cmd?"; then
      echo "skipping $cmd"
      continue
    fi

    if is_installed "$cmd"; then
      echo "$cmd is already installed"
      continue
    fi

    echo "$cmd is not installed"
    if ! ask_yes_no "Install $cmd?"; then
      echo "skipping $cmd"
      continue
    fi

    run_package "$cmd"
  done

  echo
  echo "auto-setup complete"
}

main "$@"
