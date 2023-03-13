# dotfiles
Personal dotfiles for configuring Linux dev environment

- [x] Set up PowerShell environment
  - [x] Define profile.ps1
    - [x] Merge WindowsPowerShell/profile.ps1 with dotfiles/profile.ps1
    - [x] Delegate profile.ps1 to OneDrive sync instead of dotfiles
  - [x] Define dotfiles/install.ps1
    - [x] Link .gitconfig file
- [x] Set up ZSH environment
  - [x] Customize .zshrc from oh-my-zsh lib:
    - [x] [directories.zsh](https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/directories.zsh)
    - [x] [history.zsh](https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/history.zsh)
    - [x] [key-bindings.zsh](https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/key-bindings.zsh)
    - [x] [completion.zsh](https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/completion.zsh)
  - [x] Define install.sh
    - [x] Assuming public dotfiles repo, also install prereqs, gcm, and zsh
- [ ] Configure starship.toml
  - [ ] Tweak color scheme
- [x] Add .gitconfig
- [x] Check Linux prerequisites
  - [x] curl
  - [x] git
  - [x] ln
  - [x] wsl

``` bash
# libicu is needed for gcm
sudo apt install curl git libicu70 zsh

# Download latest GCM package from https://github.com/GitCredentialManager/git-credential-manager/releases/latest
curl -Lo gcm.latest.deb https://github.com/GitCredentialManager/git-credential-manager/releases/download/v2.0.785/gcm-linux_amd64.2.0.785.deb
dpkg -i gcm.latest.deb

# Change default shell to ZSH
chsh -s $(which zsh)
```

## Default bindkey map for emacs
```bash
"^@" set-mark-command
"^A" beginning-of-line
"^B" backward-char
"^D" delete-char-or-list
"^E" end-of-line
"^F" forward-char
"^G" send-break
"^H" backward-delete-char
"^I" expand-or-complete
"^J" accept-line
"^K" kill-line
"^L" clear-screen
"^M" accept-line
"^N" down-line-or-history
"^O" accept-line-and-down-history
"^P" up-line-or-history
"^Q" push-line
"^R" history-incremental-search-backward
"^S" history-incremental-search-forward
"^T" transpose-chars
"^U" kill-whole-line
"^V" quoted-insert
"^W" backward-kill-word
"^X^B" vi-match-bracket
"^X^F" vi-find-next-char
"^X^J" vi-join
"^X^K" kill-buffer
"^X^N" infer-next-history
"^X^O" overwrite-mode
"^X^R" _read_comp
"^X^U" undo
"^X^V" vi-cmd-mode
"^X^X" exchange-point-and-mark
"^X*" expand-word
"^X=" what-cursor-position
"^X?" _complete_debug
"^XC" _correct_filename
"^XG" list-expand
"^Xa" _expand_alias
"^Xc" _correct_word
"^Xd" _list_expansions
"^Xe" _expand_word
"^Xg" list-expand
"^Xh" _complete_help
"^Xm" _most_recent_file
"^Xn" _next_tags
"^Xr" history-incremental-search-backward
"^Xs" history-incremental-search-forward
"^Xt" _complete_tag
"^Xu" undo
"^X~" _bash_list-choices
"^Y" yank
"^[^D" list-choices
"^[^G" send-break
"^[^H" backward-kill-word
"^[^I" self-insert-unmeta
"^[^J" self-insert-unmeta
"^[^L" clear-screen
"^[^M" self-insert-unmeta
"^[^_" copy-prev-word
"^[ " expand-history
"^[!" expand-history
"^[\"" quote-region
"^[\$" spell-word
"^['" quote-line
"^[," _history-complete-newer
"^[-" neg-argument
"^[." insert-last-word
"^[/" _history-complete-older
"^[0" digit-argument
"^[1" digit-argument
"^[2" digit-argument
"^[3" digit-argument
"^[4" digit-argument
"^[5" digit-argument
"^[6" digit-argument
"^[7" digit-argument
"^[8" digit-argument
"^[9" digit-argument
"^[<" beginning-of-buffer-or-history
"^[>" end-of-buffer-or-history
"^[?" which-command
"^[A" accept-and-hold
"^[B" backward-word
"^[C" capitalize-word
"^[D" kill-word
"^[F" forward-word
"^[G" get-line
"^[H" run-help
"^[L" down-case-word
"^[N" history-search-forward
"^[OA" up-line-or-history
"^[OB" down-line-or-history
"^[OC" forward-char
"^[OD" backward-char
"^[OF" end-of-line
"^[OH" beginning-of-line
"^[P" history-search-backward
"^[Q" push-line
"^[S" spell-word
"^[T" transpose-words
"^[U" up-case-word
"^[W" copy-region-as-kill
"^[[200~" bracketed-paste
"^[[2~" overwrite-mode
"^[[3~" delete-char
"^[[A" up-line-or-history
"^[[B" down-line-or-history
"^[[C" forward-char
"^[[D" backward-char
"^[_" insert-last-word
"^[a" accept-and-hold
"^[b" backward-word
"^[c" capitalize-word
"^[d" kill-word
"^[f" forward-word
"^[g" get-line
"^[h" run-help
"^[l" down-case-word
"^[n" history-search-forward
"^[p" history-search-backward
"^[q" push-line
"^[s" spell-word
"^[t" transpose-words
"^[u" up-case-word
"^[w" copy-region-as-kill
"^[x" execute-named-cmd
"^[y" yank-pop
"^[z" execute-last-named-cmd
"^[|" vi-goto-column
"^[~" _bash_complete-word
"^[^?" backward-kill-word
"^_" undo
" "-"~" self-insert
"^?" backward-delete-char
"\M-^@"-"\M-^?" self-insert
```
