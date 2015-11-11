function Update-HelpDocument {
  # .SYNOPSIS
  #   Update a help document.
  # .DESCRIPTION
  # .PARAMETER CommandInfo
  #   Update the help entry for the specified command.
  # .PARAMETER Item
  #   The item to update. Item is a path-like structure which is used to denote the item to update.
  # .PARAMETER Value
  #
  # .EXAMPLE
  #   Update-HelpDocument -Command ... -Item Parameter\SomeParam\Description -Value '...'
  #   Update-HelpDocument -Command ... -Item Parameter\(SomeParam)Description -Value '...'
  #
  #   Description for a specific parameter and a specific command
  # .EXAMPLE
  #   Update-HelpDocument -Command ... -Item Parameter\SomeParam\Globbing -Value $true
  #
  #   Globbing for a specific parameter and specific command
  # .EXAMPLE
  #   Update-HelpDocument -Item Parameter\SomeParam\Globbing -Value $true
  # 
  #   Globbing for all instances of Parameter (all commands).
  # .EXAMPLE
  #   Update-HelpDocument -Command ... -Item Synopsis -Value '...'
  #
  #   Synopsis for a particular command.
  # .EXAMPLE
  #   Update-HelpDocument -Item Parameter
  # 
  #   All parameter instances (filled from CommandInfo)
  # .EXAMPLE
  #   Update-HelpDocument -Item Syntax
  #
  #   All Syntax instances (filled from CommandInfo)
  # .EXAMPLE
  #   Update-HelpDocument -Item Inputs
  #
  #   All Inputs (filled from CommandInfo)
  # .EXAMPLE
  #   Update-HelpDocument -CommandInfo ... -Item Outputs -Value [Type1], [Type2]
  #
  #   Outputs - Manual
  # .EXAMPLE
  #   Update-HelpDocument -CommandInfo ... -Item Outputs
  #
  #   Outputs - Discover
  # .EXAMPLE
  #   Update-HelpDocument -CommandInfo ... -Item Links -Value 'Value1', 'Value2'
  #
  #   Links
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     11/11/2015 - Chris Dent - Created.
   
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [String]$Item = 'All',
    
    [Object[]]$Value,

    [Parameter(ValueFromPipeline = $true)]
    [System.Management.Automation.CommandInfo]$CommandInfo,
    
    [Parameter(ParameterSetName = 'FromPath')]
    [String]$Path,

    [Parameter(ParameterSetName = 'FromXDocument')]
    [System.Xml.Linq.XDocument]$XDocument
  )
  
  begin {
    $XDocument = GetHelpXDocument @psboundparameters
  }
  
  process {
    if (-not $psboundparameters.ContainsKey('CommandInfo')) {
      # Attempt to harvest commands from the help document itself.
      $XDocument.Element('helpItems').`
                 Elements((GetXNamespace 'command') + 'command') |
                 ForEach-Object {
                   $CommandName = $_.Element((GetXNamespace 'command') + 'details').`
                      Element((GetXNamespace 'command') + 'name').`
                      Value
                   Get-Command $CommandName | Update-HelpDocument @psboundparameters
                 }
    }

    if ($psboundparameters.ContainsKey('CommandInfo')) {
      switch -regex ($Item) {
        '^(Synopsis|All)' {
          SetHelpFormattedText `
            -Text $Value `
            -XPathExpression "/helpItems/command:command/command:details[command:name='$($CommandInfo.Name)']/maml:description" `
            -XDocument $XDocument
        }
        '^(Parameter|All)' {
          # It would be odd to specify the same description across every parameter instance.
          # Perhaps don't support other operations against description?
          if ($Item -match 'Parameter[\\/](?<ParameterName>.+)[\\/]Description$') {
            $ParameterName = $matches.ParameterName
            if ($ParameterName.IndexOf('*') -ne -1) {
              # Wildcard search for the parameter
            } else {
              $x.Element('helpItems').Element((GetXNamespace 'command') + 'command').Where( { $_.Element((GetXNamespace 'command')
 + 'details').Element((GetXNamespace 'command') + 'name').Value -eq 'Get-Process' } )
              
              # Watch for case sensitivity here. The expression is going to get really ugly.
              $XDocument.Element('helpItems').`
                         Element((GetXNamespace 'command') + 'command').`
                         Where( {
                           $ThisValue = $_.Element((GetXNamespace 'command') + 'details').`
                              Element((GetXNamespace 'command') + 'name').`
                              Value
                           $ThisValue -eq '...'
                         } )
              
              SetHelpFormattedText `
                -Text $Value `
                -XPathExpression "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/command:parameters/command:parameter[maml:name='$ParameterName']/maml:description" `
                -XDocument $XDocument
          } else {
            # Need a means of getting something from the existing document. 
          }
          
        }
        '^(Syntax|All)'    { }
        '^(Inputs|All)'    { }
        '^(Outputs|All)'   { }
        '^(Links|All)'     { }
      }
    }
  }  
}