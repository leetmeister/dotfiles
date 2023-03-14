#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Install dev experience prereqs and dotfiles.
.DESCRIPTION
    This script requires administrator privileges to:

    Install the following apps via winget (idempotent):
      - Git with Git Credential Manager (GCM)
      - Starship prompt

    Install the latest Caskaydia Cove Nerd Fonts
      - See https://github.com/$Organization/$Repository/releases/latest/

    Apply the following configurations:
      - Configure GCM as default Git credential.helper (System) 
      - Link dotfiles/.gitconfig to $HOME/.gitconfig (Global)
      - Link dotfiles/.starship/starship.toml to $HOME/.starship/starship.toml
         - Note: Assumes Profile.ps1 has custom $env:STARSHIP_CONFIG set for it

    This script also supports ShouldProcess flags:
      - Use -Force to execute silently and overwrite existing files/settings
      - Use -WhatIf to simulate what this script will do
      - Use -Confirm to prompt on each action and selectively run some of them
.LINK
    https://github.com/leetmeister/dotfiles
.PARAMETER  Force
.PARAMETER  WhatIf
.PARAMETER  Confirm
#>

Param(
    [Switch]$Force,
    [Switch]$WhatIf,
    [Switch]$Confirm
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
        if ($Force -or $PSCmdlet.ShouldContinue("Destination: $HOME\.gitconfig", 'Destination exists, overwrite with Symbolic Link?')) {
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
        if ($Force -or $PSCmdlet.ShouldContinue("Destination: $HOME\.starship\starship.toml", 'Destination exists, overwrite with Symbolic Link?')) {
            New-Item -ItemType SymbolicLink -Path "$HOME\.starship\starship.toml" -Target "$PSScriptRoot\.starship\starship.toml" -Force:$true -WhatIf:$WhatIf -Confirm:$false
        }
    }
    else {
        New-Item -ItemType SymbolicLink -Path "$HOME\.starship\starship.toml" -Target "$PSScriptRoot\.starship\starship.toml" -Force:$Force -WhatIf:$WhatIf -Confirm:$Confirm
    }
}

function Get-LatestGitHubReleaseInfo {
    Param(
        $Organization,
        $Repository
    )

    $url = "https://github.com/$Organization/$Repository/releases/latest/"
    $request = [System.Net.WebRequest]::Create($url)
    $response = $request.GetResponse()
    $realTagUrl = $response.ResponseUri.OriginalString
    $downloadUrl = $realTagUrl.Replace('tag', 'download')
    $version = $realTagUrl.split('/')[-1].Trim('v')
    $out = New-Object PsObject -Property @{url = $downloadUrl ; version = $version }
    return $out
}

function Install-NerdFonts {
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [Switch]$Force
    )

    if ($Force -and -not $Confirm) {
        $ConfirmPreference = 'None'
    }

    # Download the latest Caskaydia Cove Nerd Fonts
    $info = Get-LatestGitHubReleaseInfo -Organization ryanoasis -Repository nerd-fonts
    $fileName = 'CascadiaCode.zip'
    $downloadUrl = "$($info.url)/$fileName"
    $tempFile = "$env:TEMP/$fileName"
    $expandFolder = $fileName.Split('.')[0]
    $tempFolder = "$env:TEMP/$expandFolder"

    Write-Host "Download $downloadUrl ..."
    if ($PSCmdlet.ShouldProcess($downloadUrl, 'Download and extract')) {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile
        try {
            Expand-Archive -Path $tempFile -DestinationPath $tempFolder

            # Enumerate all Windows Compatible versions of font and install them
            # See https://github.com/ryanoasis/nerd-fonts/blob/master/install.ps1 for reference
            $fontFiles = [Collections.Generic.List[System.IO.FileInfo]]::new()
            Get-ChildItem $tempFolder -Recurse | Where-Object {
                ($_.Extension -match 'ttf|otf') -and ($_.BaseName -match 'Windows Compatible')
            } | ForEach-Object {
                $fontFiles.Add($_)
            }
            $fonts = $null
            foreach ($fontFile in $fontFiles) {
                if ($PSCmdlet.ShouldProcess($fontFile.Name, "Install Font")) {
                    if (!$fonts) {
                        $shellApp = New-Object -ComObject shell.application
                        $fonts = $shellApp.NameSpace(0x14)
                    }
                    $fonts.CopyHere($fontFile.FullName)
                }
            }
        }
        finally {
            Remove-Item -Path $tempFile -ErrorAction SilentlyContinue
            Remove-Item -Path $tempFolder -Recurse -ErrorAction SilentlyContinue
        }
    }
}

# Invoke installation functions
Install-Git -Force:$Force -WhatIf:$WhatIf -Confirm:$Confirm
Install-Starship -Force:$Force -WhatIf:$WhatIf -Confirm:$Confirm
Install-NerdFonts -Force:$Force -WhatIf:$WhatIf -Confirm:$Confirm
