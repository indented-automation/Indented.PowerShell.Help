function GetXNamespace {
  # .SYNOPSIS
  #   Get a registered XNamespace.
  # .DESCRIPTION
  #   Internal use only.
  # .PARAMETER Name
  #   The name of a previously registered XNamespace.
  # .INPUTS
  #   System.String
  # .OUTPUTS
  #   System.Xml.Linq.XNamespace
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     22/10/2015 - Chris Dent - Created.
  
  [CmdletBinding()]
  [OutputType([System.Xml.Linq.XNamespace])]
  param(
    [ValidateSet('command', 'dev', 'maml', 'xmlns')]
    [String]$Name
  )

  if ($psboundparameters.ContainsKey('Name')) {
    if ($Name -eq 'xmlns') {
      return [System.Xml.Linq.XNamespace]::xmlns
    } elseif ($Name) {
      $Script:XNamespaces[$Name]
    }
  } else {
    $Script:XNamespaces.Values
  }
}