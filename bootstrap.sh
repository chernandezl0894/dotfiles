#!/usr/bin/env bash
#
# Bootstrap a Debian/Ubuntu, Fedora, or Arch Linux machine for this dotfiles repo.
#
# Installs the OS packages, language toolchains, Neovim, tmux, and the
# Mason-managed LSPs/formatters/debug adapters used by the Neovim config.
#
# Usage:
#   ./bootstrap.sh [options]
#
# Options:
#   --skip-mason          Do not install Mason packages
#   --skip-dotfiles       Do not link dotfiles (assume config is already linked)
#   --skip-tmux-plugins   Do not install TPM plugins
#   --nvim-version VER    Neovim version to install (default: 0.10.4)
#   --dry-run             Print what would be done without changing anything
#   -h, --help            Show this help
#
# Environment overrides:
#   NVIM_VERSION, GO_VERSION, ZIG_VERSION, ODIN_TAG
#
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

NVIM_VERSION="${NVIM_VERSION:-0.10.4}"
ZIG_VERSION="${ZIG_VERSION:-0.16.0}"
GO_VERSION="${GO_VERSION:-}"
ODIN_TAG="${ODIN_TAG:-}"

SKIP_MASON=0
SKIP_DOTFILES=0
SKIP_TMUX_PLUGINS=0
DRY_RUN=0

BIN_DIR="$HOME/.local/bin"
OPT_DIR="$HOME/.local/opt"
CARGO_BIN="$HOME/.cargo/bin"
MASON_DIR="$HOME/.local/share/nvim/mason"

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-bootstrap.XXXXXX")"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

log() {
  printf '\033[1;34m==>\033[0m %s\n' "$*"
}

warn() {
  printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2
}

die() {
  printf '\033[1;31merror:\033[0m %s\n' "$*" >&2
  exit 1
}

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '  [dry-run]'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

usage() {
  sed -n '2,21p' "$0" | sed 's/^# \{0,1\}//'
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --skip-mason)
      SKIP_MASON=1
      ;;
    --skip-dotfiles)
      SKIP_DOTFILES=1
      ;;
    --skip-tmux-plugins)
      SKIP_TMUX_PLUGINS=1
      ;;
    --nvim-version)
      [ "$#" -ge 2 ] || die "--nvim-version requires a value"
      NVIM_VERSION="$2"
      shift
      ;;
    --nvim-version=*)
      NVIM_VERSION="${1#*=}"
      ;;
    --dry-run)
      DRY_RUN=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown option: $1 (try --help)"
      ;;
  esac
  shift
done

NVIM_VERSION="${NVIM_VERSION#v}"
[ -n "$NVIM_VERSION" ] || die "NVIM_VERSION cannot be empty"

# ---------------------------------------------------------------------------
# Preflight
# ---------------------------------------------------------------------------

if [ ! -r /etc/os-release ]; then
  die "Cannot read /etc/os-release; cannot detect the distribution."
fi

# shellcheck disable=SC1091
. /etc/os-release

# Map the distribution to the package manager family used throughout the script.
case " ${ID:-} ${ID_LIKE:-} " in
  *" debian "*|*" ubuntu "*)
    DISTRO_FAMILY=debian
    ;;
  *" fedora "*|*" rhel "*)
    DISTRO_FAMILY=fedora
    ;;
  *" arch "*)
    DISTRO_FAMILY=arch
    ;;
  *)
    die "Unsupported distribution: ${PRETTY_NAME:-unknown}. Debian/Ubuntu, Fedora, or Arch Linux required."
    ;;
esac

case "$(uname -m)" in
  x86_64|amd64)
    ODIN_ARCH="amd64"
    NVIM_ARCH="x86_64"
    ZIG_ARCH="x86_64"
    GO_ARCH="amd64"
    ;;
  aarch64|arm64)
    ODIN_ARCH="arm64"
    NVIM_ARCH="arm64"
    ZIG_ARCH="aarch64"
    GO_ARCH="arm64"
    ;;
  *)
    die "Unsupported architecture: $(uname -m)"
    ;;
esac

SUDO=()
if [ "$(id -u)" -eq 0 ]; then
  :
elif command -v sudo >/dev/null 2>&1; then
  SUDO=(sudo)
else
  die "sudo is required to install OS packages."
fi

if [ "$DRY_RUN" -eq 0 ] && [ "${#SUDO[@]}" -gt 0 ]; then
  log "Requesting sudo access"
  sudo -v
fi

