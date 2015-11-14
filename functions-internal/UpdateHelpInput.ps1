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

  $Parameters = $CommandInfo.Parameters.Values |
    Where-Object { $_.Name -notin (GetReservedParameterNames) }

  if ($Parameters) {
    SelectXPathXElement `
        -XPathExpression "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/command:inputTypes/command:inputType" `
        -XContainer $XDocument |
      ForEach-Object {
        $_.Remove() 
      }

    $Parameters.ParameterType |
      Where-Object { $_ -isnot [Switch] } |
      Select-Object -Unique FullName |
      ForEach-Object {
        Write-Verbose "    Creating inputTypes\inputType element for $($_.FullName)"
        
        $InputTypeXElement = GetTemplateXElement 'command:inputTypes/command:inputType'
        $InputTypeXElement.Element((GetXNamespace 'dev') + 'type').Element((GetXNamespace 'maml') + 'name').Value = $_.FullName
        
        $InputTypeXElement
      } |
      AddXElement -XContainer $XDocument `
        -Parent "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/command:inputTypes" `
        -SortBy './dev:type/maml:name'
  }
}