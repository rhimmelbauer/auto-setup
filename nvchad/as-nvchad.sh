#!/usr/bin/env bash
#
# as-nvchad.sh
# Install NvChad, a Neovim configuration framework, by cloning the starter
# config into ~/.config/nvim.
#
# Can be run standalone or via the global auto-setup.sh.
#   https://nvchad.com/docs/quickstart/install

set -uo pipefail

# Load shared helpers (distro selection/persistence, package installation).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

NVCHAD_STARTER="https://github.com/NvChad/starter"

# install_dependencies
# NvChad needs Neovim (0.10+), git and ripgrep (for telescope live-grep), plus
# a C compiler for treesitter parsers.
install_dependencies() {
  case "$AS_DISTRO" in
    arch)
      as_pkg_install neovim git ripgrep base-devel
      ;;
    debian)
      as_pkg_install neovim git ripgrep build-essential
      ;;
    *)
      echo "error: unsupported distro '$AS_DISTRO'" >&2
      return 1
      ;;
  esac
}

main() {
  echo "nvchad setup"

  local config_home nvim_dir
  config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
  nvim_dir="$config_home/nvim"

  if [[ -d "$nvim_dir" ]]; then
    echo "nvchad (or an existing nvim config) already present at $nvim_dir, skipping"
    return 0
  fi

  as_load_distro
  install_dependencies

  echo "cloning NvChad starter into $nvim_dir"
  git clone "$NVCHAD_STARTER" "$nvim_dir"
  # Remove the starter's git history so users can track their own config.
  rm -rf "$nvim_dir/.git"

  echo "nvchad setup complete"
  echo "launch 'nvim' to finish plugin installation."
}

main "$@"
