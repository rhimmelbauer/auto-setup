#!/usr/bin/env bash
#
# as-pavucontrol.sh
# Install pavucontrol, the PulseAudio Volume Control GUI.
#
# Can be run standalone or via the global auto-setup.sh.
#   https://github.com/pulseaudio/pavucontrol

set -uo pipefail

# Load shared helpers (distro selection/persistence, package installation).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

main() {
  echo "pavucontrol setup"

  if command -v pavucontrol >/dev/null 2>&1; then
    echo "pavucontrol is already installed, skipping"
    return 0
  fi

  # pavucontrol is in the official repos on both Arch and Debian/Ubuntu.
  as_pkg_install pavucontrol
  echo "pavucontrol setup complete"
}

main "$@"
