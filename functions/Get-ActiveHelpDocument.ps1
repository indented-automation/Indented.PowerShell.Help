function Get-ActiveHelpDocument {
  # .SYNOPSIS
  #   Get the help document made active by Set-ActiveHelpDocument.
  # .DESCRIPTION
  #   Get-ActiveHelpDocument allows persistent access to a help document.
  # .OUTPUTS
  #   System.Xml.Linq.XDocument
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     29/10/2015 - Chris Dent - Created.
  
  [CmdletBinding()]
  [OutputType([System.Xml.Linq.XDocument])]
  param( )

  return $Script:ActiveHelpDocument
}