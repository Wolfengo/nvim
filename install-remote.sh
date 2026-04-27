#!/usr/bin/env bash
set -euo pipefail

NVIM_VERSION="0.11.5"
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

package_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
package_name="$(basename "$package_dir")"
default_stow_root="$(dirname "$package_dir")"
recommended_package_dir="${HOME}/.dotfiles/nvim"
npm_prefix="${HOME}/.local/share/npm"
npm_bin="${npm_prefix}/bin"
stow_root=""

usage() {
  cat <<'EOF'
Usage:
  ./install-remote.sh [--stow-root PATH] [--base] [--python] [--web] [--images] [--nvim] [--nvim-bootstrap] [--all]

Options:
  --stow-root PATH
             Dotfiles root that contains the nvim package
  --base     Install system base dependencies
  --python   Install Python diagnostics / formatting tools
  --web      Install npm-based LSP / formatter tools
  --images   Install optional image preview dependencies
  --nvim     Install Neovim 0.11.x from official release
  --nvim-bootstrap
             Link config with stow, sync plugins, and install Treesitter parsers
  --all      Install everything above

The script is safe to rerun:
it checks what is already installed and only installs missing parts.
When run without options, it prepares a remote/SSH Neovim setup.
EOF
}

OS="$(uname -s)"
PKG_MANAGER=""

need_base=false
need_python=false
need_web=false
need_images=false
need_nvim=false
need_nvim_bootstrap=false

if [[ $# -eq 0 ]]; then
  need_base=true
  need_python=true
  need_web=true
  need_nvim=true
  need_nvim_bootstrap=true
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --stow-root)
      if [[ $# -lt 2 ]]; then
        echo "--stow-root requires a path" >&2
        exit 1
      fi
      stow_root="$2"
      shift
      ;;
    --base)
      need_base=true
      ;;
    --python)
      need_python=true
      ;;
    --web)
      need_web=true
      ;;
    --images)
      need_images=true
      ;;
    --nvim)
      need_nvim=true
      ;;
    --nvim-bootstrap)
      need_nvim_bootstrap=true
      ;;
    --all)
      need_base=true
      need_python=true
      need_web=true
      need_images=true
      need_nvim=true
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

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

detect_package_manager() {
  if has_cmd apt-get; then
    PKG_MANAGER="apt"
  elif has_cmd pacman; then
    PKG_MANAGER="pacman"
  elif has_cmd brew; then
    PKG_MANAGER="brew"
  else
    PKG_MANAGER=""
  fi
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
      brew list --formula "$pkg" >/dev/null 2>&1
      ;;
    *)
      return 1
      ;;
  esac
}

install_system_packages() {
  local missing=()
  for pkg in "$@"; do
    [[ -z "$pkg" ]] && continue
    if ! package_installed "$pkg"; then
      missing+=("$pkg")
    fi
  done

  if [[ ${#missing[@]} -eq 0 ]]; then
    echo "System packages already installed"
    return
  fi

  case "$PKG_MANAGER" in
    apt)
      echo "Installing apt packages: ${missing[*]}"
      sudo apt-get update
      sudo apt-get install -y "${missing[@]}"
      ;;
    pacman)
      echo "Installing pacman packages: ${missing[*]}"
      sudo pacman -Sy --needed --noconfirm "${missing[@]}"
      ;;
    brew)
      echo "Installing brew packages: ${missing[*]}"
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
      printf '%s\n' stow git curl tar ripgrep nodejs npm python3 build-essential
      ;;
    pacman)
      printf '%s\n' stow git curl tar ripgrep nodejs npm python gcc make
      ;;
    brew)
      printf '%s\n' stow git curl ripgrep node python
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

python_packages() {
  case "$PKG_MANAGER" in
    apt|brew)
      printf '%s\n' mypy black
      ;;
    pacman)
      printf '%s\n' mypy python-black stylua tree-sitter-cli
      ;;
    *)
      return 1
      ;;
  esac
}