if [ "$DRY_RUN" -eq 0 ]; then
  mkdir -p "$BIN_DIR" "$OPT_DIR" "$HOME/.tmux/plugins"
fi

export PATH="$BIN_DIR:$CARGO_BIN:$HOME/go/bin:$PATH"
hash -r

# ---------------------------------------------------------------------------
# OS packages
# ---------------------------------------------------------------------------

install_os_packages() {
  # PHP is intentionally excluded; it is handled in a different editor.
  case "$DISTRO_FAMILY" in
    debian)
      log "Installing OS packages (apt)"
      run "${SUDO[@]}" apt-get update
      run "${SUDO[@]}" env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        git curl wget ca-certificates gnupg lsb-release \
        unzip zip tar xz-utils \
        build-essential cmake pkg-config make \
        clang lld gdb \
        ripgrep fd-find \
        python3 python3-pip python3-venv \
        tmux xclip wl-clipboard openssh-client less

      # Debian/Ubuntu install fd as "fdfind".
      if [ -x /usr/bin/fdfind ]; then
        run ln -sf /usr/bin/fdfind "$BIN_DIR/fd"
      fi
      ;;
    fedora)
      log "Installing OS packages (dnf)"
      run "${SUDO[@]}" dnf install -y \
        git curl wget ca-certificates gnupg2 \
        unzip zip tar xz \
        gcc gcc-c++ make cmake pkgconf-pkg-config \
        clang lld gdb \
        ripgrep fd-find \
        python3 python3-pip \
        tmux xclip wl-clipboard openssh-clients less
      ;;
    arch)
      # No -Sy to avoid partial upgrades; refresh the database with -Syu yourself
      # if the mirrors are stale.
      log "Installing OS packages (pacman)"
      run "${SUDO[@]}" pacman -S --needed --noconfirm \
        git curl wget ca-certificates gnupg \
        unzip zip tar xz \
        gcc make cmake pkgconf \
        clang lld gdb \
        ripgrep fd \
        python python-pip \
        tmux xclip wl-clipboard openssh less
      ;;
  esac
}

install_node_nodesource() {
  local family="$1"
  local setup_url
  local install_cmd

  case "$family" in
    debian)
      setup_url="https://deb.nodesource.com/setup_22.x"
      install_cmd=(apt-get install -y --no-install-recommends nodejs)
      ;;
    fedora)
      setup_url="https://rpm.nodesource.com/setup_22.x"
      install_cmd=(dnf install -y nodejs)
      ;;
    *)
      die "NodeSource fallback is only supported on Debian and Fedora"
      ;;
  esac

  log "Installing Node.js 22 from NodeSource"
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '  [dry-run] curl -fsSL %s -o %s/node-setup.sh\n' "$setup_url" "$TMP_DIR"
    printf '  [dry-run]'
    printf ' %q' "${SUDO[@]}" -E bash "$TMP_DIR/node-setup.sh"
    printf '\n'
    printf '  [dry-run]'
    printf ' %q' "${SUDO[@]}" "${install_cmd[@]}"
    printf '\n'
    return
  fi

  curl -fsSL "$setup_url" -o "$TMP_DIR/node-setup.sh"
  "${SUDO[@]}" -E bash "$TMP_DIR/node-setup.sh"
  "${SUDO[@]}" "${install_cmd[@]}"
}

node_major_version() {
  command -v node >/dev/null 2>&1 || return 0
  node -v 2>/dev/null | sed 's/^v//' | cut -d. -f1
}

install_node() {
  local major
  major="$(node_major_version)"

  if [ "$major" -ge 18 ] 2>/dev/null && command -v npm >/dev/null 2>&1; then
    log "Node.js $(node -v) already installed"
    return
  fi

  case "$DISTRO_FAMILY" in
    debian)
      # Debian/Ubuntu repositories often ship an outdated Node.js.
      install_node_nodesource debian
      ;;
    fedora)
      log "Installing Node.js from the Fedora repositories"
      run "${SUDO[@]}" dnf install -y nodejs npm

      # Fall back to NodeSource if the distribution shipped an old Node.js.
      if [ "$DRY_RUN" -eq 0 ]; then
        major="$(node_major_version)"
        if [ -z "$major" ] || ! [ "$major" -ge 18 ] 2>/dev/null; then
          install_node_nodesource fedora
        fi
      fi
      ;;
    arch)
      log "Installing Node.js from the Arch repositories"
      run "${SUDO[@]}" pacman -S --needed --noconfirm nodejs npm
      ;;
  esac
}

