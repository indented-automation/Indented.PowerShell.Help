function GetNamespaceManager {
  # .SYNOPSIS
  #   Get the namespace manager used by Indented.PowerShell.Help.
  # .DESCRIPTION
  #   Internal use only.
  # .OUTPUTS
  #   System.Xml.XmlNamespaceManager
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     28/10/2015 - Chris Dent - Created.
   
  [CmdletBinding()]
  [OutputType([System.Xml.XmlNamespaceManager])]
  param( )

  return ,$Script:NamespaceManager
}