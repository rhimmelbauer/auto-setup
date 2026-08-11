#!/usr/bin/env bash
#
# as-speedcrunch.sh
# Install SpeedCrunch, a fast, high-precision desktop calculator.
#
# Can be run standalone or via the global auto-setup.sh.
#   https://github.com/ruphy/speedcrunch

set -uo pipefail

# Load shared helpers (distro selection/persistence, package installation).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

main() {
  echo "speedcrunch setup"

  if command -v speedcrunch >/dev/null 2>&1; then
    echo "speedcrunch is already installed, skipping"
    return 0
  fi

  # speedcrunch is in the official repos on both Arch and Debian/Ubuntu.
  as_pkg_install speedcrunch
  echo "speedcrunch setup complete"
}

main "$@"
