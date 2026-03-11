#!/usr/bin/env bash
set -euo pipefail

BASE_PACKAGES=(
  git
  curl
  tar
  ripgrep
  xclip
  wl-clipboard
)

PYTHON_PACKAGES=(
  mypy
  black
)

NPM_PACKAGES=(
  pyright
  typescript
  typescript-language-server
  @prisma/language-server
  vscode-langservers-extracted
  @fsouza/prettierd
)

usage() {
  cat <<'EOF'
Usage:
  ./install.sh [--base] [--python] [--web] [--all]

Options:
  --base     Install system base dependencies
  --python   Install Python diagnostics / formatting tools
  --web      Install npm-based LSP / formatter tools
  --all      Install everything above

The script is safe to rerun:
it checks what is already installed and only installs missing parts.
EOF
}

need_base=false
need_python=false
need_web=false

if [[ $# -eq 0 ]]; then
  need_base=true
  need_python=true
  need_web=true
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
    --all)
      need_base=true
      need_python=true
      need_web=true
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

apt_installed() {
  dpkg -s "$1" >/dev/null 2>&1
}

install_apt_if_missing() {
  local missing=()
  for pkg in "$@"; do
    if ! apt_installed "$pkg"; then
      missing+=("$pkg")
    fi
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "Installing apt packages: ${missing[*]}"
    sudo apt-get update
    sudo apt-get install -y "${missing[@]}"
  else
    echo "Apt packages already installed: $*"
  fi
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

if [[ "$need_base" == true ]]; then
  install_apt_if_missing "${BASE_PACKAGES[@]}"
fi

if [[ "$need_python" == true ]]; then
  install_apt_if_missing "${PYTHON_PACKAGES[@]}"
fi

if [[ "$need_web" == true ]]; then
  if ! has_cmd npm; then
    echo "npm is required for web tool installation" >&2
    exit 1
  fi
  install_npm_if_missing "${NPM_PACKAGES[@]}"
fi

echo "Done."
