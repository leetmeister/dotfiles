##======================================================================================
## History handling
## See https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/history.zsh for reference
##======================================================================================

# History file configuration
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000

# Customize ZSH history settings
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history dataISTFILE=~/.zsh_history

##======================================================================================
## Completion handling
## See https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/completion.zsh for reference
##======================================================================================

# The following lines were added by compinstall to initialize completion handler
zstyle :compinstall filename '$HOME/.zshrc'
autoload -Uz compinit
compinit

# Add menu select as default menu completion method, with emacs ^o shortcut
zmodload -i zsh/complist
zstyle ':completion:*:*:*:*:*' menu select
bindkey -M menuselect '^o' accept-and-infer-next-history

# Complete . and .. special directories
zstyle ':completion:*' special-dirs true

# No special colors for items in a completion list
zstyle ':completion:*' list-colors ''

# Case-insensitive, partial-word and substring completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

# Disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# Use caching so that commands like apt and dpkg complete are usable
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path $ZSH_CACHE_DIR

# Treat all non-alphanumeric words in the line editor as breaks in a word 
WORDCHARS=''

# Customize ZSH completion settings
unsetopt menu_complete   # do not autoselect the first completion entry
unsetopt flowcontrol     # disable output flow control via start/stop (^S/^Q) chars in shell editor
setopt auto_menu         # show completion menu on successive tab press
setopt complete_in_word  # cursor stays put when completion is started
setopt always_to_end     # move cursor to end of word when completion is inserted

# Automatically load bash completion functions
autoload -U +X bashcompinit && bashcompinit

##======================================================================================
## Directories handling
## See https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/directories.zsh for reference
##======================================================================================

# Autocompletion for directories
function d () {
  if [[ -n $1 ]]; then
    dirs "$@"
  else
    dirs -v | head -n 10
  fi
}
compdef _dirs d

# Aliases for directory handling
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'

alias md='mkdir -p'
alias rd='rmdir'
alias lsa='ls -lah'

# Customize ZSH directory settings
setopt auto_cd              # cd into directory if command is not executable and matches a directory name
setopt auto_pushd           # cd pushes the old directory onto the directory stack
setopt pushd_ignore_dups    # don't push multiple copies of the same directory onto the directory stack
setopt pushd_minus          # reverse the meanings of '+' & '-' number of directory in the stack

##======================================================================================
## Key bindings
## See https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/key-bindings.zsh for reference
## See http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html for ZLE details
##======================================================================================

# Make sure that the terminal is in application mode when zle is active, since
# only then values from $terminfo are valid
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
  function zle-line-init() {
    echoti smkx
  }
  function zle-line-finish() {
    echoti rmkx
  }
  zle -N zle-line-init
  zle -N zle-line-finish
fi

# Use emacs key bindings
bindkey -e

# [PageUp] - Up a line of history
if [[ -n "${terminfo[kpp]}" ]]; then
  bindkey -M emacs "${terminfo[kpp]}" up-line-or-history
fi

# [PageDown] - Down a line of history
if [[ -n "${terminfo[knp]}" ]]; then
  bindkey -M emacs "${terminfo[knp]}" down-line-or-history
fi

# Start typing + [Up-Arrow] - fuzzy find history forward
autoload -U up-line-or-beginning-search
zle -N up-line-or-beginning-search
if [[ -n "${terminfo[kcuu1]}" ]]; then
  bindkey -M emacs "${terminfo[kcuu1]}" up-line-or-beginning-search
else
  bindkey -M emacs '^[[A' up-line-or-beginning-search
fi

# Start typing + [Down-Arrow] - fuzzy find history backward
autoload -U down-line-or-beginning-search
zle -N down-line-or-beginning-search
if [[ -n "${terminfo[kcud1]}" ]]; then
  bindkey -M emacs "${terminfo[kcud1]}" down-line-or-beginning-search
else
  bindkey -M emacs '^[[B' down-line-or-beginning-search
fi

# [Home] - Go to beginning of line
if [[ -n "${terminfo[khome]}" ]]; then
  bindkey -M emacs "${terminfo[khome]}" beginning-of-line
fi

# [End] - Go to end of line
if [[ -n "${terminfo[kend]}" ]]; then
  bindkey -M emacs "${terminfo[kend]}"  end-of-line
fi

# [Shift-Tab] - move through the completion menu backwards
if [[ -n "${terminfo[kcbt]}" ]]; then
  bindkey -M emacs "${terminfo[kcbt]}" reverse-menu-complete
fi

# [Backspace] - delete backward
bindkey -M emacs '^?' backward-delete-char

# [Delete] - delete forward
if [[ -n "${terminfo[kdch1]}" ]]; then
  bindkey -M emacs "${terminfo[kdch1]}" delete-char
else
  bindkey -M emacs "^[[3~" delete-char
  bindkey -M emacs "^[3;5~" delete-char
fi

# [Ctrl-Backspace] - delete whole backward-word
bindkey -M emacs '^[^?' backward-kill-word

# [Ctrl-Delete] - delete whole forward-word
bindkey -M emacs '^[[3;5~' kill-word

# [Ctrl-RightArrow] - move forward one word
bindkey -M emacs '^[[1;5C' forward-word

# [Ctrl-LeftArrow] - move backward one word
bindkey -M emacs '^[[1;5D' backward-word

# [Ctrl-r] - Search backward incrementally for a specified string.
# The string may begin with ^ to anchor the search to the beginning of the line.
bindkey '^r' history-incremental-search-backward

# [Space] - don't do history expansion
bindkey ' ' magic-space

##======================================================================================
## Additional ZSH customizations
## See https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins for plugins
##======================================================================================

# Customize ZSH miscellaneous options
unsetopt beep # do not beep on error

# Initialize zsh community plugins
if [[ -f $HOME/.zsh_plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source $HOME/.zsh_plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

if [[ -f $HOME/.zsh_plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source $HOME/.zsh_plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Run Starship prompt
export STARSHIP_CONFIG="$HOME/.starship/starship.toml"
export STARSHIP_CACHE="$HOME/.starship/cache"
eval "$(starship init zsh)"