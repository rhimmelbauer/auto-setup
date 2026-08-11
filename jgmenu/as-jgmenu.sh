#!/usr/bin/env bash
#
# as-jgmenu.sh
# Install jgmenu, a small, fast and configurable X11 menu.
#
# Can be run standalone or via the global auto-setup.sh.
#   https://github.com/jgmenu/jgmenu

set -uo pipefail

# Load shared helpers (distro selection/persistence, package installation).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

main() {
  echo "jgmenu setup"

  if command -v jgmenu >/dev/null 2>&1; then
    echo "jgmenu is already installed, skipping"
    return 0
  fi

  # jgmenu is in the official repos on both Arch and Debian/Ubuntu.
  as_pkg_install jgmenu
  echo "jgmenu setup complete"
}

main "$@"
