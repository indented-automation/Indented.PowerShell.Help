function GetTemplateXElement {
  # .SYNOPSIS
  #   Get a node from the template.
  # .DESCRIPTION
  #   The template document is used to hold a default document consistent with the schema.
  # .PARAMETER Name
  #   The node to retrieve, for example, command:command. A more specific query is also permitted, for example command:command\command:parameter
  # .PARAMETER Path
  #   The path to the template. By default the ModuleBase\variables\template.xml file.
  # .INPUTS
  #   System.String
  # .OUTPUTS
  #   System.Xml.Linq.XElement
  # .EXAMPLE
  #   GetTemplateXElement 'command:command'
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     06/11/2015 - Chris Dent - Created.
  
  [CmdletBinding()]
  [OutputType([System.Xml.Linq.XElement])]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$Name,

    [ValidateNotNullOrEmpty()]
    [ValidateScript( { Test-Path $_ } )]
    [String]$Path = "$psscriptroot\..\variables\template.xml"
  )

  $XDocument = [System.Xml.Linq.XDocument]::Load($Path)

  # Select the first matching node from the template. Parameter type elements are duplicated, however both versions are the same in the template.
  SelectXPathXElement -XPathExpression "/helpItems//$Name" -XContainer $XDocument |
    Select-Object -First 1
}