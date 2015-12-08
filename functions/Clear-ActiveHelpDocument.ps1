function Clear-ActiveHelpDocument {
  # .SYNOPSIS
  #   Clear the help document made active by Set-ActiveHelpDocument.
  # .DESCRIPTION
  #   Clear-ActiveHelpDocument removes an active help document from memory.
  # .INPUTS
  #   None
  # .OUTPUTS
  #   None
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     04/12/2015 - Chris Dent - Created.
  
  [CmdletBinding()]
  param( )

  if (Test-Path Variable:Script:ActiveHelpDocument) {
    Remove-Variable ActiveHelpDocument -Scope Script
  }
}