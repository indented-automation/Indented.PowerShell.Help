function UpdateHelpInput {
  # .EXTERNALHELP Indented.PowerShell.Help-Help.xml

  [CmdletBinding()]
  [OutputType([System.Xml.Linq.XDocument])]
  param(
    [Parameter(Mandatory = $true)]
    [System.Management.Automation.CommandInfo]$CommandInfo,

    [Parameter(Mandatory = $true)]
    [System.Xml.Linq.XDocument]$XDocument
  )

  Write-Host "Hello"
  
  return $XDocument
}