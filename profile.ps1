# Alias definitions
set-alias cd Push-Location -option AllScope -scope Global
set-alias cd- Pop-LocationStack -option AllScope -scope Global
set-alias cd.. Push-ParentLocation -option AllScope -scope Global
set-alias cdh Get-LocationHistory -option AllScope -scope Global
set-alias loadprof Invoke-UserGlobalProfile -scope Global
set-alias np notepad.exe -scope Global
set-alias up Push-ParentLocation -option AllScope -scope Global
set-alias xp Invoke-Explorer -scope Global

# UI environment settings
$host.UI.RawUI.ForegroundColor = 'Gray'

# Import
Import-Module PSReadline
Set-PSReadLineOption -PredictionSource History

# Custom prompt settings
# This creates a prompt of the format:
#    C:\Current\Path [x]
#    y.z> 
# Where x = current depth of the default location stack
# y = nested prompt level 
# z = command history ID for the next command
function global:Prompt
{
  Write-Host $(Get-Location).Path -noNewLine
	Write-Host " [$((Get-Location -stack).Count)]" -foregroundcolor DarkGray

  $color = 'DarkGray'
  if ($nestedPromptLevel -gt 0)
  {
    $color = 'DarkGreen'
  }
  Write-Host "$nestedpromptlevel." -noNewLine -foregroundcolor $color
  return "$((Get-History -count 1).Id + 1)> "
}

# Traverse up the location hierarchy
function global:Push-ParentLocation
{
  # Go up one level by default
  $parentPath = ".."
  $param = $args[0]
  
  if ($param -ne $null) 
  {
    $parentPath = (Get-Location).Path
    if ($param -is [int])
    {
      # If arg is a number, go up that many levels
      for (; $param -gt 0; $param--)
      {
        $temp = Split-Path $parentPath -parent
        if ($temp -eq '') 
        {
          break
        }
        $parentPath = $temp
      }
    }
    else
    {
      # If arg is a string, go up to deepest segment beginnging with that string
      # e.g C:\foo\fi\bar\current> cd.. f  goes to C:\foo\fi
      do
      {
        $parentPath = Split-Path $parentPath -parent
      }
      while ($parentPath.Length -gt 0 -and !(Split-Path $parentPath -leaf).StartsWith($param,[System.StringComparison]"CurrentCultureIgnoreCase"))    
    }
  }

  if ($parentPath -ne '')
  {
    Push-Location $parentPath
  }
}

# Return to a previous location on the default stack
function global:Pop-LocationStack
{

  $i = $args[0]
  
  if ($i -eq $null) 
  { 
    # Pop one by default
    $i = 1
  }
  
  if ($i -isnot [int])
  {
    # Ignore command if argument is non-numeric
    return 
  }
  
  # Pop up to the max number of items in the stack
  $stackSize = (Get-Location -stack).Count
  if ($i -gt $stackSize) 
  {
    $i = $stackSize
  }
  
  for(; $i -gt 0; $i--)
  {
    Pop-Location
  }
}

# Pretty print the default location stack 
function global:Get-LocationHistory
{
  $stackArray = (Get-Location -stack).ToArray()
  if ($stackArray -ne $null)
  {  
    $stackArray.GetUpperBound(0)..0 | Select @{n='Depth';e={$_ + 1}}, @{n='Path';e={$stackArray[$_]}} | Format-Table -autosize
  }
}

# Launch explorer opened to the current location
function global:Invoke-Explorer
{
  if ($args.Count -gt 0)
  {
    & explorer.exe $args
  }
  else 
  {
    & explorer.exe .
  }
}

# Reloads the user's global profile.ps1
function global:Invoke-UserGlobalProfile
{
  Invoke-Expression "$(split-path $profile -parent)\profile.ps1"
}
