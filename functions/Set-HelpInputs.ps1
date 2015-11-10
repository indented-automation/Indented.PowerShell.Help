function Set-HelpInputs {
  # .EXTERNALHELP Indented.PowerShell.Help-Help.xml

  [CmdletBinding(DefaultParameterSetName = 'FromXDocument')]
  [OutputType([System.Xml.Linq.XDocument])]
  param(
    [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true)]
    [System.Management.Automation.CommandInfo]$CommandInfo,

    [Parameter(ParameterSetName = 'FromPath')]
    [String]$Path,

    [Parameter(ParameterSetName = 'FromXDocument')]
    [System.Xml.Linq.XDocument]$XDocument,

    [Switch]$Force
  )

  Write-Host "Hello"
}