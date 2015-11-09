function Get-CmdletInfo {
  # .SYNOPSIS
  #   Create an instance of CmdletInfo from a type inheriting from PSCmdlet.
  # .DESCRIPTION
  #   Simplifies creation of a CmdletInfo object from a type.
  #
  #   Note: Get-Command provides the same return value if the module is imported.
  # .PARAMETER ImplementingType
  #   The type which implements a Cmdlet.
  # .INPUTS
  #   System.Type
  # .OUTPUTS
  #   System.Management.Automation.CmdletInfo
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     22/10/2015 - Chris Dent - Created.
  
  [CmdletBinding()]
  [OutputType([System.Management.Automation.CmdletInfo])]
  param(
    [ValidateNotNullOrEmpty()]
    [Type]$ImplementingType
  )

  $Cmdlet = $ImplementingType.GetCustomAttributes([System.Management.Automation.CmdletAttribute], $false)
  return New-Object System.Management.Automation.CmdletInfo(
    ('{0}-{1}' -f $Cmdlet.VerbName, $Cmdlet.NounName),
    $ImplementingType
  )
}