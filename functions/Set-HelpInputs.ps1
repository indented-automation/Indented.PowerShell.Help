function Set-HelpInputs {
  [CmdletBinding()]
  param(
    [System.Management.Automation.CommandInfo]$CommandInfo,

    [System.Xml.Linq.XDocument]$XDocument
  )

  Write-Host "Hello"
}