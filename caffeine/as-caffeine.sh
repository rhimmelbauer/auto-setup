#!/usr/bin/env bash
#
# as-caffeine.sh
# Install caffeine, a tool to keep the screen awake / prevent the desktop
# from going to sleep.
#
# Can be run standalone or via the global auto-setup.sh.
#   https://code.launchpad.net/caffeine

set -uo pipefail

# Load shared helpers (distro selection/persistence, package installation).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

install_caffeine() {
  as_load_distro

  case "$AS_DISTRO" in
    debian)
      as_pkg_install caffeine
      ;;
    arch)
      # caffeine (caffeine-ng) lives in the AUR, so it needs an AUR helper.
      if command -v yay >/dev/null 2>&1; then
        yay -S --needed --noconfirm caffeine-ng
      elif command -v paru >/dev/null 2>&1; then
        paru -S --needed --noconfirm caffeine-ng
      else
        echo "error: caffeine-ng is an AUR package; install an AUR helper" >&2
        echo "       such as 'yay' or 'paru', then re-run this script." >&2
        return 1
      fi
      ;;
    *)
      echo "error: unsupported distro '$AS_DISTRO'" >&2
      return 1
      ;;
  esac
}

main() {
  echo "caffeine setup"

  if command -v caffeine >/dev/null 2>&1; then
    echo "caffeine is already installed, skipping"
    return 0
  fi

  install_caffeine
  echo "caffeine setup complete"
}

main "$@"
