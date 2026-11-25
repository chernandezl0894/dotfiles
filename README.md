# Dotfiles

Personal development environment for **Debian/Ubuntu**, **Fedora**, and **Arch Linux**, built around Neovim, zsh, tmux, Alacritty, and i3.

The repository contains the configuration files plus a bootstrap script that installs the required toolchains, Neovim, zsh, tmux, the minimal i3 desktop, and the LSPs/formatters/debug adapters used by the editor.

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
- **zsh** with shared history, completion with inline autosuggestions, a compact two-line prompt, and optional pyenv/nvm/zoxide/direnv hooks.
- **tmux** with a `C-a` prefix, Vim-style pane navigation, fzf project switching, session restore, and clipboard integration.
- **Alacritty** as the primary terminal: Nerd Font, padding, opacity, Vi mode, and clipboard shortcuts.
- **i3/i3status** with a lightweight configuration for low-resource laptops.
- **One bootstrap script** for Debian/Ubuntu, Fedora, and Arch Linux on `x86_64` and `arm64`.



## Requirements

- Debian 12+, Ubuntu, Fedora, or Arch Linux (64-bit `x86_64` or `arm64`).
- `sudo` access for OS packages, unless running as root.
- Internet access during bootstrap.
- Git.
- A [Nerd Font](https://www.nerdfonts.com/) is required by the i3 bar. The i3 config uses `AdwaitaMono Nerd Font Mono`, which the bootstrap script installs automatically (see the i3 section for the manual command).

> [!WARNING]
> The bootstrap script runs the distribution package manager (`apt-get`, `dnf`, or `pacman`), downloads toolchains, and replaces dotfile symlinks. Review it before running, especially on an existing machine: linking removes existing targets before creating symlinks.

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
| `--skip-dotfiles` | Do not link the dotfiles; assume the configuration is already linked. |
| `--skip-tmux-plugins` | Do not clone TPM or install tmux plugins. |
| `--skip-zsh-plugins` | Do not clone the zsh completion and autosuggestion plugins. |
| `--skip-fonts` | Do not download or install the i3bar Nerd Font. |
| `--set-zsh-shell` | Set zsh as the login shell for the current user. |
| `--nvim-version VER` | Install a specific Neovim version. Default: `0.10.4`. |
| `--dry-run` | Print the actions without changing the system. |
| `-h`, `--help` | Show usage. |

Environment overrides:

```bash
NVIM_VERSION=0.10.4 GO_VERSION=1.27.2 ZIG_VERSION=0.16.0 ODIN_TAG=dev-2026-10 LAZYGIT_VERSION=0.66.4 ALACRITTY_VERSION=0.17.0 ./bootstrap.sh
```

### Re-link configuration

The bootstrap script is idempotent and always (re)creates the configuration symlinks unless `--skip-dotfiles` is passed. To refresh the symlinks with the heavier steps skipped:

```bash
./bootstrap.sh --skip-mason --skip-tmux-plugins
```

It links Neovim, zsh, tmux, Alacritty, Ghostty, Git, lazygit, i3, and i3status into `~/.config`, replacing existing targets. It also links `zsh/zshrc` to `~/.zshrc`, `tmux-sessionizer` and the `theme` switcher into `~/.local/bin`, and `tmux/tmux.conf` into `~/.tmux.conf`, and installs the i3bar Nerd Font into `${XDG_DATA_HOME:-~/.local/share}/fonts` unless `--skip-fonts` is passed.

## Packages and libraries

The bootstrap installs the following system packages, toolchains, and Neovim dependencies.

### OS packages

The bootstrap installs:

- Build tools: `build-essential`, `cmake`, `pkg-config`, `make`, `clang`, `lld`, `gdb`
- Build headers for Alacritty: `fontconfig`, `freetype`, `xcb`, `xkbcommon`, `wayland`, and `ncurses`/`tic`
- Utilities: `git`, `curl`, `wget`/`wget2`, `unzip`, `zip`, `tar`, `xz-utils`, `ripgrep`, `fd-find`, `fzf`, `less`, `openssh-client`
- Python: `python3`, `python3-pip`, `python3-venv`
- Terminal: `zsh`, `tmux`, `xclip`, `wl-clipboard`
- Desktop (lightweight): `i3`, `i3status`, `i3lock`, `xss-lock`, `rofi`, `maim`, `brightnessctl`, `playerctl`, `dex`
- Shell helpers: `zoxide`, `direnv`

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

HTML/JS/CSS work includes Emmet completions in HTML, CSS, JSX, and TSX files,
Prettier and eslint/stylelint, automatic tag renaming, bracket pairs, and CSS
color previews.

#### Neovim plugins

| Plugin | Purpose |
| --- | --- |
| `lazy.nvim` | Plugin manager with lockfile support. |
| `nvim-lspconfig` | LSP client configuration. |
| `mason.nvim`, `mason-lspconfig.nvim`, `mason-tool-installer.nvim` | LSP/tool installation and management. |
| `blink.cmp`, `friendly-snippets` | Completion and snippets. |
| `LuaSnip` | Snippet engine. |
| `nvim-treesitter`, `nvim-treesitter-textobjects` | Syntax highlighting, indentation, text objects, and function/parameter jumps. |
| `telescope.nvim`, `telescope-fzf-native.nvim`, `telescope-ui-select.nvim` | Fuzzy finding for files, buffers, symbols, help, Git, diagnostics, keymaps, and `vim.ui.select`. |
| `trouble.nvim` | Diagnostics, symbols, references, quickfix, and location lists. |
| `flash.nvim`, `harpoon` | Fast jumps and pinned project files. |
| `persistence.nvim` | Per-project session restore. |
| `grug-far.nvim`, `nvim-surround` | Project-wide search/replace and surround editing. |
| `nvim-ts-autotag`, `nvim-autopairs`, `nvim-colorizer.lua` | HTML/JSX tag handling, bracket pairs, and CSS color previews. |
| `render-markdown.nvim`, `todo-comments.nvim`, `rainbow-delimiters.nvim` | Markdown rendering, TODO search, and delimiter colors. |
| `minuet-ai.nvim` | Manual AI completion with Ollama or a cloud API. |
| `conform.nvim` | Format-on-save and manual formatting. |
| `nvim-lint` | Linting for JavaScript, TypeScript, CSS, SCSS, and Less. |
| `nvim-dap`, `nvim-dap-ui`, `nvim-dap-virtual-text`, `mason-nvim-dap` | Debug Adapter Protocol UI, inline values, and Python debugging. |
| `neotest`, `neotest-python` | Running and inspecting Python tests. |
| `gitsigns.nvim`, `vim-fugitive` | Git hunks, line blame, and Git commands. |
| `toggleterm.nvim` | Integrated terminals, Makefile shortcuts, and a lazygit float. |
| `vim-tmux-navigator` | Seamless navigation between Neovim splits and tmux panes. |
| `which-key.nvim` | Keymap discovery with grouped leader menus. |
| `lualine.nvim`, `nvim-web-devicons` | Statusline with Git branch/diff, diagnostics, LSP client, search count, and file icons. |
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
| `<leader>sd` | Search diagnostics. |
| `<leader>sk` | Search keymaps. |
| `<leader>st` | Search TODOs. |
| `<leader>sr` | Search and replace in the project. |
| `<C-p>` | Search Git files. |
| `s` / `S` | Flash jump / Flash Treesitter. |
| `<A-]>` / `<A-[>` | Request/cycle AI completion with Minuet (manual only). |
| `<A-a>` / `<A-A>` / `<A-w>` / `<A-e>` | Accept line / all / next word / dismiss AI completion. |
| `<leader>xx` / `<leader>xX` / `<leader>xs` / `<leader>xr` / `<leader>xl` / `<leader>xq` | Trouble: diagnostics / buffer diagnostics / symbols / references / location list / quickfix. |
| `<leader>Ha` / `<leader>Hm` / `<leader>H1`…`<leader>H4` | Harpoon: add file / menu / jump to file. |
| `<leader>qs` / `<leader>ql` / `<leader>qd` | Restore session / restore last session / don't save session. |
| `<leader>um` | Toggle in-buffer Markdown rendering. |
| `]f` / `[f` / `]a` / `[a` | Next/previous function or parameter. |
| `<leader>e` | Show diagnostic float. |
| `<leader>ca` | Code action. |
| `<leader>rn` | Rename symbol. |
| `<leader>f` | Format buffer. |
| `<leader>tn` | Run nearest test. |
| `<leader>tf` | Run test file. |
| `<leader>ts` | Run test suite. |
| `<leader>td` | Debug nearest test. |
| `<leader>tS` | Toggle test summary. |
| `<F5>` / `<F9>` / `<F10>` / `<F11>` / `<F12>` | Continue / toggle breakpoint / step over / into / out. |
| `<leader>b` / `<leader>B` / `<leader>lp` | Toggle / conditional breakpoint, and log point. |
| `<leader>du` / `<leader>de` / `<leader>dr` / `<leader>dt` / `<leader>dR` | Toggle DAP UI / evaluate / REPL / terminate / restart. |
| `<leader>hs` / `<leader>hr` / `<leader>hp` / `<leader>hd` | Stage / reset / preview / diff Git hunks. |
| `<leader>gB` / `<leader>gS` | Toggle line blame / stage the whole buffer. |
| `<leader>gl` / `<leader>gL` / `<leader>gb` / `<leader>gz` | Git log / buffer log / branches / stashes. |
| `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` | Move between Neovim splits and tmux panes. |
| `<leader>\|` / `<leader>-` | Split vertically / horizontally (mirrors `prefix \|` and `prefix -` in tmux). |
| `<leader>` + backtick | Toggle terminal. |
| `<leader>tt` / `<leader>th` / `<leader>tv` | Floating / horizontal / vertical terminal. |
| `<leader>t1` … `<leader>t5` | Open terminal by number. |
| `<leader>tN` / `<leader>tA` | New terminal / toggle all terminals. |
| `<leader>t.` | Send the current line or selection to terminal 1. |
| `<leader>gg` | Open lazygit in a floating terminal at the repository root. |
| `<leader>m` / `<leader>mc` / `<leader>mr` | Run `make` / `make clean` / `make run`. |
| `<leader>1` | Reload Neovim config and open Mason. |

#### AI completion

Minuet is configured for **manual** completion only: it does not send requests
while typing. Press `<A-]>` to request or cycle a suggestion and `<A-a>` to
accept one line. `<A-A>` accepts the whole suggestion, `<A-w>` the next word,
and `<A-e>` dismisses it.

The default provider is local Ollama with `qwen2.5-coder:1.5b`. To use
DeepSeek, export the key before starting Neovim:

```bash
export DEEPSEEK_API_KEY=...
MINUET_PRESET=deepseek nvim
```

Or switch at runtime to the predefined DeepSeek preset:

```vim
:Minuet change_preset deepseek
```

Return to the local model with `:Minuet change_preset local`. Optional
overrides: `MINUET_OLLAMA_MODEL`, `MINUET_OLLAMA_ENDPOINT`,
`MINUET_DEEPSEEK_MODEL`, and `MINUET_DEEPSEEK_ENDPOINT`.

### git

Git reads the shared settings from `git/config` (linked to
`~/.config/git/config`), while the machine-specific identity and credentials
stay in `~/.gitconfig`, which is not managed by this repository. The global
ignore patterns live in `git/ignore` (linked to `~/.config/git/ignore`).

- Rebase on pull, prune on fetch, auto-setup remotes, rerere, `zdiff3` conflict
  markers, histogram diffs, moved-line detection, and verbose commits.
- User aliases: `git st`, `co`, `sw`, `br`, `ci`, `last`, `lg`, `df`, `dc`,
  `unstage`, and `amend`.
- `core.editor` and the interactive-rebase editor are set to `nvim`.

The bootstrap installs lazygit with Go (`LAZYGIT_VERSION`, default `0.66.4`)
and links `lazygit/config.yml` to `~/.config/lazygit/config.yml`. To install or
update it manually:

```bash
GOBIN="$HOME/.local/bin" go install github.com/jesseduffield/lazygit@v0.66.4
```

Press `<leader>gg` to open it in a floating terminal at the repository root.
Files opened from lazygit with `e` open in the Neovim instance that launched it
(`os.editPreset: nvim-remote`).

### zsh

The bootstrap installs zsh and links `zsh/zshrc` to `~/.zshrc`. The
configuration is intentionally minimal:

- **Two-line prompt**: the working directory and git branch are on the first line
  and the `❯` marker on the second, so narrow terminals stay readable.
- **History and completion**: 20,000 shared history entries, duplicate
  suppression, and a colored menu completion with case-insensitive matching.
- **Autosuggestions**: `zsh-autosuggestions` and `zsh-completions` are cloned
  into `${XDG_DATA_HOME:-~/.local/share}/zsh/plugins` by the bootstrap; the
  config also falls back to an existing `~/.oh-my-zsh/custom/plugins` copy, so
  the shell still works without them. Suggestions appear in grey and are
  accepted with `Ctrl-E` or `Right`; `Alt-Right` accepts one word.
- **PATH and editor**: `~/.local/bin`, `~/go/bin`, and `~/.cargo/bin` are added
  to `PATH`; `EDITOR`, `VISUAL`, and `PAGER` default to `nvim`, `nvim`, and
  `less`.
- **Optional integrations**: pyenv, nvm, zoxide, and direnv are loaded only when
  they are installed.
- **Machine-specific settings** belong in `~/.zshrc.local`, which is sourced at
  the end when present.

Aliases:

| Alias | Expands to |
| --- | --- |
| `ll`, `la` | `ls -lah` |
| `gs` | `git status -sb` |
| `gd` | `git diff` |
| `gl` | `git log --oneline --graph --decorate -20` |
| `ga` / `gc` | `git add` / `git commit` |
| `tm` | `tmux new -A -s main` |
| `ta` | `tmux attach` |
| `reload` | `source ~/.zshrc` |

New shells keep using the previous login shell by default. To make zsh the
login shell, run the bootstrap with `--set-zsh-shell`, or do it manually and
then start a new session:

```bash
chsh -s "$(command -v zsh)"   # log out and back in afterwards
```

### tmux

- Prefix changed from `C-b` to `C-a`.
- Mouse support, 10,000-line history, and Vim-style copy mode.
- Vim-style pane navigation with `h`, `j`, `k`, `l` and arrow keys.
- Intuitive splits with `|` and `-`, and new windows with `c`, all opened in the
  current directory.
- Repeatable pane resizing with `prefix H/J/K/L`.
- Pane borders show the pane index and title.
- Project sessionizer with `prefix f`: a fuzzy picker (`fzf` + `fd`) over
  `~/workspace`, `~/github`, and `~/crissis16` that creates or switches to a
  tmux session for the selected project. Override the roots with
  `TMUX_SESSIONIZER_DIRS`.
- Windows and panes are numbered from `1` (`base-index 1`).
- Plugins (TPM lives in `~/.config/tmux/plugins`): `tmux-sensible`,
  `vim-tmux-navigator`, `tmux-yank`, `tmux-resurrect`, `tmux-continuum`,
  `tmux-fzf`, and `tmux-open`.

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
| `prefix f` | Pick a project and create/switch to its tmux session. |
| `prefix F` | Search and manage sessions/windows/panes with `tmux-fzf`. |
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
| `prefix H` / `J` / `K` / `L` | Resize the pane left / down / up / right (repeatable). |
| `prefix Space` | Cycle through pane layouts. |

Copy mode (Vim keys):

| Keys | Action |
| --- | --- |
| `prefix [` | Enter copy mode. |
| `v` | Start selection. |
| `C-v` | Toggle rectangular selection. |
| `y` | Copy selection to the system clipboard (`tmux-yank`). |
| `o` / `C-o` | Open the selected path or URL with `xdg-open` / `$EDITOR` (`tmux-open`). |
| `q` / `Esc` | Leave copy mode. |

### Alacritty and i3

The bootstrap installs the minimal i3 stack (i3, i3status, i3lock, xss-lock,
rofi, maim, brightnessctl, playerctl, and dex), builds Alacritty from source,
and links the Alacritty, i3, and i3status configurations. The NetworkManager
applet is started only when `nm-applet` is already installed.

Alacritty is built with Cargo from the pinned `ALACRITTY_VERSION` (default
`0.17.0`) instead of Debian 12's old package. The bootstrap also installs the
terminfo entry, the `.desktop` file, and the icon in `~/.local`.

- **Alacritty** is the primary terminal: theme managed centrally (gruvbox-dark by default), AdwaitaMono Nerd
  Font Mono, 4 px padding, 0.97 opacity, 160x80 initial window, Vi mode,
  OSC 52 copy support, clipboard shortcuts, and 100,000-line scrollback. Bold,
  italic, and bold-italic faces use the same Nerd Font.
- **i3** keeps the `Mod4` modifier and standard workspace bindings, adds small
  gaps, a scratchpad, rofi, screenshots, screen locking, brightness/media keys,
  and a lightweight i3status bar with Wi-Fi, CPU, RAM, disk, battery, and local
  date/time (Lima).

To install the bar font manually (the bootstrap script does this automatically):

```bash
mkdir -p ~/.local/share/fonts/adwaita-mono-nerd
curl -sSL -o /tmp/AdwaitaMono.zip \
  https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/AdwaitaMono.zip
unzip -oq /tmp/AdwaitaMono.zip '*.ttf' -d ~/.local/share/fonts/adwaita-mono-nerd
fc-cache -f ~/.local/share/fonts
fc-list | grep -i adwaita   # verify
```

The `Mono` variant (`AdwaitaMono Nerd Font Mono`) keeps icons at a single cell width so the bar does not shift.

#### i3 cheatsheet

`Mod` is `Mod4` (the Super/Windows key). Bindings follow the Vim-style layout:
`j`/`k`/`l`/`;` mean left/down/up/right.

Applications and session:

| Keys | Action |
| --- | --- |
| `Mod+Return` | Open Alacritty (falls back to `i3-sensible-terminal`). |
| `Mod+d` | Open the rofi application launcher. |
| `Mod+Shift+q` | Kill the focused window. |
| `Mod+Shift+x` | Lock the screen. |
| `Print` / `Mod+Print` | Screenshot a region / the whole screen to the clipboard. |
| `Mod+minus` / `Mod+Shift+minus` | Show / move the focused window to the scratchpad. |
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
| `XF86AudioPlay` / `Next` / `Prev` | Play-pause / next / previous track (`playerctl`). |
| `XF86MonBrightnessUp` / `Down` | Brightness up / down by 5% (`brightnessctl`). |

i3bar runs `i3status` at the bottom, refreshed every 5 seconds. From left to right it shows Wi-Fi (ESSID, colored by signal quality), CPU usage, RAM usage, root disk availability, battery (icon by state, percentage, and time left), and the date/time in `America/Lima`. Volume keys send `SIGUSR1` to `i3status`, so the bar refreshes immediately even though it no longer displays the volume.

## Themes

Themes live in `themes/<name>/`, with one native snippet per application:

```text
themes/gruvbox-dark/
├── alacritty.toml   # [colors.*] importado por Alacritty
├── tmux.conf        # status, bordes, mensajes y modo
├── i3.conf          # client.* y colores de la barra
├── nvim.lua         # colorscheme, background y overrides
└── opencode.json    # name + mode para OpenCode
```

`~/.config/theme/current` is a symlink to the active theme. Every app includes
from that stable path:

- Alacritty: `import = ["~/.config/theme/current/alacritty.toml"]`
- tmux: `if-shell` + `source-file` (tmux does not expand `~` on its own)
- i3: `include ~/.config/theme/current/i3.conf`
- Neovim: `config/theme.lua` loads `nvim.lua` and watches
  `~/.config/theme` to reapply the theme in every running instance.

Switch themes from anywhere:

```bash
theme list
theme current
theme set gruvbox-light
theme next
```

The switcher reloads Alacritty (live config reload), tmux (`source-file`) and
i3 (`i3-msg reload`); Neovim updates through the filesystem watcher. Apps that
are not running are ignored. Available themes: `gruvbox-dark` (default),
`gruvbox-light`, `catppuccin-mocha` and `catppuccin-latte`.

OpenCode reads its theme from `~/.config/opencode/cli.json`. Each theme maps
itself with `opencode.json`:

```json
{ "name": "gruvbox", "mode": "dark" }
```

`theme set` merges that object into the WSL config and, when present, the
Windows config at `C:\Users\<user>\.config\opencode\cli.json`. OpenCode
reloads CLI settings live; if a Windows instance does not pick it up, reopen it.
Override the Windows path with `WIN_OPENCODE_CONFIG` if needed.

Windows Neovim keeps its own config at `%LOCALAPPDATA%\nvim`. `theme set` copies
the active `nvim.lua` to `%LOCALAPPDATA%\nvim\theme-central.lua`; that config
loads the file once and watches it, so the same theme applies live. The original
Windows `theme.lua` is backed up as `theme.lua.bak-pre-central` when this is
enabled. Override the directory with `WIN_NVIM`.

To add a theme, create a directory with the same five files. If it uses a
Neovim colorscheme that is not installed, add the plugin first; if the
colorscheme is missing, Neovim falls back to gruvbox with a warning.

### Alacritty on Windows

Windows Alacritty reads `%APPDATA%\alacritty\alacritty.toml`, a different file
from the WSL one. It keeps its own font, size, opacity and window settings, and
imports a stable theme file:

```toml
import = ["C:/Users/USER/AppData/Roaming/alacritty/theme.toml"]
```

`theme set` copies the active theme's `alacritty.toml` to that `theme.toml` and
touches the Windows config so Alacritty reloads. Set `WIN_ALACRITTY` if the
directory is not detected automatically. The original Windows config is backed
up as `alacritty.toml.bak-pre-theme` when this integration is first enabled.

## Repository layout

```text
.
├── bootstrap.sh       # Debian/Ubuntu, Fedora, and Arch provisioning script
├── nvim/              # Neovim configuration and lazy-lock.json
├── zsh/               # Minimal zsh configuration
├── tmux/              # tmux configuration
├── git/               # Shared Git configuration and global ignore rules
├── lazygit/           # lazygit configuration
├── alacritty/         # Alacritty configuration
├── ghostty/           # Ghostty configuration
├── themes/            # Centralized themes for Alacritty, tmux, i3 and Neovim
├── i3/                # i3 window manager configuration
├── i3status/          # i3status bar configuration
└── scripts/           # tmux-sessionizer, theme switcher and clipboard helpers
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
- [ ] Add a `--skip-desktop` flag for headless machines that should not install Alacritty and the i3 stack.
- [ ] Add debug adapters and configurations for C/C++ and Rust (`codelldb` or `gdb`) if those workflows grow.
- [ ] Evaluate Neovim 0.11+ and update pinned plugins when `gitsigns.nvim` and the LSP setup are compatible.
- [ ] Add backup and rollback support for existing configuration files.
- [x] Extend support to Fedora and Arch Linux.
- [ ] Add a local override file for machine-specific settings and secrets.
- [ ] Improve offline/idempotent behavior for toolchain downloads.
