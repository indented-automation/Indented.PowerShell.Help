function New-HelpDocument {
  # .SYNOPSIS
  #   Create a new empty help document.
  # .DESCRIPTION
  #   The resulting help document will contain a declaration, helpItems root node and a schema attribute.
  # .OUTPUTS
  #   System.Xml.Linq.XDocument
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     28/10/2015 - Chris Dent - Created.
  
  [CmdletBinding()]
  [OutputType([System.Xml.Linq.XDocument])]
  param( )
  
  $XDocument = New-Object System.Xml.Linq.XDocument
  $XDocument.Declaration = New-Object System.Xml.Linq.XDeclaration "1.0", "utf-16", $true
  
  return ($XDocument | AddHelpItemsRootElement)
}