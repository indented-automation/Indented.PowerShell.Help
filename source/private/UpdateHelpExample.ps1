function UpdateHelpExample {
  # .EXTERNALHELP Indented.PowerShell.Help-Help.xml

  [CmdletBinding()]
  [OutputType([System.Xml.Linq.XDocument])]
  param(
    $Example,

    [Parameter(Mandatory = $true)]
    [System.Management.Automation.CommandInfo]$CommandInfo,

    [Parameter(Mandatory = $true)]
    [System.Xml.Linq.XDocument]$XDocument,

    [Switch]$Append
  )

  if ($psboundparameters.ContainsKey('Example')) {
    if ($Example -is [Indented.PowerShell.Help.DocumentItem]) {
      $DocumentItem = $Example
    } elseif ($Example -eq $null -and -not $Append) {
      $DocumentItem = Get-HelpDocumentItem -Item 'Example' -Template
    } elseif ($Example -eq $null) {
      # Ignore this condition for now.
    } else {
      $DocumentItem = New-HelpExample $Example 
    }
  
    if (Test-Path variable:DocumentItem) {
      # Remove the place holder example if still present
      Get-HelpDocumentItem -Item "Example\" -CommandInfo $CommandInfo -XDocument $XDocument |
        Remove-HelpDocumentItem
      
      if ($Append) { 
        Get-HelpDocumentItem -Item Example -CommandInfo $CommandInfo -XDocument $XDocument |
          Where-Object { $_.Properties["title"] -eq $DocumentItem.Properties["title"] } |
          Remove-HelpDocumentItem
      } else {
        # Clear all examples
        Get-HelpDocumentItem -Item Example -CommandInfo $CommandInfo -XDocument $XDocument |
          Remove-HelpDocumentItem
      }
    
      AddXElement `
        -XElement $DocumentItem.XElement `
        -XContainer $XDocument `
        -Parent "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/command:examples"
    }
  }
}