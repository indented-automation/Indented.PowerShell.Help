function Get-CommandInfo {
  # .SYNOPSIS
  #   Get a CommandInfo object based on the value for Command. 
  # .DESCRIPTION
  #   Get-CommandInfo makes an attempt to acquire a CommandInfo derived type from the supplied value.
  # .PARAMETER Command
  #   The command to acquire CommandInfo for.
  # .INPUTS
  #   System.Object
  # .OUTPUTS
  #   System.Management.Automation.CommandInfo
  # .EXAMPLE
  #   Get-CommandInfo 'Get-CommandInfo'
  # .EXAMPLE
  #   Get-CommandInfo 'Microsoft.PowerShell.Commands.ProcessBaseCommand'
  # .EXAMPLE
  #   Get-CommandInfo 'C:\ModuleRoot.psm1'
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     14/12/2015 - Chris Dent - Created.

  [CmdletBinding()]
  param(
    $Command
  )
  if ($Command -is [System.Management.Automation.CommandInfo]) {
    $Command
  } elseif ($Command -is [Type] -or ($Command -is [String] -and $Command -as [Type])) {
    Get-CmdletInfo -ImplementingType $Command
  } elseif ($Command -is [String] -and $Command.EndsWith('.ps1') -and (Test-Path $Command)) {
    Get-FunctionInfo -Path $Command
  } elseif ($Command -is [ScriptBlock]) {
    Get-FunctionInfo -ScriptBlock $Command
  } elseif ($Command -is [String]) {
    Get-Command $Command
  }
}