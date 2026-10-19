# Dotfiles

Personal development environment for **Debian/Ubuntu**, **Fedora**, and **Arch Linux**, built around Neovim, tmux, Alacritty, and i3.

The repository contains the configuration files plus a bootstrap script that installs the required toolchains, Neovim, tmux, and the LSPs/formatters/debug adapters used by the editor.

![Debian](https://img.shields.io/badge/Debian-12-A81D33?logo=debian&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-supported-E95420?logo=ubuntu&logoColor=white)
![Fedora](https://img.shields.io/badge/Fedora-supported-51A2DA?logo=fedora&logoColor=white)
![Arch](https://img.shields.io/badge/Arch-supported-1793D1?logo=archlinux&logoColor=white)
![Neovim](https://img.shields.io/badge/Neovim-0.10.4-57A143?logo=neovim&logoColor=white)
![tmux](https://img.shields.io/badge/tmux-3.x-1BB91F?logo=tmux&logoColor=white)

## What is this?

This is a ready-to-reproduce workstation setup for a terminal-first workflow:

- **Neovim** with LSP, completion, formatting, linting, Treesitter, Git integration, debugging, and test running.
- **Language support** for Python, C/C++, Go, Rust, Odin, Zig, Lua, JavaScript/TypeScript, HTML, CSS, and Tailwind.
- **tmux** with a `C-a` prefix, Vim-style pane navigation, session restore, and clipboard integration.
- **Alacritty** configuration and themes.
- **i3/i3status** desktop configuration.
- **One bootstrap script** for Debian/Ubuntu, Fedora, and Arch Linux on `x86_64` and `arm64`.

PHP is intentionally excluded. It is handled in a different editor.

## Requirements

- Debian 12+, Ubuntu, Fedora, or Arch Linux (64-bit `x86_64` or `arm64`).
- `sudo` access for OS packages, unless running as root.
- Internet access during bootstrap.
- Git.
- A [Nerd Font](https://www.nerdfonts.com/) is recommended. The Alacritty and i3 configs use `JetBrainsMonoNLNerdFont`, which is not installed by the bootstrap script.

> [!WARNING]
> The bootstrap script runs the distribution package manager (`apt-get`, `dnf`, or `pacman`), downloads toolchains, and replaces dotfile symlinks. Review it before running, especially on an existing machine. The `install` helper removes existing targets before creating symlinks.

## Usage

### Quick start

```bash
git clone https://github.com/cristhianjhlcom/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Inspect what would happen first
./bootstrap.sh --dry-run

# Run the full setup
./bootstrap.sh
```

Open a new shell after the bootstrap finishes so the updated `PATH` is used.

### Bootstrap options

| Option | Description |
| --- | --- |
| `--skip-mason` | Install Neovim plugins but skip Mason-managed LSPs, formatters, and debug adapters. |
| `--skip-dotfiles` | Do not run `./install`; assume the configuration is already linked. |
| `--skip-tmux-plugins` | Do not clone TPM or install tmux plugins. |
| `--nvim-version VER` | Install a specific Neovim version. Default: `0.10.4`. |
| `--dry-run` | Print the actions without changing the system. |
| `-h`, `--help` | Show usage. |

Environment overrides:

```bash
NVIM_VERSION=0.10.4 GO_VERSION=1.27.2 ZIG_VERSION=0.16.0 ODIN_TAG=dev-2026-10 ./bootstrap.sh
```

### Link configuration only

If the tools are already installed and you only want to update the symlinks:

```bash
./install
```

The installer links Neovim, tmux, Alacritty, i3, and i3status into `~/.config`.

## Packages and libraries

The bootstrap installs the following system packages, toolchains, and Neovim dependencies.

### OS packages

The bootstrap installs:

- Build tools: `build-essential`, `cmake`, `pkg-config`, `make`, `clang`, `lld`, `gdb`
- Utilities: `git`, `curl`, `wget`, `unzip`, `zip`, `tar`, `xz-utils`, `ripgrep`, `fd-find`, `less`, `openssh-client`
- Python: `python3`, `python3-pip`, `python3-venv`
- Terminal: `tmux`, `xclip`, `wl-clipboard`

`fd-find` is exposed as `fd` in `~/.local/bin`.

### Language toolchains

| Language | Toolchain |
| --- | --- |
| Node.js | Node.js 22 via NodeSource when the system version is older than 18. |
| Python | System Python 3 with `venv` and `pip`. |
| Go | Latest stable release from `go.dev`, installed under `~/.local/opt`. |
| Rust | `rustup` with `rustfmt` and `clippy`. |
| C/C++ | `clang`, `lld`, `gdb`, and `build-essential`. |
| Odin | Latest official Odin release. |
| Zig | Zig `0.16.0`, matching Mason's `zls` generation. |

Toolchain binaries are linked into `~/.local/bin`, which should appear before system paths in `PATH` (it does in this setup).

### Neovim

Neovim is installed from the official tarball into `~/.local/opt` and linked as `~/.local/bin/nvim`. The tarball is used instead of an AppImage to avoid the `libfuse2` dependency.

> [!NOTE]
> Neovim is pinned to `0.10.4` because the plugin set is validated against that version. Newer Neovim releases may require updating pinned plugins such as `gitsigns.nvim`.

The config uses `lazy.nvim` and the committed `lazy-lock.json` for reproducible plugin versions.

#### Language servers and formatters

| Language | LSP | Formatting / linting |
| --- | --- | --- |
| Python | `pyright`, `ruff` | `ruff` |
| C/C++ | `clangd` | `clang-format` |
| Go | `gopls` | `goimports` |
| Rust | `rust-analyzer` | `rustfmt` from `rustup` |
| Odin | `ols` | `odinfmt` (bundled with `ols`) |
| Zig | `zls` | `zigfmt` from Zig |
| Lua | `lua_ls` | `stylua` |
| JavaScript/TypeScript | `ts_ls` | `prettier`, `eslint_d` |
| HTML/CSS | `html`, `cssls`, `tailwindcss`, `emmet_ls` | `prettier`, `stylelint` |

Python projects are detected through `.venv`, `venv`, or `.virtualenv` directories. Ruff handles import organization, while Pyright is configured not to duplicate it.

#### Neovim plugins

| Plugin | Purpose |
| --- | --- |
| `lazy.nvim` | Plugin manager with lockfile support. |
| `nvim-lspconfig` | LSP client configuration. |
| `mason.nvim`, `mason-lspconfig.nvim`, `mason-tool-installer.nvim` | LSP/tool installation and management. |
| `blink.cmp`, `friendly-snippets` | Completion and snippets. |
| `LuaSnip` | Snippet engine. |
| `nvim-treesitter`, `nvim-treesitter-textobjects` | Syntax highlighting, indentation, and text objects. |
| `telescope.nvim` | Fuzzy finding for files, buffers, symbols, help, and Git. |
| `conform.nvim` | Format-on-save and manual formatting. |
| `nvim-lint` | Linting for JavaScript, TypeScript, CSS, SCSS, and Less. |
| `nvim-dap`, `nvim-dap-ui`, `mason-nvim-dap` | Debug Adapter Protocol UI and Python debugging. |
| `neotest`, `neotest-python` | Running and inspecting Python tests. |
| `gitsigns.nvim`, `vim-fugitive` | Git hunks and Git commands. |
| `toggleterm.nvim` | Integrated terminals and Makefile shortcuts. |
| `lualine.nvim`, `nvim-web-devicons` | Statusline and file icons. |
| `gruvbox` | Color scheme. |
| `nvim-notify` | Notification UI. |
| `indent-blankline.nvim` | Indentation guides. |
| `editorconfig-vim` | EditorConfig support. |
| `neodev.nvim` | Neovim Lua API completion. |

#### Useful keymaps

The leader key is `Space`.

| Keymap | Action |
| --- | --- |
| `<leader>sf` | Find files. |
| `<leader>ss` | Live grep. |
| `<leader>sb` | Search buffers. |
| `<C-p>` | Search Git files. |
| `<leader>e` | Show diagnostic float. |
| `<leader>ca` | Code action. |
| `<leader>rn` | Rename symbol. |
| `<leader>f` | Format buffer. |
| `<leader>tn` | Run nearest test. |
| `<leader>tf` | Run test file. |
| `<leader>ts` | Run test suite. |
| `<leader>td` | Debug nearest test. |
| `<leader>tS` | Toggle test summary. |
| `<F5>` / `<F10>` / `<F11>` / `<F12>` | Continue / step over / step into / step out. |
| `<leader>b` | Toggle breakpoint. |
| `<leader>hs` / `<leader>hr` / `<leader>hp` / `<leader>hd` | Stage / reset / preview / diff Git hunks. |
| `<leader>` + backtick | Toggle terminal. |
| `<leader>m` / `<leader>mc` / `<leader>mr` | Run `make` / `make clean` / `make run`. |
| `<leader>1` | Reload Neovim config and open Mason. |

### tmux

- Prefix changed from `C-b` to `C-a`.
- Mouse support, 10,000-line history, and Vim-style copy mode.
- Vim-style pane navigation with `h`, `j`, `k`, `l` and arrow keys.
- Intuitive splits with `|` and `-`, opened in the current directory.
- Windows and panes are numbered from `1` (`base-index 1`).
- Plugins: `tpm`, `tmux-sensible`, `vim-tmux-navigator`, `tmux-yank`, `tmux-resurrect`, and `tmux-continuum`.

#### Session persistence

tmux keeps sessions alive while the machine is on. To survive a reboot, `tmux-resurrect`
saves the environment and `tmux-continuum` restores it automatically:

- The environment (sessions, windows, panes, layouts, working directories, and pane
  contents) is autosaved every 15 minutes to `~/.local/share/tmux/resurrect/`.
- On server start, the last saved environment is restored (`@continuum-restore 'on'`),
  so you come back to your last session by default.
- A `systemd --user` unit at `~/.config/systemd/user/tmux.service` starts the tmux
  server at login and saves the environment when it stops (`@continuum-boot 'on'`).
- After logging in, open a terminal and run `tmux a` to land in the restored session.
  To attach automatically, add this to your shell rc file (not managed by this repo):
  `[ -z "$TMUX" ] && { tmux attach 2>/dev/null || tmux new -s main; }`.
- Manual control: `prefix + C-s` saves now, `prefix + C-r` restores now.
- Only a conservative program list is relaunched (`vim`, `nvim`, `htop`, `less`, `man`,
  `top`, ...); everything else comes back as a shell in the right directory. Add more
  with `set -g @resurrect-processes 'ssh make python'`.
- Manage the service with `systemctl --user status|stop|disable tmux.service`. To turn
  off auto-start, also set `@continuum-boot 'off'` in `tmux/tmux.conf`.

#### Cheatsheet

Everything inside tmux starts with the prefix `C-a` (`Ctrl+a`); release it and press the key.

From a regular shell (outside tmux):

```bash
tmux                       # create a new session and attach to it
tmux new -s work           # create a named session "work"
tmux ls                    # list sessions
tmux attach -t work        # attach to the session "work" (alias: tmux a -t work)
tmux a                     # attach to the most recently used session (where you left off)
tmux kill-session -t work  # kill one session
tmux kill-server           # kill the server and every session
```

General:

| Keys | Action |
| --- | --- |
| `prefix d` | Detach (leave everything running in the background). |
| `prefix s` | List and switch between sessions. |
| `prefix $` | Rename the current session. |
| `prefix (` / `prefix )` | Previous / next session. |
| `prefix :` | Command prompt, e.g. `:new-session -s work` or `:kill-session`. |
| `prefix ?` | List every key binding. |
| `prefix r` | Reload `tmux.conf`. |
| `prefix I` / `prefix U` | Install / update TPM plugins. |
| `prefix C-s` / `prefix C-r` | Save / restore the session environment now. |
| Mouse | Click to select panes/windows, drag borders to resize, scroll to enter copy mode. |

Windows:

| Keys | Action |
| --- | --- |
| `prefix c` | New window (in the current directory). |
| `prefix ,` | Rename the current window. |
| `prefix n` / `prefix p` | Next / previous window. |
| `prefix 1` … `prefix 9` | Jump to window by number. |
| `prefix w` | List and switch between windows. |
| `prefix &` | Close the current window. |
| `prefix S-Left` / `prefix S-Right` | Previous / next window. |

Panes:

| Keys | Action |
| --- | --- |
| `prefix \|` | Split vertically (side by side). |
| `prefix -` | Split horizontally (stacked). |
| `prefix h` / `j` / `k` / `l` | Move left / down / up / right between panes. |
| `prefix z` | Zoom (maximize) the current pane; press again to restore. |
| `prefix o` | Cycle to the next pane. |
| `prefix q` | Show pane numbers. |
| `prefix x` | Close the current pane. |
| `prefix {` / `prefix }` | Move the pane left / right. |
| `prefix Space` | Cycle through pane layouts. |

Copy mode (Vim keys):

| Keys | Action |
| --- | --- |
| `prefix [` | Enter copy mode. |
| `v` | Start selection. |
| `C-v` | Toggle rectangular selection. |
| `y` | Copy selection to the system clipboard (`tmux-yank`). |
| `q` / `Esc` | Leave copy mode. |

### Alacritty and i3

The bootstrap script links the Alacritty and i3 configurations but does not install the desktop packages or fonts. Install Alacritty, i3, i3status, dmenu, i3lock, xss-lock, NetworkManager applet, and a Nerd Font separately if you use those configs.

- **Alacritty**: Sweetie Light theme, JetBrainsMonoNL Nerd Font, 160x80 initial window, clipboard shortcuts, and 100,000-line scrollback.
- **i3**: `Mod4` as the modifier key, dmenu launcher, standard workspace bindings, and i3status with battery information.

#### i3 cheatsheet

`Mod` is `Mod4` (the Super/Windows key). Bindings follow the Vim-style layout:
`j`/`k`/`l`/`;` mean left/down/up/right.

Applications and session:

| Keys | Action |
| --- | --- |
| `Mod+Return` | Open a terminal (`i3-sensible-terminal`). |
| `Mod+d` | Open the `dmenu_run` launcher. |
| `Mod+Shift+q` | Kill the focused window. |
| `Mod+Shift+c` | Reload the i3 configuration. |
| `Mod+Shift+r` | Restart i3 in place (keeps layout/session). |
| `Mod+Shift+e` | Exit i3 / log out (asks for confirmation). |
| `Mod+r` | Enter resize mode (see below). |
| Mouse + `Mod` | Drag floating windows to move them. |

Focus and move:

| Keys | Action |
| --- | --- |
| `Mod+j` / `Mod+k` / `Mod+l` / `Mod+;` | Focus left / down / up / right. |
| `Mod+Left` / `Down` / `Up` / `Right` | Same, with the arrow keys. |
| `Mod+Shift+j` / `k` / `l` / `;` | Move the focused window left / down / up / right. |
| `Mod+Shift+Arrow` | Same, with the arrow keys. |
| `Mod+a` | Focus the parent container. |

Layout:

| Keys | Action |
| --- | --- |
| `Mod+h` | Split horizontally (side by side). |
| `Mod+v` | Split vertically (stacked). |
| `Mod+f` | Toggle fullscreen. |
| `Mod+s` | Stacking layout. |
| `Mod+w` | Tabbed layout. |
| `Mod+e` | Toggle split layout. |
| `Mod+Shift+space` | Toggle tiling / floating. |
| `Mod+space` | Move focus between tiling and floating windows. |

Workspaces:

| Keys | Action |
| --- | --- |
| `Mod+1` … `Mod+0` | Switch to workspace 1–10. |
| `Mod+Shift+1` … `Mod+Shift+0` | Move the focused window to workspace 1–10. |

Resize mode (press `Mod+r` first, then):

| Keys | Action |
| --- | --- |
| `j` / `;` | Shrink / grow width. |
| `k` / `l` | Grow / shrink height. |
| `Arrow` keys | Same as above. |
| `Return` / `Escape` / `Mod+r` | Return to the default mode. |

Media keys:

| Keys | Action |
| --- | --- |
| `XF86AudioRaiseVolume` / `LowerVolume` | Volume up / down by 10% (`pactl`). |
| `XF86AudioMute` | Mute / unmute the default sink. |
| `XF86AudioMicMute` | Mute / unmute the default source. |

i3bar runs `i3status` at the top with a battery module (refreshed every 5 seconds).

## Repository layout

```text
.
├── bootstrap.sh       # Debian/Ubuntu, Fedora, and Arch provisioning script
├── install            # Symlink helper for configuration files
├── nvim/              # Neovim configuration and lazy-lock.json
├── tmux/              # tmux configuration
├── alacritty/         # Alacritty configuration and themes
├── i3/                # i3 window manager configuration
└── i3status/          # i3status bar configuration
```

## Maintenance

- Install missing Neovim plugins with `:Lazy install`; avoid `:Lazy sync` when you want to preserve the locked versions.
- Update plugins deliberately with `:Lazy update`, then review and commit `nvim/lazy-lock.json`.
- Re-run `./bootstrap.sh` safely to restore missing tools; already-installed versions are skipped.
- Use `./bootstrap.sh --dry-run` to preview changes.
- If `nvim` resolves to an older binary, make sure `~/.local/bin` appears before `/usr/local/bin` in `PATH`.

## Future improvements

- [ ] Add container-based CI for `bootstrap.sh` across Debian 12, Ubuntu 24.04, Fedora, and Arch, on `x86_64` and `arm64`.
- [ ] Add ShellCheck and Lua formatting/linting checks to CI.
- [ ] Add install profiles such as `minimal`, `desktop`, and `full`, plus a `--skip-toolchains` option for faster tests.
- [ ] Install a Nerd Font and optional desktop packages (Alacritty, i3, i3status, dmenu, i3lock) behind an opt-in flag.
- [ ] Add debug adapters for C/C++/Rust (`codelldb` or `gdb`) and Go (`delve`).
- [ ] Evaluate Neovim 0.11+ and update pinned plugins when `gitsigns.nvim` and the LSP setup are compatible.
- [ ] Add backup and rollback support for existing configuration files.
- [x] Extend support to Fedora and Arch Linux.
- [ ] Add a local override file for machine-specific settings and secrets.
- [ ] Improve offline/idempotent behavior for toolchain downloads.
