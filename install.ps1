#Requires -RunAsAdministrator
Param(
    [Switch]$Confirm,
    [Switch]$WhatIf,
    [Switch]$Force
)

function Install-Git {
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [Switch]$Force
    )

    if ($Force -and -not $Confirm) {
        $ConfirmPreference = 'None'
    }

    # Install updated Git, which includes Git Credential Manager (GCM) core
    Write-Host "Update Git installation ..."
    if ($PSCmdlet.ShouldProcess('Git.Git', 'winget install')) {
        winget install --id 'Git.Git'
    }

    # Link dotfiles\.gitconfig to local home
    Write-Host "Link dotfiles\.gitconfig to local config path ..."
    if (Test-Path "$HOME\.gitconfig") {
        if ($Force -or $PSCmdlet.ShouldContinue("Destination: $HOME\.gitconfig", 'Overwrite with Symbolic Link')) {
            New-Item -ItemType SymbolicLink -Path "$HOME\.gitconfig" -Target "$PSScriptRoot\.gitconfig" -Force:$true -WhatIf:$WhatIf -Confirm:$false
        }
    }
    else {
        New-Item -ItemType SymbolicLink -Path "$HOME\.gitconfig" -Target "$PSScriptRoot\.gitconfig" -Force:$Force -WhatIf:$WhatIf -Confirm:$Confirm
    }

    # Configure Git to use git-credential-manager-core system-wide
    if ($PSCmdlet.ShouldProcess('C:\Program Files\Git\mingw64\bin\git-credential-manager-core.exe', 'git config --system credential.helper')) {
        git config --system credential.helper 'C:\\Program\ Files\\Git\\mingw64\\bin\\git-credential-manager.exe'
    }
}

function Install-Starship {
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [Switch]$Force
    )

    if ($Force -and -not $Confirm) {
        $ConfirmPreference = 'None'
    }

    # Install Starship
    Write-Host "Install Starship ..."
    if ($PSCmdlet.ShouldProcess('Starship.Starship', 'winget install')) {
        winget install --id 'Starship.Starship'
    }

    # Add Starship to $PATH
    $path = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    if ($path.Contains('C:\Program Files\starship\bin')) {
        Write-Host 'Starship is already in $PATH ...'
    }
    else {
        if (!$path.EndsWith(';')) {
            $path = "$path;"
        }
        Write-Host 'Add starship to path ...'
        if ($PSCmdlet.ShouldProcess('Add C:\Program Files\starship\bin', 'Machine environment $PATH')) {
            [Environment]::SetEnvironmentVariable('Path', -join ($path, 'C:\Program Files\starship\bin;'), 'Machine')
            $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
        }
    }

    # Add .starship config path
    if (Test-Path "$HOME\.starship" -PathType Container) {
        Write-Host "Starship config path $HOME\.starship already exists ..."
    }
    else {
        Write-Host "Create $HOME\.starship path"
        New-Item -ItemType Directory -Path "$HOME\.starship" -Force:$Force -WhatIf:$WhatIf -Confirm:$Confirm
    }

    # Link dotfiles\.starship\starship.toml to local config path
    Write-Host "Link dotfiles\.starship\starship.toml to local config path ..."
    if (Test-Path "$HOME\.starship\starship.toml") {
        if ($Force -or $PSCmdlet.ShouldContinue("Destination: $HOME\.starship\starship.toml", 'Overwrite with Symbolic Link')) {
            New-Item -ItemType SymbolicLink -Path "$HOME\.starship\starship.toml" -Target "$PSScriptRoot\.starship\starship.toml" -Force:$true -WhatIf:$WhatIf -Confirm:$false
        }
    }
    else {
        New-Item -ItemType SymbolicLink -Path "$HOME\.starship\starship.toml" -Target "$PSScriptRoot\.starship\starship.toml" -Force:$Force -WhatIf:$WhatIf -Confirm:$Confirm
    }
}

# Invoke installation functions
Install-Git -Force:$Force -Confirm:$Confirm -WhatIf:$WhatIf
Install-Starship -Force:$Force -Confirm:$Confirm -WhatIf:$WhatIf
