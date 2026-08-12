# AI Instructions

These instructions describe the goals **and the established conventions** of this
repo so that any AI (or human) can keep working on it consistently. Read this
whole file before making changes.

## Objective

A global, interactive bash script (`auto-setup.sh`) that walks a user through
installing a developer environment. Each package has its **own** script so it
can also be installed independently after cloning the repo (e.g. run
`qtile/as-qtile.sh` on its own to install only qtile).

Packages covered:
- [asdf](https://asdf-vm.com/) (v0.16+ Go binary)
- [fish shell](https://fishshell.com/)
- [alacritty](https://github.com/alacritty/alacritty)
- [qtile](https://docs.qtile.org/en/stable/)
- [jgmenu](https://github.com/jgmenu/jgmenu)
- [nvchad](https://nvchad.com/docs/quickstart/install)
- [starship](https://starship.rs/)
- A choice of [NerdFonts](https://github.com/ryanoasis/nerd-fonts)
- [keymapper](https://github.com/houmain/keymapper)
- [caffeine](https://code.launchpad.net/caffeine)
- [flameshot](https://flameshot.org/)
- [feh](https://feh.finalrewind.org/) (image viewer / wallpaper setter)
- [pavucontrol](https://github.com/pulseaudio/pavucontrol)
- [SpeedCrunch](https://github.com/ruphy/speedcrunch)

> Note: GitHub SSH key creation was intentionally **dropped** as a script (git
> is needed to clone the repo in the first place). It remains a documentation
> reference only.

## Repository layout

```
auto-setup.sh              # global interactive orchestrator
lib/common.sh              # shared helpers (sourced by every script)
<pkg>/as-<pkg>.sh          # one folder + script per package
<pkg>/config/              # optional: bundled dotfiles copied on install
```

- Every package lives in its own folder named after the command.
- Its script is named `as-<pkg>.sh` (the `as-` prefix is required).
- Scripts are executable (`chmod +x`).

## Install order (used by `auto-setup.sh`)

caffeine → flameshot → feh → pavucontrol → speedcrunch → jgmenu →
keymapper → nerdfonts → nvchad → fish → alacritty → starship → asdf →
qtile

## Global script flow (`auto-setup.sh`)

The distro is selected once up front, then each package in the install order is
walked through interactively:

1. Announce the package (`Next package: <pkg>`).
2. Prompt to continue or skip it. Skipping moves straight to the next package.
3. Check whether it is already installed (`command -v <pkg>`).
4. If installed, say so and move on to the next package.
5. If not installed, prompt to confirm the install. Confirming runs
   `<pkg>/as-<pkg>.sh`; declining skips it.

Prompts use the `ask_yes_no` helper, which re-asks on invalid input and treats
a closed stdin (EOF) as "no" so a non-interactive run can't spin forever.

## Shared library: `lib/common.sh`

Every `as-<pkg>.sh` sources `lib/common.sh` so it works standalone. It provides:
- `as_select_distro` — prompts Arch vs Debian/Ubuntu, persists the choice to
  `~/.config/auto-setup/distro`.
- `as_load_distro` — resolves the distro from env → saved file → prompt.
- `as_pkg_install <pkgs...>` — installs via `pacman` (Arch) or `apt-get`
  (Debian). The distro is chosen once in `auto-setup.sh` and reused by all
  scripts; standalone runs prompt on first use.

## Conventions every package script MUST follow

1. Start with `#!/usr/bin/env bash` and `set -uo pipefail`.
2. Resolve its own dir and source the shared lib:
   ```bash
   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   source "$SCRIPT_DIR/../lib/common.sh"
   ```
3. Wrap logic in a `main()` and call `main "$@"` at the end.
4. Print `echo "<pkg> setup"` at the start and a completion line at the end.
5. **Idempotency / skip check:** detect if already installed (usually
   `command -v <bin>`, or a path check like `~/.config/nvim`) and skip the
   install, printing a "skipping" message. The global script additionally does
   its own `command -v` check (see "Global script flow" above).
6. Support **both** Arch and Debian/Ubuntu via `as_pkg_install` / `AS_DISTRO`.

## Installation-method preference

- Prefer official distro repos (via `as_pkg_install`) when the package is
  available there (flameshot, feh, pavucontrol, speedcrunch, jgmenu, fish,
  alacritty).
- For tools **not** in official repos, **build from source** per the upstream
  instructions rather than using a package manager / AUR / prebuilt `.deb`, and
  ensure build deps are installed (`base-devel` on Arch, `build-essential` on
  Debian). Example: keymapper is built from source and also installs a
  `keymapperd` systemd service plus a user autostart client entry.
- Some tools use their own installers/binaries: starship uses the official
  install script on Debian, asdf downloads the latest release binary.

## Dotfile bundling pattern (`<pkg>/config/`)

Some packages ship the user's real config so a fresh machine gets it. When a
`<pkg>/config/` folder exists, the script deploys it in an `install_config`
step that:
1. Backs up any existing destination to `<dest>.bak.<timestamp>`.
2. Copies the bundle with `cp -a`.

Currently bundled: `qtile/config/`, `fish/config/`, `alacritty/config/`,
`starship/config/starship.toml`. Caches (`__pycache__`, `.mypy_cache`) are
excluded from bundles. Note: some bundled configs (e.g. fish `config.fish`)
contain machine-specific absolute paths copied verbatim per the user's request.

## Validation

Syntax-check any script you change with `bash -n <script>`. There is no build
step. GitHub Actions CI is intentionally not set up at the moment.

