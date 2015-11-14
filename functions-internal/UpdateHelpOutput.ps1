function UpdateHelpOutput {
  # .EXTERNALHELP Indented.PowerShell.Help-Help.xml

  [CmdletBinding()]
  [OutputType([System.Xml.Linq.XDocument])]
  param(
    $Output,

    [Parameter(Mandatory = $true)]
    [System.Management.Automation.CommandInfo]$CommandInfo,

    [Parameter(Mandatory = $true)]
    [System.Xml.Linq.XDocument]$XDocument,
    
    [Switch]$Append
  )

  if (-not $psboundparameters.ContainsKey('Output')) {
    if ($CommandInfo.OutputType) {
      $Output = $CommandInfo.OutputType.Type
    }
    if (-not $Output) {
      Write-Verbose "    Command either does not declare output types or has no output. Clearing returnValues\returnValue"
    }
  }
  if ($Output -eq $null) {
    SelectXPathXElement `
        -XPathExpression "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/command:returnValues/command:returnValue" `
        -XContainer $XDocument |
      ForEach-Object {
        $_.Remove() 
      }
      # Re-insert the empty value from the template.
      GetTemplateXElement 'command:returnValues/command:returnValue' |
        AddXElement -XContainer $XDocument -Parent "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/command:returnValues"
  } else {
    if ($Output -is [Type]) {
      $FullName = $Output.FullName
    } else {
      $FullName = $Output
    }

    # Remove any 'None' elements
    SelectXPathXElement `
        -XPathExpression "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/command:returnValues/command:returnValue[dev:type/maml:name='None']" `
        -XContainer $XDocument |
      ForEach-Object {
        $_.Remove() 
      }
    
    if ($Append) {
      # Check if the specified Output has already been added.
      
    } else {
      # Clear down Output

      $Output |
        ForEach-Object {
          Write-Verbose "    Creating returnValues\returnValue element for $FullName"
  
          $OutputTypeXElement = GetTemplateXElement 'command:returnValues/command:returnValue'
          $OutputTypeXElement.Element((GetXNamespace 'dev') + 'type').Element((GetXNamespace 'maml') + 'name').Value = $FullName
          
          $OutputTypeXElement
        } |
        AddXElement -XContainer $XDocument `
          -Parent "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/command:returnValues" `
          -SortBy './dev:type/maml:name'
    }
  }
}