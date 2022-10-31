# Install Starship
winget install --id "Starship.Starship"

# Create symlinks
New-Item -ItemType Directory -Path "$HOME/.starship"
New-Item -ItemType SymbolicLink -Path "$HOME/dotfiles/.starship/starship.toml" -Target "$HOME/.starship/starship.toml"
