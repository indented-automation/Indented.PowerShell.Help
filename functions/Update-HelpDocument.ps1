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
  # .PARAMETER Append
  #   Valid when adding Links, Outputs and Examples.
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
   
  [CmdletBinding(DefaultParameterSetName = 'FromXDocument')]
  param(
    [ValidateNotNullOrEmpty()]
    [String]$Item = 'All',
    
    [Object[]]$Value,

    [Parameter(ValueFromPipeline = $true)]
    [System.Management.Automation.CommandInfo]$CommandInfo,
    
    [Parameter(Mandatory = $true, ParameterSetName = 'FromPath')]
    [String]$Path,

    [Parameter(ParameterSetName = 'FromXDocument')]
    [System.Xml.Linq.XDocument]$XDocument
  )
  
  begin {
    $XDocument = GetHelpXDocument @psboundparameters
  }
  
  process {
    if (-not $psboundparameters.ContainsKey('CommandInfo')) {
      # Harvest commands from the help document.
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
      # Ensure the command is present in the help file.
      if (-not (SelectXPathXElement -XPathExpression "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']" -XContainer $XDocument)) {
        $XDocument = AddHelpCommandElement $CommandInfo -XDocument $XDocument
      }
      $CommonParams = @{
        CommandInfo = $CommandInfo
        XDocument   = $XDocument 
      }
      switch -regex ($Item) {
        '^(Syntax|All)$' {
          Write-Verbose "$($CommandInfo.Name): Updating syntax section"
          $XDocument = UpdateHelpSyntax @CommonParams
        }
        '^(Parameter|All)$' {
          Write-Verbose "$($CommandInfo.Name): Updating parameters section"
          $XDocument = UpdateHelpParameter @CommonParams
        }
        '^(Inputs|All)$' {
          Write-Verbose "$($CommandInfo.Name): Updating inputs section"
          $XDocument = UpdateHelpInput @CommonParams
        }
        '^(Outputs|All)$' {
          Write-Verbose "$($CommandInfo.Name): Updating outputs section"
          if ($psboundparameters.ContainsKey('Value')) {
            if ($Append) {
              $XDocument = UpdateHelpOutput $Value -Append @CommonParams
            } else {
              $XDocument = UpdateHelpOutput $Value @CommonParams
            }
          } else {
            $XDocument = UpdateHelpOutput @CommonParams
          }
        }
        '^Links$' {
          Write-Verbose "$($CommandInfo.Name): Updating links section"
          if ($Append) {
            $XDocument = UpdateHelpLink $Value -Append @CommonParams
          } else {
            $XDocument = UpdateHelpLink $Value @CommonParams
          }
        }
        '^Synopsis$' {
          Write-Verbose "$($CommandInfo.Name): Setting synopsis element"
          $XDocument = SetHelpFormattedText $Value `
            -XPathExpression "/helpItems/command:command/command:details[command:name='$($CommandInfo.Name)']/maml:description" `
            -XContainer $XDocument
        }
        '^Description$' {
          Write-Verbose "$($CommandInfo.Name): Setting description element"
          $XDocument = SetHelpFormattedText $Value `
            -XPathExpression "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/maml:description" `
            -XContainer $XDocument
        }
        '^Parameter[\\/](?<ParameterName>[^\\/]+)' {
          $ParameterName = $matches.ParameterName 
        }
        '^Parameter[\\/][^\\/]+$' {
          Write-Verbose "$($CommandInfo.Name): Updating parameters\parameter\$ParameterName element"
          $XDocument = UpdateHelpParameter -Name $ParameterName @CommonParams
        }
        '^Parameter[\\/][^\\/]+[\\/]Description$' {
          Write-Verbose "$($CommandInfo.Name): Setting description element for parameters\parameter\$ParameterName"
          $CommandInfo.Parameters.Values.Where( { $_.Name -like $ParameterName -and $_.Name -notin $ReservedParameterNames } ) |
            ForEach-Object {
              $XDocument = SetHelpFormattedText $Value `
                -XPathExpression "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/command:parameters/command:parameter[maml:name='$($_.Name)']/maml:description" `
                -XContainer $XDocument
            }
          break
        }
        '^Parameter[\\/][^\\/]+[\\/](?<ElementName>globbing|variableLength)$' {
          $ElementName = $matches.ElementName
          
          if ($Value -in 'true', 'false') {
            $Value = $Value.ToLower()
          } else {
            # Die, invalid argument 
          }
          $CommandInfo.Parameters.Values.Where( { $_.Name -like $ParameterName -and $_.Name -notin (GetReservedParameterNames) } ) |
            ForEach-Object {
              switch ($ElementName) {
                'globbing' {
                  Write-Verbose "$($CommandInfo.Name): Setting globbing attribute for parameters\parameter\$ParameterName"
                  $XDocument = SetHelpAttributeValue 'globbing' `
                    -Value $Value
                    -XPathExpression "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/command:parameters/command:parameter[maml:name='$($_.Name)']"
                    break
                }                    
                'variableLength' {
                  Write-Verbose "$($CommandInfo.Name): Setting variableLength attribute for parameters\parameter\$ParameterName"
                  $XDocument = SetHelpAttributeValue 'variableLength' `
                    -Value $Value
                    -XPathExpression "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/command:parameters/command:parameter[maml:name='$($_.Name)']"
                  $XDocument = SetHelpAttributeValue 'variableLength' `
                    -Value $Value
                    -XPathExpression "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/command:parameters/command:parameter[maml:name='$($_.Name)']/command:parameterValue"
                  break
                }
              }
            }
          break
        }
        'Example' {
          Write-Verbose "$($CommandInfo.Name): Updating examples element"
          if ($Append) {
            $XDocument = UpdateHelpExample $Value -Append @CommonParams
          } else {
            $XDocument = UpdateHelpExample $Value @CommonParams
          }
        }
        default { Write-Error "The requested setting is not supported" }
      }
    }
  }
}