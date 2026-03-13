#!/usr/bin/env bash
set -euo pipefail

NVIM_VERSION="0.11.5"
NPM_PACKAGES=(
  pyright
  tree-sitter-cli
  typescript
  typescript-language-server
  @prisma/language-server
  vscode-langservers-extracted
  @fsouza/prettierd
)

usage() {
  cat <<'EOF'
Usage:
  ./install-remote.sh [--base] [--python] [--web] [--images] [--nvim] [--all]

Options:
  --base     Install system base dependencies
  --python   Install Python diagnostics / formatting tools
  --web      Install npm-based LSP / formatter tools
  --images   Install optional image preview dependencies
  --nvim     Install Neovim 0.11.x from official release
  --all      Install everything above

The script is safe to rerun:
it checks what is already installed and only installs missing parts.
EOF
}

OS="$(uname -s)"
PKG_MANAGER=""

need_base=false
need_python=false
need_web=false
need_images=false
need_nvim=false

if [[ $# -eq 0 ]]; then
  need_base=true
  need_python=true
  need_web=true
  need_nvim=true
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
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
    --all)
      need_base=true
      need_python=true
      need_web=true
      need_images=true
      need_nvim=true
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
      printf '%s\n' git curl tar ripgrep xclip wl-clipboard nodejs npm python3 build-essential
      ;;
    pacman)
      printf '%s\n' git curl tar ripgrep xclip wl-clipboard nodejs npm python gcc make
      ;;
    brew)
      printf '%s\n' git curl ripgrep node python
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
    apt|pacman|brew)
      printf '%s\n' mypy black
      ;;
    *)
      return 1
      ;;
  esac
}

install_npm_if_missing() {
  local packages=("$@")
  local missing=()

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
    echo "Installing npm packages: ${missing[*]}"
    npm install -g "${missing[@]}"
  else
    echo "Npm packages already installed"
  fi
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
  if ! has_cmd npm; then
    echo "npm is required for web tool installation" >&2
    exit 1
  fi
  install_npm_if_missing "${NPM_PACKAGES[@]}"
fi

if [[ "$need_images" == true ]]; then
  mapfile -t packages < <(image_packages)
  install_system_packages "${packages[@]}"
fi

if [[ "$need_nvim" == true ]]; then
  install_nvim_release
fi

echo "Done."
