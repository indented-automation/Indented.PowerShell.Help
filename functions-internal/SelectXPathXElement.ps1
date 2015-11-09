function SelectXPathXElement {
  # .SYNOPSIS
  #   Select an element from a System.Xml.Linq container using XPath.
  # .DESCRIPTION
  #   Wraps the extension method XPathSelectElements injecting a valid namespace manager.
  #
  #   While Linq to XML syntax is relatively clean in languages like C# the usage is more than a bit painful in PowerShell.
  # .PARAMETER XPathExpression
  #   An expression to return nodes. 
  # .PARAMETER XContainer
  #   A container to search.
  # .INPUTS
  #   System.String
  #   System.Xml.Linq.XContainer
  # .OUTPUTS
  #   System.Xml.Linq.XElement
  # .EXAMPLE
  #   SelectXPathXElement -XPathExpression '\helpItems\command:command'
  #
  #   Get nodes matching the specified expression from the active help document.
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     03/11/2015 - Chris Dent - Created.
  
  [CmdletBinding()]
  [OutputType([System.Xml.Linq.XElement])]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$XPathExpression,
  
    [ValidateNotNullOrEmpty()]
    [System.Xml.Linq.XContainer]$XContainer = (Get-ActiveHelpDocument)
  )
  
  [System.Xml.XPath.Extensions]::XPathSelectElements(
    $XContainer,
    $XPathExpression,
    (GetNamespaceManager)
  )
}