# ---------------------------------------------------------------------------
# Language toolchains
# ---------------------------------------------------------------------------

install_go() {
  if [ -z "$GO_VERSION" ]; then
    GO_VERSION="$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -n1)"
  fi
  case "$GO_VERSION" in
    go*) ;;
    *) GO_VERSION="go$GO_VERSION" ;;
  esac

  local dest="$OPT_DIR/$GO_VERSION"
  if [ -x "$dest/bin/go" ] && "$dest/bin/go" version 2>/dev/null | grep -q " $GO_VERSION "; then
    log "Go $GO_VERSION already installed"
  else
    log "Installing Go $GO_VERSION"
    local archive="$GO_VERSION.linux-$GO_ARCH.tar.gz"
    run curl -fL "https://go.dev/dl/$archive" -o "$TMP_DIR/$archive"
    if [ "$DRY_RUN" -eq 0 ]; then
      rm -rf "$dest"
      mkdir -p "$dest"
      tar -xzf "$TMP_DIR/$archive" -C "$dest" --strip-components=1
    fi
  fi

  run ln -sf "$dest/bin/go" "$BIN_DIR/go"
  run ln -sf "$dest/bin/gofmt" "$BIN_DIR/gofmt"
}

install_rust() {
  local rustup="$CARGO_BIN/rustup"

  if [ ! -x "$rustup" ]; then
    log "Installing Rust via rustup"
    if [ "$DRY_RUN" -eq 1 ]; then
      printf '  [dry-run] curl -fsSL https://sh.rustup.rs | sh -s -- -y --profile minimal --component rustfmt --component clippy\n'
    else
      curl -fsSL https://sh.rustup.rs |
        sh -s -- -y --profile minimal --component rustfmt --component clippy
    fi
  else
    log "Rustup already installed"
    run "$rustup" component add rustfmt clippy
  fi

  # rustup writes to ~/.cargo/bin; expose its shims through ~/.local/bin too.
  local bin
  for bin in cargo rustc rustfmt cargo-clippy clippy-driver; do
    if [ -x "$CARGO_BIN/$bin" ]; then
      run ln -sf "$CARGO_BIN/$bin" "$BIN_DIR/$bin"
    fi
  done
}

install_zig() {
  local dest="$OPT_DIR/zig-$ZIG_VERSION"
  if [ -x "$dest/zig" ] && "$dest/zig" version 2>/dev/null | grep -qx "$ZIG_VERSION"; then
    log "Zig $ZIG_VERSION already installed"
  else
    log "Installing Zig $ZIG_VERSION"
    local archive="zig-$ZIG_ARCH-linux-$ZIG_VERSION.tar.xz"
    local url="https://ziglang.org/download/$ZIG_VERSION/$archive"

    run curl -fL "$url" -o "$TMP_DIR/$archive"
    if [ "$DRY_RUN" -eq 0 ]; then
      rm -rf "$dest"
      mkdir -p "$dest"
      tar -xJf "$TMP_DIR/$archive" -C "$dest" --strip-components=1
    fi
  fi

  run ln -sf "$dest/zig" "$BIN_DIR/zig"
}

install_odin() {
  if [ -z "$ODIN_TAG" ]; then
    ODIN_TAG="$(curl -fsSL https://api.github.com/repos/odin-lang/Odin/releases/latest |
      python3 -c 'import json, sys; print(json.load(sys.stdin)["tag_name"])')"
  fi
  [ -n "$ODIN_TAG" ] || die "Could not determine the latest Odin release tag."

  local dest="$OPT_DIR/odin-$ODIN_TAG"
  if [ -x "$dest/odin" ]; then
    log "Odin $ODIN_TAG already installed"
  else
    log "Installing Odin $ODIN_TAG"
    local archive="odin-linux-$ODIN_ARCH-$ODIN_TAG.tar.gz"
    local url="https://github.com/odin-lang/Odin/releases/download/$ODIN_TAG/$archive"

    run curl -fL "$url" -o "$TMP_DIR/$archive"
    if [ "$DRY_RUN" -eq 0 ]; then
      rm -rf "$dest"
      mkdir -p "$dest"
      tar -xzf "$TMP_DIR/$archive" -C "$dest" --strip-components=1
    fi
  fi

  run ln -sf "$dest/odin" "$BIN_DIR/odin"
}

# ---------------------------------------------------------------------------
# Neovim
# ---------------------------------------------------------------------------

