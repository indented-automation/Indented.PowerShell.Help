function RegisterNamespace {
  # .SYNOPSIS
  #   Creates and registers an XML namespace for later use.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER Name
  #   The name of the entry to add.
  # .PARAMETER URI
  #   A URI acting as a unique reference for the namespace.
  # .INPUTS
  #   System.String
  #   System.URI
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     28/10/2015 - Chris Dent - Created.
  
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [ValidatePattern('^[a-z]+$')]
    [String]$Name,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [URI]$URI
  )

  if (-not (Test-Path Variable:Script:XNamespaces)) {
    New-Variable XNamespaces -Scope Script -Value @{} 
  }
  if (-not (Test-Path Variable:Script:NamespaceManager)) {
    New-Variable NamespaceManager -Scope Script -Value (New-Object System.Xml.XmlNamespaceManager((New-Object System.Xml.NameTable)))
  }

  if (-not $Script:XNamespaces.Contains($Name)) {
    $Script:XNamespaces.Add(
      $Name,
      ([System.Xml.Linq.XNamespace]$URI.ToString())
    )
    $Script:NamespaceManager.AddNamespace($Name, $URI)
  }
}