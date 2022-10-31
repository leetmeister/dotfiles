# History settings 
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000

# Miscellaneous options
unsetopt beep

# The following lines were added by compinstall
zstyle :compinstall filename '$HOME/.zshrc'
autoload -Uz compinit
compinit

# Case-insensitive partial-word and substring completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
# disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
# Use caching so that commands like apt and dpkg complete are useable
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path $ZSH_CACHE_DIR

unsetopt menu_complete   # do not autoselect the first completion entry
unsetopt flowcontrol
setopt auto_menu         # show completion menu on successive tab press
setopt complete_in_word
setopt always_to_end

# automatically load bash completion functions
autoload -U +X bashcompinit && bashcompinit

# Initialize zsh community plugins
if [[ -f $HOME/.zsh_plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source $HOME/.zsh_plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

if [[ -f $HOME/.zsh_plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source $HOME/.zsh_plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Run Starship prompt
eval "$(starship init zsh)"