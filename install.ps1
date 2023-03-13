# Install Git, which includes Git Credential Manager (GCM) core
winget install --id "Git.Git"
New-Item -ItemType SymbolicLink -Path "$PSScriptRoot/dotfiles/.gitconfig" -Target "$HOME/.gitconfig"

# Install Starship
winget install --id "Starship.Starship"
New-Item -ItemType Directory -Path "$HOME/.starship"
New-Item -ItemType SymbolicLink -Path "$PSScriptRoot/dotfiles/.starship/starship.toml" -Target "$HOME/.starship/starship.toml"