install_neovim() {
  local dest="$OPT_DIR/nvim-$NVIM_VERSION"
  local archive="nvim-linux-$NVIM_ARCH.tar.gz"
  local url="https://github.com/neovim/neovim/releases/download/v$NVIM_VERSION/$archive"

  if [ -x "$dest/bin/nvim" ] && "$dest/bin/nvim" --version 2>/dev/null | head -n1 | grep -q "v$NVIM_VERSION"; then
    log "Neovim $NVIM_VERSION already installed"
  else
    log "Installing Neovim $NVIM_VERSION (tarball, no FUSE dependency)"
    run curl -fL "$url" -o "$TMP_DIR/$archive"
    run curl -fL "$url.sha256sum" -o "$TMP_DIR/$archive.sha256sum"
    if [ "$DRY_RUN" -eq 0 ]; then
      (cd "$TMP_DIR" && sha256sum -c "$archive.sha256sum")
      rm -rf "$dest"
      mkdir -p "$dest"
      tar -xzf "$TMP_DIR/$archive" -C "$dest" --strip-components=1
    fi
  fi

  run ln -sf "$dest/bin/nvim" "$BIN_DIR/nvim"
  hash -r
}

# ---------------------------------------------------------------------------
# Dotfiles and tmux plugins
# ---------------------------------------------------------------------------

# Each managed path mirrors the repository layout under ~/.config, e.g.
# tmux/tmux.conf -> ~/.config/tmux/tmux.conf.
link_file() {
  local source_file="$1"
  local target_file="$2"

  run mkdir -p "$(dirname "$target_file")"
  if [ -e "$target_file" ] || [ -L "$target_file" ]; then
    run rm -rf "$target_file"
  fi
  run ln -sfn "$source_file" "$target_file"
}

link_dotfiles() {
  if [ "$SKIP_DOTFILES" -eq 1 ]; then
    log "Skipping dotfile symlinks (--skip-dotfiles)"
    return
  fi

  log "Linking dotfiles"
  local relative
  for relative in \
    tmux/tmux.conf \
    nvim \
    alacritty/alacritty.toml \
    alacritty/themes/catppuccin-frappe.toml \
    alacritty/themes/catppuccin-mocha.toml \
    alacritty/themes/catppuccin-latte.toml \
    alacritty/themes/dreamsof.toml \
    alacritty/themes/sweetie_light.toml \
    alacritty/themes/sweetie_dark.toml \
    i3/config \
    i3status/config; do
    link_file "$DOTFILES_DIR/$relative" "$HOME/.config/$relative"
  done
}

install_tmux_plugins() {
  local tpm="$HOME/.tmux/plugins/tpm"

  if [ "$SKIP_TMUX_PLUGINS" -eq 1 ]; then
    log "Skipping TPM plugin installation (--skip-tmux-plugins)"
    return
  fi

  if [ ! -d "$tpm/.git" ]; then
    log "Installing tmux plugin manager"
    run git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm"
  else
    log "tmux plugin manager already installed"
  fi

  if [ -x "$tpm/bin/install_plugins" ]; then
    log "Installing tmux plugins"
    run "$tpm/bin/install_plugins"
  else
    warn "TPM install_plugins not found; run prefix + I inside tmux later."
  fi
}

# ---------------------------------------------------------------------------
# Neovim plugins and Mason packages
# ---------------------------------------------------------------------------

install_lazy_plugins() {
  if [ ! -f "$HOME/.config/nvim/init.lua" ]; then
    warn "Neovim config not found at ~/.config/nvim; skipping plugin installation."
    return
  fi

  log "Installing Neovim plugins"
  run "$BIN_DIR/nvim" --headless "+Lazy! install" +qa
}

