# dotfiles

Personal [dotfiles](https://dotfiles.github.io/) for configuring Windows & Linux dev environments:

- For Windows:
  - [Visual Studio Code](https://code.visualstudio.com/Download)
  - [Windows Terminal](https://learn.microsoft.com/en-us/windows/terminal/install)
  - [PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.3)
  - [Starship](https://starship.io)
- For Linux (Ubuntu/Debian):
  - [VS Code Remote Development](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack)
  - [Windows Subsystem for Linux (WSL)](https://learn.microsoft.com/en-us/windows/wsl/install)
  - [Zsh](https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH)
  - [Starship](https://starship.io)

## Usage

### Prerequisites

To run the installation scripts:

- Latest version of [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) for cloning this repo.
- For Windows, the built-in [Windows PowerShell (5.1)](https://learn.microsoft.com/en-us/powershell/scripting/whats-new/differences-from-windows-powershell?view=powershell-7.3) is sufficient to execute [`install.ps1`](./install.ps1).
- For Linux, an apt-based distro (e.g. Ubuntu, Debian) with [bash](https://www.gnu.org/software/bash/manual/html_node/index.html).

### Manual install on Windows

From a PowerShell prompt that is **run as administrator**:

```ps1
git clone https://github.com/leetmeister/dotfiles.git $HOME\dotfiles
& "$HOME\dotfiles\install.ps1" # [ -Force | -WhatIf | -Confirm ]
```

To get help:

```ps1
Get-Help $HOME\dotfiles\install.ps1
```

### Manual install on Linux

```bash
git clone https://github.com/leetmeister/dotfiles.git $HOME/dotfiles
$HOME/dotfiles/install.sh # [ --no-deps | --no-zsh | --no-starship | --no-gcm ]
```

### Automatically apply to VS Code dev containers

Update the [settings.json `dotfiles` properties](https://code.visualstudio.com/docs/devcontainers/containers#_personalizing-with-dotfile-repositories):

```json
{
  "dotfiles.repository": "leetmeister/dotfiles",
  "dotfiles.targetPath": "~/dotfiles",
  "dotfiles.installCommand": "~/dotfiles/install.sh"
}
```

These should then be automatically synced via GitHub/Microsoft account [settings sync](https://code.visualstudio.com/docs/getstarted/settings#_settings-sync).

## Additional configuration notes

### MacOS

No install script for MacOS but most things can be installed manually through [Homebrew](https://brew.sh/), bootstrapping through [Terminal](https://support.apple.com/guide/terminal/welcome/mac):

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew tap homebrew/cask-fonts
brew install font-cascadia-code
brew install cask iterm2
brew install git zsh starship git-credential-manager
```

That leaves configuration tasks that can be inferred from [`install.sh`](./install.sh):

- Git clone the zsh plugins into `$HOME/.zsh_plugins/`
  - <https://github.com/zsh-users/zsh-autosuggestions.git>
  - <https://github.com/zsh-users/zsh-syntax-highlighting.git>
- Apply the `.gitconfig`, `.zshrc`, and `starship.toml` dotfiles.
  - To view dotfiles in Finder, use `Cmd+Shift+.` to toggle showing `.*` files.
- Git config the system to use GCM.

There are also customizations to be made to iTerm:

- *iTerm → Preferences → Profiles → Colors → Color Presets*
  - Some color schemes to use: <https://iterm2colorschemes.com/>
- *iTerm → Preferences → Profiles → Text → Font*
  - Select the installed `Caskaydia Cove NF` font.

### PowerShell profiles

These are not included in dotfiles as they are already being synced via OneDrive under:

- `%USERPROFILE%\OneDrive\Documents`
  - `WindowsPowerShell\Profile.ps1`
  - `PowerShell\Profile.ps1` (if PowerShell 7 is additionally installed)

### Windows Terminal settings

The [`.windows_terminal/settings.json`](./.windows_terminal/settings.json) file will need to be customized to be appropriate for which shells are installed on the target device, and is not automatically installed as part of the install.ps1 script.

The Windows Terminal [settings.json](https://learn.microsoft.com/en-us/windows/terminal/customize-settings/profile-general) file is usually under `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json` and can be replaced there.

To distinguish between the various shells, custom themes can be generated via <https://windowsterminalthemes.dev/> per shell.

## References

| Topic | Link |
|  ---  |  --- |
| Bash Scripting Cheatsheet | <https://devhints.io/bash>
| Dev Container Templates   | <https://containers.dev/templates>
| Git Configuration         | <https://www.git-scm.com/book/en/v2/Customizing-Git-Git-Configuration>
| Git Credential Manager    | <https://github.com/git-ecosystem/git-credential-manager/blob/release/docs/configuration.md>
| Oh My Zsh Wiki            | <https://github.com/ohmyzsh/ohmyzsh/wiki>
| PowerShell 7              | <https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.3>
| PowerShell Profiles       | <https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles>
| Starship Configurations   | <https://starship.rs/config>
| Terminal Color Schemes    | <https://github.com/mbadolato/iTerm2-Color-Schemes>
| VS Code Profiles          | <https://code.visualstudio.com/docs/editor/profiles>
| Windows Terminal Settings | <https://learn.microsoft.com/en-us/windows/terminal/customize-settings/profile-general>
| Windows Terminal Splash   | <https://terminalsplash.com/>
| Zsh Manual                | <https://zsh.sourceforge.io/Doc/Release/zsh_toc.html>
