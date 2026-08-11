#!/usr/bin/env bash
#
# as-flameshot.sh
# Install flameshot, a powerful yet simple screenshot tool.
#
# Can be run standalone or via the global auto-setup.sh.
#   https://flameshot.org/docs/installation/installation-linux/

set -uo pipefail

# Load shared helpers (distro selection/persistence, package installation).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

main() {
  echo "flameshot setup"

  if command -v flameshot >/dev/null 2>&1; then
    echo "flameshot is already installed, skipping"
    return 0
  fi

  # flameshot is in the official repos on both Arch and Debian/Ubuntu.
  as_pkg_install flameshot
  echo "flameshot setup complete"
}

main "$@"
