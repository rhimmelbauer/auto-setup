#!/usr/bin/env bash
#
# lib/common.sh
# Shared helpers for auto-setup scripts.
#
# Provides:
#   - Distro selection/persistence (Arch vs Debian/Ubuntu), saved globally so
#     each individual as-<cmd>.sh script can run standalone and still know
#     which package manager to use.
#   - as_pkg_install: install packages using the appropriate package manager.

# Guard against sourcing more than once.
if [[ -n "${AS_COMMON_SOURCED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
AS_COMMON_SOURCED=1

# Where the selected distro is persisted globally.
AS_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/auto-setup"
AS_DISTRO_FILE="$AS_CONFIG_DIR/distro"

# as_select_distro
# Prompt the user to choose their distro and persist the choice globally.
as_select_distro() {
  local choice
  while true; do
    echo "Select your distribution:"
    echo "  1) Arch"
    echo "  2) Debian/Ubuntu"
    read -r -p "Enter choice [1-2]: " choice
    case "$choice" in
      1) AS_DISTRO="arch"; break ;;
      2) AS_DISTRO="debian"; break ;;
      *) echo "Invalid choice, please try again." ;;
    esac
  done

  mkdir -p "$AS_CONFIG_DIR"
  echo "$AS_DISTRO" > "$AS_DISTRO_FILE"
  export AS_DISTRO
}

# as_load_distro
# Load the distro from the environment or the saved config file. If neither is
# available, prompt for it. Lets individual scripts run independently.
as_load_distro() {
  if [[ -n "${AS_DISTRO:-}" ]]; then
    return 0
  fi

  if [[ -f "$AS_DISTRO_FILE" ]]; then
    AS_DISTRO="$(cat "$AS_DISTRO_FILE")"
    export AS_DISTRO
    return 0
  fi

  as_select_distro
}

# as_pkg_install <package>...
# Install one or more packages using the appropriate package manager.
as_pkg_install() {
  as_load_distro

  case "$AS_DISTRO" in
    arch)
      sudo pacman -S --needed --noconfirm "$@"
      ;;
    debian)
      sudo apt-get update
      sudo apt-get install -y "$@"
      ;;
    *)
      echo "error: unknown distro '$AS_DISTRO'" >&2
      return 1
      ;;
  esac
}
