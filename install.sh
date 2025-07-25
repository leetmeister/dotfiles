#!/usr/bin/env bash
# See https://betterdev.blog/minimal-safe-bash-script-template/ for recommendations
set -eu

SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}")
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat << EOF
Usage: ${SCRIPT_NAME} [OPTIONS]

Install dev experience prereqs and dotfiles.

Minimally, it always links the dotfiles/.gitconfig to \$HOME/.gitconfig (global config).
Depending on options, it will also:

1. Install the following apt packages, which can be skipped with the --no-deps flag.
   Will prompt for sudo elevation:
    - curl
    - coreutils (for ln)
    - git
    - jq (if installing Git Credential Manager)
    - libicu70 (if installing Git Credential Manager)

2. Install and configure ZSH, which can be skipped with the --no-zsh flag.
    - Install the zsh package (will prompt for sudo elevation)
    - Set zsh as the default shell
    - Install the zsh-autosuggestions and zsh-syntax-highlighting plugins
    - Link dotfiles/.zshrc to \$HOME/.zshrc

3. Install the Starship prompt, which can be skipped with the --no-starship flag.
    - Install Starship from starship.rs install script (self-elevates)
    - Link dotfiles/.starship/starship.toml to \$HOME/.starship/starship.toml
      - Note that dotfiles/.zshrc uses \$STARSHIP_CONFIG to reference this path
    - [WSL only] Add 'git_status.windows_starship' configuration to starship.toml

4. Install the latest Git Credential Manager (GCM) release from GitHub, which can
   be skipped with the --no-gcm flag. Will prompt for sudo elevation.
    - [WSL] Configure Windows GCM as default Git credential.helper at --system scope
      if in WSL
    - [Non-WSL] Download and install the GCM .deb release, then configure
      it as the default Git credential.helper at --system scope

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
  NO_DEPS=0
  NO_GCM=0
  NO_STARSHIP=0
  NO_ZSH=0

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
if [[ (${NO_DEPS} = 1) && (${NO_GCM} = 1) && (${NO_STARSHIP} = 1) && (${NO_ZSH} = 1) ]]; then
  msg "${BLUE}[INFO]${NOFORMAT}: All install actions skipped, only applying .gitconfig"
fi

# The presence of /proc/sys/fs/binfmt_misc/WSLInterop file or /run/WSL directory suggests the Linux instance is running under WSL
IS_WSL=0
if [[ -e "/proc/sys/fs/binfmt_misc/WSLInterop" || -d "/run/WSL" ]]; then
  echo "Detected that script is running under WSL ..."
  IS_WSL=1
fi

# Apply dotfiles/.gitconfig
ln -nfs "${SCRIPT_DIR}/.gitconfig" "$HOME/.gitconfig"

# Install prerequisite packages
DEPS="curl coreutils git jq"

# Only add libicu70 for non-WSL systems where we actually install GCM
if [[ ${NO_GCM} = 0 && ${IS_WSL} = 0 ]]; then
  DEPS="${DEPS} libicu70"
fi
if [[ ${NO_DEPS} = 1 ]]; then
  echo "--no-deps specified, assume that required dependencies are already installed: ${DEPS}"
else
  echo "Installing required apt packages: ${DEPS} ..."
  sudo apt update
  sudo apt install ${DEPS}
fi

# Install and configure ZSH
if [[ ${NO_ZSH} = 1 ]]; then
  echo "--no-zsh specified, not applying dotfiles/.zshrc"
else
  echo "Installing ZSH as default shell ..."
  sudo apt install zsh
  chsh -s "$(which zsh)"

  echo "Cloning zsh-autosuggestions plugin from GitHub ..."
  if [ -d "$HOME/.zsh_plugins/zsh-autosuggestions" ]; then
    (cd "$HOME/.zsh_plugins/zsh-autosuggestions" && git pull )
  else
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.zsh_plugins/zsh-autosuggestions"
  fi

  echo "Cloning zsh-syntax-highlighting plugin from GitHub ..."
  if [ -d "$HOME/.zsh_plugins/zsh-syntax-highlighting" ]; then
    (cd "$HOME/.zsh_plugins/zsh-syntax-highlighting" && git pull )
  else
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.zsh_plugins/zsh-syntax-highlighting"
  fi

  echo "Linking dotfiles/.zshrc to local home ..."
  ln -nfs "${SCRIPT_DIR}/.zshrc" "$HOME/.zshrc"

  echo "Creating .zshrc.local from template if it doesn't exist ..."
  if [[ ! -f "$HOME/.zshrc.local" ]]; then
    cp "${SCRIPT_DIR}/.zshrc.local.template" "$HOME/.zshrc.local"
    echo "Created $HOME/.zshrc.local from template - customize it for your machine"
  else
    echo "$HOME/.zshrc.local already exists, skipping"
  fi
fi

# Install and configure Starship
if [[ ${NO_STARSHIP} = 1 ]]; then
  echo "--no-starship specified, not applying dotfiles/.starship/starship.toml"
else
  echo "Installing Starship prompt ..."
  curl -SsL https://starship.rs/install.sh | sh

  echo "Linking dotfiles/.starship/starship.toml to local home ..."
  mkdir -p "$HOME/.starship"
  ln -nfs "${SCRIPT_DIR}/.starship/starship.toml" "$HOME/.starship/starship.toml"

  if [[ ${IS_WSL} = 1 ]]; then
    msg "${YELLOW}[WARN]${NOFORMAT}: Ensure that Windows has Starship installed for handling git_status in WSL ..."
    starship config git_status.windows_starship '/mnt/c/Program Files/starship/bin/starship.exe'
  fi
fi

# Install and configure Git Credential Manager (GCM)
if [[ ${NO_GCM} = 1 ]]; then
  echo "--no-gcm specified, not configuring GCM as credential.helper"
else
  if [[ ${IS_WSL} = 1 ]]; then
    msg "${YELLOW}[WARN]${NOFORMAT}: Ensure that Windows has git-credential-manager.exe installed for WSL ..."
    sudo git config --system credential.helper "/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe"
  else
    GCM_VER=$(curl -sL https://api.github.com/repos/GitCredentialManager/git-credential-manager/releases/latest | jq -r ".tag_name" | cut -c2- )
    echo "Installing latest Git Credential Manager (GCM) v${GCM_VER}..."
    curl -Lo gcm.latest.deb https://github.com/GitCredentialManager/git-credential-manager/releases/download/v${GCM_VER}/gcm-linux_amd64.${GCM_VER}.deb
    sudo dpkg -i gcm.latest.deb
    rm gcm.latest.deb

    echo "Configuring Git to use GCM with cache credentialstore for oauth and basic auth ..."
    sudo git config --system credential.helper "$(which git-credential-manager)"
    sudo git config --system credential.credentialstore "cache"
    sudo git config --system credential.githubauthmodes "oauth, basic"
  fi
fi

echo 'All done!'