install_mason_packages() {
  if [ "$SKIP_MASON" -eq 1 ]; then
    log "Skipping Mason packages (--skip-mason)"
    return
  fi

  [ -f "$HOME/.config/nvim/init.lua" ] ||
    die "Neovim config not found at ~/.config/nvim; run without --skip-dotfiles first."

  if [ "$DRY_RUN" -eq 0 ] && pgrep -x nvim >/dev/null 2>&1; then
    warn "Neovim is running; Mason installation may conflict with it."
  fi

  # A previous aborted headless run can leave a stale lock behind. Only clean
  # locks when no other Neovim process can be using them.
  if [ "$DRY_RUN" -eq 0 ] && ! pgrep -x nvim >/dev/null 2>&1 && [ -d "$MASON_DIR/staging" ]; then
    find "$MASON_DIR/staging" -maxdepth 1 -name '*.lock' -delete 2>/dev/null || true
  fi

  local lua_file="$TMP_DIR/mason-install.lua"
  cat >"$lua_file" <<'LUA'
local packages = {
  -- LSPs
  "lua-language-server",
  "html-lsp",
  "css-lsp",
  "tailwindcss-language-server",
  "emmet-ls",
  "pyright",
  "ruff",
  "zls",
  "ols",
  "clangd",
  "gopls",
  "rust-analyzer",
  "typescript-language-server",
  -- Formatters and linters
  "prettier",
  "goimports",
  "clang-format",
  "stylua",
  "eslint_d",
  "stylelint",
  -- Debug adapters
  "debugpy",
}

local ok, registry = pcall(require, "mason-registry")
if not ok then
  io.stderr:write("mason-registry is not available: " .. tostring(registry) .. "\n")
  vim.cmd("cquit 1")
end

local function get(name)
  local found, package = pcall(registry.get_package, name)
  if not found then
    return nil
  end
  return package
end

-- On a cold install the registry is fetched asynchronously by mason-lspconfig.
local function registry_ready()
  for _, name in ipairs(packages) do
    if not get(name) then
      return false
    end
  end
  return true
end
if not vim.wait(60 * 1000, registry_ready, 500) then
  local unknown = {}
  for _, name in ipairs(packages) do
    if not get(name) then
      table.insert(unknown, name)
    end
  end
  io.stderr:write("Unknown Mason packages (is the registry ready?): " .. table.concat(unknown, ", ") .. "\n")
  vim.cmd("cquit 1")
end

local function all_installed()
  for _, name in ipairs(packages) do
    local package = get(name)
    if not package or not package:is_installed() then
      return false
    end
  end
  return true
end

local function report_missing()
  local missing = {}
  for _, name in ipairs(packages) do
    local package = get(name)
    if not package then
      table.insert(missing, name .. " (not in registry)")
    elseif not package:is_installed() then
      table.insert(missing, name .. (package:is_installing() and " (installing)" or " (not installed)"))
    end
  end
  if #missing > 0 then
    io.stderr:write("Mason packages not installed:\n  " .. table.concat(missing, "\n  ") .. "\n")
  end
end

-- Trigger any package the config did not already start installing.
for _, name in ipairs(packages) do
  local package = get(name)
  if package and not package:is_installed() and not package:is_installing() then
    pcall(function()
      package:install()
    end)
  end
end

-- 30 minutes is generous for a cold install over a slow connection.
local done = vim.wait(30 * 60 * 1000, all_installed, 1000)
if not done then
  report_missing()
  vim.cmd("cquit 1")
end

print("All Mason packages are installed.")
LUA

  log "Installing Mason packages (this can take a while)"
  run "$BIN_DIR/nvim" --headless -c "luafile $lua_file" -c "qa!"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

log "Detected ${PRETTY_NAME:-unknown} (family: $DISTRO_FAMILY, arch: $ODIN_ARCH)"

install_os_packages
install_node
install_neovim
install_go
install_rust
install_zig
install_odin

link_dotfiles
install_tmux_plugins

install_lazy_plugins
install_mason_packages

log "Bootstrap complete"
hash -r
if [ "$DRY_RUN" -eq 0 ] && [ "$(command -v nvim 2>/dev/null)" != "$BIN_DIR/nvim" ]; then
  warn "nvim resolves to $(command -v nvim 2>/dev/null || echo 'nothing'); put $BIN_DIR before other PATH entries."
fi
printf '\nInstalled versions:\n'
for bin in nvim go rustc cargo zig odin tmux node; do
  if command -v "$bin" >/dev/null 2>&1; then
    case "$bin" in
      nvim) printf '  %-8s %s\n' "$bin" "$("$bin" --version 2>/dev/null | head -n1)" ;;
      go) printf '  %-8s %s\n' "$bin" "$("$bin" version 2>/dev/null)" ;;
      rustc|cargo) printf '  %-8s %s\n' "$bin" "$("$bin" --version 2>/dev/null)" ;;
      zig) printf '  %-8s %s\n' "$bin" "$("$bin" version 2>/dev/null)" ;;
      odin) printf '  %-8s %s\n' "$bin" "$("$bin" version 2>/dev/null | head -n1)" ;;
      tmux|node) printf '  %-8s %s\n' "$bin" "$("$bin" -V 2>/dev/null || "$bin" --version 2>/dev/null)" ;;
    esac
  fi
done
printf '\nMake sure %s is in your PATH (it usually already is).\n' "$BIN_DIR"
