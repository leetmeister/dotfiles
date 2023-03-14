#!/usr/bin/env bash
# See https://betterdev.blog/minimal-safe-bash-script-template/ for recommendations
set -eu

SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}")
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat << EOF
Usage: ${SCRIPT_NAME} [OPTIONS]

Script description here.

Available options:
--no-deps       Do not install apt dependencies needed by components in this script
--no-zsh        Do not install ZSH as the default shell or apply the dotfiles/.zshrc
--no-starship   Do not install Starship as the prompt or apply the dotfiles/.starship/starship.toml
--no-gcm        Do not install Git Credential Manager as Git credential helper
-h, --help      Print this help and exit
-v, --verbose   Print script debug info

EOF
  exit
}

setup_colors() {
  if [[ -t 2 ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

parse_params() {
  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    --no-deps) NO_DEPS=1 ;;
    --no-gcm) NO_GCM=1 ;;
    --no-starship) NO_STARSHIP=1 ;;
    --no-zsh) NO_ZSH=1 ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  return 0
}

parse_params "$@"
setup_colors

# Validate permissions needed to perform installs
if [[ -n ${NO_DEP} && -n ${NO_GCM} && ${NO_STARSHIP} && -n ${NO_ZSH} ]]; then
  msg "${BLUE}[INFO]${NOFORMAT}: All install actions skipped, only applying .gitconfig"
elif [[ "$EUID" != 0 ]]; then
  die "${RED}[ERROR]${NOFORMAT}: ${SCRIPT_NAME} needs to be run as root or under 'sudo' to perfom installs"
fi

# The presence of /proc/sys/fs/binfmt_misc/WSLInterop file or /run/WSL directory suggests the Linux instance is running under WSL
if [[ -e "/proc/sys/fs/binfmt_misc/WSLInterop" || -d "/run/WSL" ]]; then
  echo "Detected that script is running under WSL ..."
  IS_WSL=1
fi

# Apply dotfiles/.gitconfig
ln -nfs "${SCRIPT_DIR}/.gitconfig" "$HOME/.gitconfig"

# Install prerequisite packages
if [[ -z ${NO_DEPS} ]]; then
  DEPS="curl ln git"
  if [[ -z ${NO_GCM} ]]; then
    DEPS="${DEPS} jq libicu70"
  fi
  echo "Installing required apt packages: ${DEPS} ..."
  apt update
  apt install "${DEPS}"
else
  echo "--no-deps specified, assume that required depencies are already installed: ${DEPS}"
fi

# Install and configure ZSH
if [[ -z "$NO_ZSH" ]]; then
  echo "Installing ZSH as default shell ..."
  apt install zsh
  chsh -s "$(which zsh)"

  echo "Cloning zsh-autosuggestions plugin from GitHub ..."
  git clone https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.zsh_plugins/zsh-autosuggestions"

  echo "Cloning zsh-syntax-highlighting plugin from GitHub ..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.zsh_plugins/zsh-syntax-highlighting"

  echo "Linking dotfiles/.zshrc to local home ..."
  ln -nfs "${SCRIPT_DIR}/.zshrc" "$HOME/.zshrc"
else
  echo "--no-zsh specified, not applying dotfiles/.zshrc"
fi

# Install and configure Starship
if [[ -z "$NO_STARSHIP" ]]; then
  echo "Installing Starship prompt ..."
  curl -SsL https://starship.rs/install.sh | sh

  echo "Linking dotfiles/.starship/starship.toml to local home ..."
  ln -nfs "${SCRIPT_DIR}/.starship/starship.toml" "$HOME/.starship/starship.toml"

  if [[ -n "$IS_WSL" ]]; then
    msg "${YELLOW}[WARN]${NOFORMAT}: Ensure that Windows has Starship installed for handling git_status in WSL ..."
    starship config git_status.windows_starship '/mnt/c/Program Files/Starship/bin/starship.exe'
  fi
else
  echo "--no-starship specified, not applying dotfiles/.starship/starship.toml"
fi

# Install and configure Git Credential Manager (GCM)
if [[ -z "$NO_GCM" ]]; then
  GCM_VER=$(curl -sL https://api.github.com/repos/GitCredentialManager/git-credential-manager/releases/latest | jq -r ".tag_name" | cut -c1- )
  echo "Installing latest Git Credential Manager (GCM) v${GCM_VER}..."
  curl -Lo gcm.latest.deb https://github.com/GitCredentialManager/git-credential-manager/releases/download/v${GCM_VER}/gcm-linux_amd64.${GCM_VER}.deb
  dpkg -i gcm.latest.deb

  if [[ -n "$IS_WSL" ]]; then
    msg "${YELLOW}[WARN]${NOFORMAT}: Ensure that Windows has git-credential-manager.exe installed for WSL ..."
    git config --system credential.helper "/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe"
  else
    echo "Configuring Git to use GCM with cache credentialstore for oauth and basic auth ..."
    git config --system credential.helper "$(which git-credential-manager)"
    git config --system credential.credentialstore "cache"
    git config --system credential.githubauthmodes "oauth, basic"
  fi
fi

echo 'All done!'