install_npm_if_missing() {
  local packages=("$@")
  local missing=()

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
    esac
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    if ! has_cmd npm; then
      echo "npm is required for web tool installation" >&2
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

ensure_config_link() {
  if ! has_cmd stow; then
    echo "stow is required to link this package. Run $0 --base first." >&2
    exit 1
  fi

  local root="${stow_root:-$default_stow_root}"
  root="$(realpath -m "$root")"

  if [[ "$package_name" != "nvim" || "$(realpath -m "$root/$package_name")" != "$(realpath -m "$package_dir")" ]]; then
    echo "This package is currently at: $package_dir" >&2
    echo "Recommended location: $recommended_package_dir" >&2
    echo "Move it there or rerun with an explicit --stow-root PATH that contains this nvim package." >&2
    exit 1
  fi

  if [[ "$(realpath -m "$package_dir")" != "$(realpath -m "$recommended_package_dir")" ]]; then
    echo "This package is not in the recommended location."
    echo "Current location: $package_dir"
    echo "Recommended location: $recommended_package_dir"
    if [[ -z "$stow_root" ]]; then
      if [[ -t 0 && -t 1 ]]; then
        read -r -p "Use current parent as stow root anyway? [y/N] " answer
        case "$answer" in
          y|Y|yes|YES)
            ;;
          *)
            echo "Aborted. Move the package or rerun with --stow-root PATH." >&2
            exit 1
            ;;
        esac
      else
        echo "Non-interactive run requires --stow-root PATH for non-standard locations." >&2
        exit 1
      fi
    fi
  fi

  mkdir -p "${HOME}/.config"
  echo "Linking Neovim config with stow: stow --dir $root --target ${HOME} $package_name"
  stow --dir "$root" --target "$HOME" "$package_name"
}

bootstrap_nvim() {
  if ! has_cmd nvim; then
    echo "nvim is not installed or is not in PATH. Run $0 --nvim first." >&2
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

version_ge() {
  [[ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | tail -n1)" == "$1" ]]
}

install_nvim_release() {
  local current_version=""

  if has_cmd nvim; then
    current_version="$(nvim --version | sed -n '1s/^NVIM v//p')"
  fi

  if [[ -n "$current_version" ]] && version_ge "$current_version" "0.11.0"; then
    echo "Neovim is already new enough: $current_version"
    return
  fi

  if [[ "$OS" == "Darwin" ]]; then
    if [[ "$PKG_MANAGER" != "brew" ]]; then
      echo "On macOS, brew is required to install Neovim automatically." >&2
      exit 1
    fi
    echo "Installing Neovim via Homebrew"
    brew install neovim || brew upgrade neovim
    return
  fi

  if [[ "$OS" != "Linux" ]]; then
    echo "Unsupported OS for automatic Neovim install: $OS" >&2
    exit 1
  fi

  local arch
  case "$(uname -m)" in
    x86_64|amd64)
      arch="x86_64"
      ;;
    aarch64|arm64)
      arch="arm64"
      ;;
    *)
      echo "Unsupported Linux architecture: $(uname -m)" >&2
      exit 1
      ;;
  esac

  local archive="nvim-linux-${arch}.tar.gz"
  echo "Installing Neovim $NVIM_VERSION from official release"
  curl -L "https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/${archive}" -o "/tmp/${archive}"
  sudo rm -rf "/opt/nvim-${NVIM_VERSION}"
  sudo mkdir -p "/opt/nvim-${NVIM_VERSION}"
  sudo tar -xzf "/tmp/${archive}" -C "/opt/nvim-${NVIM_VERSION}" --strip-components=1
  sudo ln -sf "/opt/nvim-${NVIM_VERSION}/bin/nvim" /usr/local/bin/nvim
}

detect_package_manager

if [[ "$need_base" == true ]]; then
  mapfile -t packages < <(base_packages)
  install_system_packages "${packages[@]}"
fi

if [[ "$need_python" == true ]]; then
  mapfile -t packages < <(python_packages)
  install_system_packages "${packages[@]}"
fi

if [[ "$need_web" == true ]]; then
  install_npm_if_missing "${NPM_PACKAGES[@]}"
fi

if [[ "$need_images" == true ]]; then
  mapfile -t packages < <(image_packages)
  install_system_packages "${packages[@]}"
fi

if [[ "$need_nvim" == true ]]; then
  install_nvim_release
fi

if [[ "$need_nvim_bootstrap" == true ]]; then
  bootstrap_nvim
fi

echo "Done."
