#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./install-local.sh [--base] [--font] [--clipboard] [--images] [--dev-tools] [--nvim-bootstrap] [--all]

Options:
  --base       Install base packages required by this Neovim config
  --font       Install Nerd Font for local terminal UI
  --clipboard  Install local clipboard provider
  --images     Install local image preview dependency
  --dev-tools  Install local tools used by this Neovim config
  --nvim-bootstrap
               Link config, sync plugins, and install Treesitter parsers
  --all        Install all local dependencies above

Run this script on the local machine where your terminal is running.
When run without options, it prepares the full local Neovim setup.
EOF
}

NVIM_LANGUAGES=(
  c
  lua
  vim
  vimdoc
  query
  markdown
  markdown_inline
  python
  tsx
  javascript
  rust
)

NPM_PACKAGES=(
  pyright
  tree-sitter-cli
  typescript
  typescript-language-server
  @prisma/language-server
  vscode-langservers-extracted
  @fsouza/prettierd
)

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
config_dir="${script_dir}"
npm_prefix="${HOME}/.local/share/npm"
npm_bin="${npm_prefix}/bin"

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

detect_package_manager() {
  if has_cmd apt-get; then
    printf '%s' apt
    return
  fi
  if has_cmd pacman; then
    printf '%s' pacman
    return
  fi
  if has_cmd brew; then
    printf '%s' brew
    return
  fi
  printf '%s' ""
}

package_installed() {
  local pkg="$1"
  case "$PKG_MANAGER" in
    apt)
      dpkg -s "$pkg" >/dev/null 2>&1
      ;;
    pacman)
      pacman -Q "$pkg" >/dev/null 2>&1
      ;;
    brew)
      brew list "$pkg" >/dev/null 2>&1
      ;;
    *)
      return 1
      ;;
  esac
}

install_packages() {
  local missing=()
  local pkg
  for pkg in "$@"; do
    if ! package_installed "$pkg"; then
      missing+=("$pkg")
    fi
  done

  if [[ ${#missing[@]} -eq 0 ]]; then
    echo "Local packages already installed"
    return
  fi

  case "$PKG_MANAGER" in
    apt)
      sudo apt-get update
      sudo apt-get install -y "${missing[@]}"
      ;;
    pacman)
      sudo pacman -Sy --needed --noconfirm "${missing[@]}"
      ;;
    brew)
      brew install "${missing[@]}"
      ;;
    *)
      echo "No supported package manager found. Install manually: ${missing[*]}" >&2
      exit 1
      ;;
  esac
}

base_packages() {
  case "$PKG_MANAGER" in
    apt)
      printf '%s\n' stow git curl tar ripgrep nodejs npm python3 build-essential unzip fontconfig
      ;;
    pacman)
      printf '%s\n' stow git curl tar ripgrep nodejs npm python gcc make unzip fontconfig
      ;;
    brew)
      printf '%s\n' stow git curl ripgrep node python
      ;;
    *)
      return 1
      ;;
  esac
}

font_packages() {
  case "$PKG_MANAGER" in
    apt)
      printf '%s\n' unzip fontconfig
      ;;
    pacman)
      printf '%s\n' ttf-jetbrains-mono-nerd
      ;;
    brew)
      printf '%s\n' font-jetbrains-mono-nerd-font
      ;;
    *)
      return 1
      ;;
  esac
}

clipboard_packages() {
  case "$PKG_MANAGER" in
    apt)
      if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
        printf '%s\n' wl-clipboard
      elif [[ -n "${DISPLAY:-}" ]]; then
        printf '%s\n' xclip
      fi
      ;;
    pacman)
      if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
        printf '%s\n' wl-clipboard
      elif [[ -n "${DISPLAY:-}" ]]; then
        printf '%s\n' xclip
      fi
      ;;
    brew)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

image_packages() {
  case "$PKG_MANAGER" in
    apt|pacman|brew)
      printf '%s\n' imagemagick
      ;;
    *)
      return 1
      ;;
  esac
}

dev_tool_packages() {
  case "$PKG_MANAGER" in
    apt)
      printf '%s\n' black mypy
      ;;
    pacman)
      printf '%s\n' python-black mypy stylua tree-sitter-cli
      ;;
    brew)
      printf '%s\n' black mypy stylua tree-sitter
      ;;
    *)
      return 1
      ;;
  esac
}

ensure_config_link() {
  local target="${HOME}/.config/nvim"
  mkdir -p "${HOME}/.config"

  if [[ -e "$target" || -L "$target" ]]; then
    local resolved_target
    local resolved_config
    resolved_target="$(realpath -m "$target")"
    resolved_config="$(realpath -m "$config_dir")"
    if [[ "$resolved_target" == "$resolved_config" ]]; then
      echo "Neovim config already linked: $target"
      return
    fi

    echo "Refusing to replace existing Neovim config: $target -> $resolved_target" >&2
    echo "Move it away manually, then rerun this script." >&2
    exit 1
  fi

  ln -s "$config_dir" "$target"
  echo "Linked Neovim config: $target -> $config_dir"
}

