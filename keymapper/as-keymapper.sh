#!/usr/bin/env bash
#
# as-keymapper.sh
# Install keymapper (a cross-platform context-aware key remapper) by building
# it from source.
#
# Can be run standalone or via the global auto-setup.sh.
#   https://github.com/houmain/keymapper#building

set -uo pipefail

# Load shared helpers (distro selection/persistence, package installation).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

KEYMAPPER_REPO="https://github.com/houmain/keymapper"

# install_build_deps
# Install the build toolchain and libraries required to compile keymapper.
install_build_deps() {
  case "$AS_DISTRO" in
    arch)
      # base-devel provides the compiler toolchain (make, gcc, etc.).
      as_pkg_install git base-devel cmake \
        libusb dbus \
        libx11 libxkbcommon-x11 \
        libappindicator-gtk3
      ;;
    debian)
      # build-essential provides the compiler toolchain (make, gcc, g++).
      as_pkg_install git cmake build-essential \
        libudev-dev libusb-1.0-0-dev libdbus-1-dev \
        libx11-dev libx11-xcb-dev libxkbcommon-x11-dev \
        libayatana-appindicator3-dev
      ;;
    *)
      echo "error: unsupported distro '$AS_DISTRO'" >&2
      return 1
      ;;
  esac
}

# build_and_install
# Clone keymapper, build it with CMake and install it system-wide.
build_and_install() {
  local src_dir
  src_dir="$(mktemp -d)"

  git clone --depth 1 "$KEYMAPPER_REPO" "$src_dir/keymapper"

  cmake -B "$src_dir/keymapper/build" -S "$src_dir/keymapper"
  cmake --build "$src_dir/keymapper/build" -j"$(nproc)"
  sudo cmake --install "$src_dir/keymapper/build"

  rm -rf "$src_dir"
}

# install_service
# Create and enable a systemd service for the keymapper daemon (keymapperd).
install_service() {
  local service_file="/etc/systemd/system/keymapperd.service"
  local keymapperd_bin

  keymapperd_bin="$(command -v keymapperd)"
  if [[ -z "$keymapperd_bin" ]]; then
    echo "error: keymapperd binary not found after install" >&2
    return 1
  fi

  echo "creating systemd service at $service_file"
  sudo tee "$service_file" >/dev/null <<EOF
[Unit]
Description=Keymapper Daemon

[Service]
ExecStart=$keymapperd_bin

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl enable --now keymapperd.service
}

# setup_client
# Set up the user-session client: a default config file (if none exists) and a
# desktop autostart entry so `keymapper` launches on login and connects to the
# daemon. Runs for the invoking user, not root.
setup_client() {
  local config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
  local config_file="$config_home/keymapper.conf"
  local autostart_dir="$config_home/autostart"
  local desktop_file="$autostart_dir/keymapper.desktop"
  local keymapper_bin

  keymapper_bin="$(command -v keymapper)"
  if [[ -z "$keymapper_bin" ]]; then
    echo "error: keymapper binary not found after install" >&2
    return 1
  fi

  # Create a starter config only if the user doesn't already have one.
  if [[ ! -f "$config_file" ]]; then
    echo "creating default config at $config_file"
    mkdir -p "$config_home"
    cat > "$config_file" <<'EOF'
# keymapper configuration
# See https://github.com/houmain/keymapper#configuration
#
# Example mappings (uncomment to enable):
# CapsLock >> Backspace
# Control{Q} >> Alt{F4}
EOF
  fi

  # Autostart the client in the graphical session (-u auto-reloads on changes).
  echo "creating autostart entry at $desktop_file"
  mkdir -p "$autostart_dir"
  cat > "$desktop_file" <<EOF
[Desktop Entry]
Type=Application
Name=keymapper
Comment=Context-aware key remapper client
Exec=$keymapper_bin -u
Terminal=false
X-GNOME-Autostart-enabled=true
EOF
}

main() {
  echo "keymapper setup"

  if command -v keymapper >/dev/null 2>&1; then
    echo "keymapper is already installed, skipping"
    return 0
  fi

  as_load_distro
  install_build_deps
  build_and_install
  install_service
  setup_client

  echo "keymapper setup complete"
}

main "$@"
