function Update-HelpDocument {
  # .SYNOPSIS
  #   Update a help document.
  # .DESCRIPTION
  #   Update-HelpDocument attempts to construct and write individual items of a help document.
  #
  #   The following items are automatically populated and may not require manual updating:
  #
  #     * Detail (except Synopsis)
  #     * Syntax
  #     * Parameters (except description, globbing and variableLength)
  #     * Inputs
  #     * Outputs (where an OutputType attribute is defined)
  #
  #   The remaining items require additional information which can by supplied using the Value parameter:
  #
  #     * Synopsis
  #     * Description
  #     * Parameter descriptions
  #     * Inputs (where remarks are desired)
  #     * Outputs (without an OutputType attribute, or where remarks are desired)
  #     * Links
  #     * Notes
  #
  #   All manually set items can be drawn from comment-based help. Content translation is best effort.
  #
  #   Where manually updating a section the value supplied may be:
  #
  #     * A string representing the intended value
  #     * A Indented.PowerShell.Help.DocumentItem object created by one of the item creation functions (New-Help<Item>).
  #
  #   The order the elements appear in the file is dictated by the Schema and occasionally by how help is displayed. For example, syntax must be presented in the same order as the param block. Where order is not dictated by either the schema or usage items are inserted in alphabetical order.
  #
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
   
  [CmdletBinding(DefaultParameterSetName = 'FromDocument')]
  [OutputType([System.Xml.Linq.XDocument])]
  param(
    [ValidateNotNullOrEmpty()]
    [String]$Item = 'All',
    
    $Value,

    [Switch]$Append,

    [Parameter(ParameterSetName = 'FromCommandInfo', ValueFromPipeline = $true)]
    $CommandInfo,
    
    [Parameter(ParameterSetName = 'FromModule')]
    [String]$Module,
    
    [String]$Path,

    [System.Xml.Linq.XDocument]$XDocument
  )
  
  begin {
    $XDocument = GetHelpXDocument @psboundparameters
    
    if ($pscmdlet.ParameterSetName -eq 'FromModule') {
      $null = $psboundparameters.Remove('Module')
      # If this is documenting itself it can find functions which are not exported as well.
      Get-Command -Module $Module |
        Where-Object { $_.Name -in (Get-Module $Module).ExportedCommands.Keys } |
        Update-HelpDocument @psboundparameters
    }

    if ($pscmdlet.ParameterSetName -eq 'FromDocument') {
      # Harvest commands from the help document.
      $XDocument.Element('helpItems').`
                 Elements((GetXNamespace 'command') + 'command').`
                 ForEach( {
                   $CommandName = $_.Element((GetXNamespace 'command') + 'details').`
                      Element((GetXNamespace 'command') + 'name').`
                      Value
                   Get-Command $CommandName 
                 } ) |
                 Update-HelpDocument @psboundparameters
    }
  }
  
  process {
    if ($psboundparameters.ContainsKey('CommandInfo')) {
      $CommandInfo = Get-CommandInfo $CommandInfo
      if ($CommandInfo) {
        Write-Verbose "Update-HelpDocument: $($CommandInfo.Name)"
  
        $CommonParams = @{
          CommandInfo = $CommandInfo
          XDocument   = $XDocument 
        }
              
        # Ensure the command is present in the help file.
        if (-not (SelectXPathXElement -XPathExpression "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']" -XContainer $XDocument)) {
          AddHelpCommandElement @CommonParams
        }
        switch -regex ($Item) {
          '^Description$' {
            Write-Verbose "  Setting description element"
            SetHelpFormattedText $Value `
              -XPathExpression "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/maml:description" `
              -XContainer $XDocument
          }        
          '^Example$' {
            Write-Verbose "  Updating examples element"
            if ($Append) {
              UpdateHelpExample $Value -Append @CommonParams
            } else {
              UpdateHelpExample $Value @CommonParams
            }
          }
          '^(Inputs|All)$' {
            Write-Verbose "  Updating inputs element"
            UpdateHelpInput @CommonParams
          }
          '^Links$' {
            Write-Verbose "  Updating links element"
            if ($Append) {
              UpdateHelpLink $Value -Append @CommonParams
            } else {
              UpdateHelpLink $Value @CommonParams
            }
          }
          '^Notes$' {
            SetHelpFormattedText $Value `
              -XPathExpression "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/maml:alertSet/maml:alert" `
              -XContainer $XDocument
          }
          '^(Outputs|All)$' {
            Write-Verbose "  Updating outputs element"
            if ($psboundparameters.ContainsKey('Value')) {
              if ($Append) {
                UpdateHelpOutput $Value -Append @CommonParams
              } else {
                UpdateHelpOutput $Value @CommonParams
              }
            } else {
              UpdateHelpOutput @CommonParams
            }
          }
          '^Synopsis$' {
            Write-Verbose "  Setting synopsis element"
            SetHelpFormattedText $Value `
              -XPathExpression "/helpItems/command:command/command:details[command:name='$($CommandInfo.Name)']/maml:description" `
              -XContainer $XDocument
          }
          '^(Syntax|All)$' {
            Write-Verbose "  Updating syntax element"
            UpdateHelpSyntax @CommonParams
          }
          '^(Parameter|All)$' {
            Write-Verbose "  Updating parameters element"
            UpdateHelpParameter @CommonParams
          }
          '^Parameter[\\/](?<ParameterName>[^\\/]+)' {
            $ParameterName = $matches.ParameterName 
          }
          '^Parameter[\\/][^\\/]+$' {
            Write-Verbose "  Updating parameters\parameter\$ParameterName element"
            UpdateHelpParameter -Name $ParameterName @CommonParams
          }
          '^Parameter[\\/][^\\/]+[\\/]Description$' {
            Write-Verbose "  Setting description element for parameters\parameter\$ParameterName"
            $CommandInfo.Parameters.Values.Where( { $_.Name -like $ParameterName -and $_.Name -notin $ReservedParameterNames } ) |
              ForEach-Object {
                SetHelpFormattedText $Value `
                  -XPathExpression "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/command:parameters/command:parameter[maml:name='$($_.Name)']/maml:description" `
                  -XContainer $XDocument
              }
            break
          }
          '(globbing|variableLength)$' {
            if ($Value -in 'true', 'false') {
              $Value = $Value.ToLower()
            } else {
              # Die, invalid argument 
            }
          }
          '^Parameter[\\/][^\\/]+[\\/]globbing$' {
            $CommandInfo.Parameters.Values.Where( { $_.Name -like $ParameterName -and $_.Name -notin (GetReservedParameterNames) } ) |
              ForEach-Object {
                Write-Verbose "  Setting globbing attribute for parameters\parameter\$ParameterName"
                SetHelpAttributeValue 'globbing' `
                  -Value $Value
                  -XPathExpression "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/command:parameters/command:parameter[maml:name='$($_.Name)']"
              }                    
            break
          }
          'Parameter[\\/][^\\/]+[\\/]variableLength$' {
            $CommandInfo.Parameters.Values.Where( { $_.Name -like $ParameterName -and $_.Name -notin (GetReservedParameterNames) } ) |
              ForEach-Object {
                Write-Verbose "  Setting variableLength attribute for parameters\parameter\$ParameterName"
                SetHelpAttributeValue 'variableLength' `
                  -Value $Value
                  -XPathExpression "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/command:parameters/command:parameter[maml:name='$($_.Name)']"
                SetHelpAttributeValue 'variableLength' `
                  -Value $Value
                  -XPathExpression "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/command:parameters/command:parameter[maml:name='$($_.Name)']/command:parameterValue"
              }                  
            break
          }
          default { Write-Error "The requested setting is not supported" }
        }
      }
    }
  }
}