install_npm_if_missing() {
  local packages=("$@")
  local missing=()
  local pkg

  if [[ -d "$npm_bin" ]]; then
    export PATH="${npm_bin}:${PATH}"
  fi

  for pkg in "${packages[@]}"; do
    case "$pkg" in
      pyright)
        has_cmd pyright-langserver || missing+=("$pkg")
        ;;
      typescript)
        has_cmd tsc || missing+=("$pkg")
        ;;
      tree-sitter-cli)
        has_cmd tree-sitter || missing+=("$pkg")
        ;;
      typescript-language-server)
        has_cmd typescript-language-server || missing+=("$pkg")
        ;;
      @prisma/language-server)
        has_cmd prisma-language-server || missing+=("$pkg")
        ;;
      vscode-langservers-extracted)
        has_cmd vscode-css-language-server || missing+=("$pkg")
        ;;
      @fsouza/prettierd)
        has_cmd prettierd || missing+=("$pkg")
        ;;
      *)
        missing+=("$pkg")
        ;;
    esac
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    if ! has_cmd npm; then
      echo "npm is required to install web/LSP tools. Install npm first or run install-remote.sh --base." >&2
      exit 1
    fi
    mkdir -p "$npm_prefix"
    npm config set prefix "$npm_prefix" >/dev/null
    export PATH="${npm_bin}:${PATH}"
    echo "Installing npm packages: ${missing[*]}"
    npm install -g "${missing[@]}"
  else
    echo "Npm packages already installed"
  fi
}

bootstrap_nvim() {
  if ! has_cmd nvim; then
    echo "nvim is not installed or is not in PATH. Install Neovim 0.11+ first or run install-remote.sh --nvim." >&2
    exit 1
  fi

  ensure_config_link

  echo "Syncing Neovim plugins"
  nvim --headless "+Lazy! sync" +qa

  if ! has_cmd tree-sitter; then
    echo "tree-sitter CLI is still missing; skipping Treesitter parser installation." >&2
    echo "Install tree-sitter-cli and rerun: $0 --nvim-bootstrap" >&2
    return
  fi

  echo "Installing Treesitter parsers: ${NVIM_LANGUAGES[*]}"
  local lua_languages=""
  local lang
  for lang in "${NVIM_LANGUAGES[@]}"; do
    lua_languages="${lua_languages}'${lang}',"
  done
  nvim --headless "+lua require('nvim-treesitter').install({ ${lua_languages} }, { force = true, summary = true }):wait(300000)" +qa
}

install_font() {
  case "$PKG_MANAGER" in
    apt)
      mapfile -t packages < <(font_packages)
      install_packages "${packages[@]}"
      local font_dir="${HOME}/.local/share/fonts/JetBrainsMonoNerd"
      mkdir -p "${font_dir}"
      curl -fLo /tmp/JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
      unzip -o /tmp/JetBrainsMono.zip -d "${font_dir}" >/dev/null
      fc-cache -fv >/dev/null
      ;;
    pacman|brew)
      mapfile -t packages < <(font_packages)
      install_packages "${packages[@]}"
      ;;
    *)
      echo "Unsupported package manager for font install" >&2
      exit 1
      ;;
  esac
}

need_font=false
need_clipboard=false
need_images=false
need_dev_tools=false
need_base=false
need_nvim_bootstrap=false

if [[ $# -eq 0 ]]; then
  need_base=true
  need_font=true
  need_clipboard=true
  need_images=true
  need_dev_tools=true
  need_nvim_bootstrap=true
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --base)
      need_base=true
      ;;
    --font)
      need_font=true
      ;;
    --clipboard)
      need_clipboard=true
      ;;
    --images)
      need_images=true
      ;;
    --dev-tools)
      need_dev_tools=true
      ;;
    --nvim-bootstrap)
      need_nvim_bootstrap=true
      ;;
    --all)
      need_base=true
      need_font=true
      need_clipboard=true
      need_images=true
      need_dev_tools=true
      need_nvim_bootstrap=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
  shift
done

PKG_MANAGER="$(detect_package_manager)"

if [[ "$need_base" == true ]]; then
  mapfile -t packages < <(base_packages)
  install_packages "${packages[@]}"
fi

if [[ "$need_font" == true ]]; then
  install_font
fi

if [[ "$need_clipboard" == true ]]; then
  mapfile -t packages < <(clipboard_packages)
  if [[ ${#packages[@]} -gt 0 ]]; then
    install_packages "${packages[@]}"
  else
    echo "No extra clipboard package required for this local environment"
  fi
fi

if [[ "$need_images" == true ]]; then
  mapfile -t packages < <(image_packages)
  install_packages "${packages[@]}"
fi

if [[ "$need_dev_tools" == true ]]; then
  mapfile -t packages < <(dev_tool_packages)
  install_packages "${packages[@]}"
  install_npm_if_missing "${NPM_PACKAGES[@]}"
fi

if [[ "$need_nvim_bootstrap" == true ]]; then
  bootstrap_nvim
fi

echo "Local setup done."
