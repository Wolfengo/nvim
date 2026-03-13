#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./install-local.sh [--font] [--clipboard] [--images] [--all]

Options:
  --font       Install Nerd Font for local terminal UI
  --clipboard  Install local clipboard provider
  --images     Install local image preview dependency
  --all        Install all local dependencies above

Run this script on the local machine where your terminal is running.
EOF
}

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

if [[ $# -eq 0 ]]; then
  need_font=true
  need_clipboard=true
  need_images=true
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --font)
      need_font=true
      ;;
    --clipboard)
      need_clipboard=true
      ;;
    --images)
      need_images=true
      ;;
    --all)
      need_font=true
      need_clipboard=true
      need_images=true
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

echo "Local setup done."
