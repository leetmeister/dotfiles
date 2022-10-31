#!/usr/bin/bash

# Install Starship
curl -SsL https://starship.rs/install.sh | sh

# Install ZSH plugins
git clone https://github.com/zsh-users/zsh-autosuggestions.git $HOME/.zsh_plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.zsh_plugins/zsh-syntax-highlighting

# Create symlinks
ln -nfs $HOME/dotfiles/.zshrc $HOME/.zshrc
ln -nfs $HOME/dotfiles/.starship/starship.toml $HOME/.starship/starship.toml

# Add WSL-specific configurations
# The presence of /proc/sys/fs/binfmt_misc/WSLInterop file or /run/WSL directory suggests the Linux instance is running under WSL
if [[ -e "/proc/sys/fs/binfmt_misc/WSLInterop" || -d "/run/WSL" ]]; then
    git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/libexec/git-core/git-credential-manager-core.exe"
    starship config git_status.windows_starship '/mnt/c/Program Files/Starship/bin/starship.exe'
else
    git config --global credential.helper $(which git-credential-manager-core)
    git config --global credential.credentialstore "cache"
    git config --global credential.githubauthmodes "oauth, basic"
fi
