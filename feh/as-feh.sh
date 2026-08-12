#!/usr/bin/env bash
#
# as-feh.sh
# Install feh, a lightweight image viewer and wallpaper setter.
#
# Can be run standalone or via the global auto-setup.sh.
#   https://feh.finalrewind.org/

set -uo pipefail

# Load shared helpers (distro selection/persistence, package installation).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

main() {
  echo "feh setup"

  if command -v feh >/dev/null 2>&1; then
    echo "feh is already installed, skipping"
    return 0
  fi

  # feh is in the official repos on both Arch and Debian/Ubuntu.
  as_pkg_install feh
  echo "feh setup complete"
}

main "$@"
