#!/usr/bin/env bash
#
# auto-setup.sh
# Global setup script that walks you through installing each package.
#
# Each package has its own script under <cmd>/as-<cmd>.sh and can be run
# independently. This global script runs through them in a defined order,
# skipping any package that is already installed.

set -uo pipefail

# Directory this script lives in, so it works regardless of the caller's cwd.
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Shared helpers (distro selection/persistence, package installation).
source "$ROOT_DIR/lib/common.sh"

# Install order (as defined in ai-instructions.md).
PACKAGES=(
  caffeine
  flameshot
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
    if is_installed "$cmd"; then
      echo "skipping $cmd"
      read -r -p "Press enter to continue..." _
      continue
    fi

    run_package "$cmd"
  done

  echo "auto-setup complete"
}

main "$@"
