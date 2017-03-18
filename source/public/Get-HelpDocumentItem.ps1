function Get-HelpDocumentItem {
  # .SYNOPSIS
  #   Get an item from an existing MAML help document.
  # .DESCRIPTION
  #   Get-HelpDocument element returns an object view of an element from an XML document.
  # .PARAMETER Path
  #   A path to an existing XML document.
  # .PARAMETER Template 
  #   Use the help document template as the working file.
  # .PARAMETER XDocument
  #   An in-memory XDocument to work on.
  # .PARAMETER Item
  #   The help item to return. This needs tab expansion.
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     04/12/2015 - Chris Dent - Fixed the notes and synopsis searchers.
  #     14/11/2015 - Chris Dent - Created.

  [CmdletBinding()]
  [OutputType([Indented.PowerShell.Help.DocumentItem])]
  param(
    [Parameter(Position = 1)]
    [String]$Item = 'All',

    [ValidateNotNullOrEmpty()]
    [System.Management.Automation.CommandInfo]$CommandInfo,

    [System.String]$Path,

    [System.Xml.Linq.XDocument]$XDocument,
    
    [Switch]$Template
  )
  
  begin {
    $XDocument = GetHelpXDocument @psboundparameters
  }
  
  process {
    $CommandElements = $XDocument.Element('helpItems').
                                  Elements((GetXNamespace 'command') + 'command').
                                  Where( {
                                    $CommandName = $_.Element((GetXNamespace 'command') + 'details').
                                                      Element((GetXNamespace 'command') + 'name').
                                                      Value
                                    -not $psboundparameters.ContainsKey('CommandInfo') -or $CommandName -eq $CommandInfo.Name
                                  } )

    $CommandElements |
      ForEach-Object {
        $XElement = $_

        $CommandName = $XElement.Element((GetXNamespace 'command') + 'details').
                                 Element((GetXNamespace 'command') + 'name').
                                 Value
        if (-not $psboundparameters.ContainsKey('CommandInfo') -and $CommandName -ne '') {
          $CommandInfo = Get-Command $CommandName
        }

        # Start by retrieving each element considered interesting
        $ExampleTitle = $InputTypeName = $OutputTypeName = $ParameterName = $ParameterSetName = '*'
        switch -RegEx ($Item) {
          '^(Details|All)$' {
            New-Object Indented.PowerShell.Help.DocumentItem(
              'Details',
              $CommandInfo,
              $XElement.Element((GetXNamespace 'command') + 'details')
            )
          }
          '^(Description|All)$' {
            New-Object Indented.PowerShell.Help.DocumentItem(
              'Description',
              $CommandInfo,
              $XElement.Element((GetXNamespace 'maml') + 'description')
            )
          }
          '^Example[\\/](?<ExampleTitle>.*)$' {
            $ExampleTitle = $matches.ExampleTitle
          }
          '^Example|^All$' {
            $XElement.Element((GetXNamespace 'command') + 'examples').
                      Elements((GetXNamespace 'command') + 'example').
                      Where( { $_.Element((GetXNamespace 'maml') + 'title').Value -like $ExampleTitle } ).
                      ForEach( {
                        New-Object Indented.PowerShell.Help.DocumentItem(
                          "Example",
                          $CommandInfo,
                          $_
                        )
                      } )
          }
          '^Inputs[\\/](?<TypeName>.+)$' {
            $InputTypeName = $matches.TypeName
          }
          '^Inputs|^All$' {
            $XElement.Element((GetXNamespace 'command') + 'inputTypes').
                      Elements((GetXNamespace 'command') + 'inputType').
                      Where( { $_.Element((GetXNamespace 'dev') + 'type').
                                  Element((GetXNamespace 'maml') + 'name').
                                  Value -like $InputTypeName } ).
                      ForEach( {
                        New-Object Indented.PowerShell.Help.DocumentItem(
                          'Inputs',
                          $CommandInfo,
                          $_
                        )
                      } )
          }
          '^(Links|All)$' {
            $XElement.Element((GetXNamespace 'maml') + 'relatedLinks').
                      Elements((GetXNamespace 'maml') + 'navigationLink').
                      Where( { $_.Element((GetXNamespace 'maml') + 'linkText').Value -ne '' } ).
                      ForEach( {
                        New-Object Indented.PowerShell.Help.DocumentItem(
                          'Links',
                          $CommandInfo,
                          $_
                        )
                      } )
          }
          '^(Notes|All)$' {
            # It'd be good to provide this as a single block of text and work with everything else in the background.
            $XElement.Element((GetXNamespace 'maml') + 'alertSet').
                      Elements((GetXNamespace 'maml') + 'alert').
                      ForEach( {
                        New-Object Indented.PowerShell.Help.DocumentItem(
                          'Notes',
                          $CommandInfo,
                          $_
                        )
                      } )
          }
          '^Outputs[\\/](?<TypeName>.+)$' {
            $OutputTypeName = $matches.TypeName
          }
          '^Outputs|^All$' {
            $XElement.Element((GetXNamespace 'command') + 'returnValues').
                      Elements((GetXNamespace 'command') + 'returnValue').
                      Where( { $_.Element((GetXNamespace 'dev') + 'type').
                                  Element((GetXNamespace 'maml') + 'name').
                                  Value -like $OutputTypeName
                      } ).
                      ForEach( {
                        New-Object Indented.PowerShell.Help.DocumentItem(
                          'Outputs',
                          $CommandInfo,
                          $_
                        )
                      } )
          }
          '^Parameter[\\/](?<ParameterName>.+)$' {
            $ParameterName = $matches.ParameterName 
          }
          '^Parameter|^All$' {
            $XElement.Element((GetXNamespace 'command') + 'parameters').
                      Elements((GetXNamespace 'command') + 'parameter').
                      Where( { $_.Element((GetXNamespace 'maml') + 'name').Value -like $ParameterName } ).
                      ForEach( {
                        New-Object Indented.PowerShell.Help.DocumentItem(
                          'Parameter',
                          $CommandInfo,
                          $_
                        )
                      } )
          }
          '^(Synopsis|All)$' {
            New-Object Indented.PowerShell.Help.DocumentItem(
              'Synopsis',
              $CommandInfo,
              $XElement.Element((GetXNamespace 'command') + 'details').
                        Element((GetXNamespace 'maml') + 'description')
            )
          }
          '^Syntax[\\/](?<ParameterSetName>.+)$' {
            $ParameterSetName = $matches.ParameterSetName
            $ParameterName = '*'
          }
          '^Syntax[\\/](?<ParameterSetName>[^\\/]+)[\\/](?<ParameterName>.*)$' {
            $ParameterSetName = $matches.ParameterSetName
            $ParameterName = $matches.ParameterName
          }
          '^Syntax|^All$' {
            # This will either present a numeric parameter set index or a name if the help file was generated by this
            $Syntax = $XElement.Element((GetXNamespace 'command') + 'syntax')
            $CurrentNode = $Syntax.FirstNode
            $i = 0
            do {
              if ($CurrentNode -is [System.Xml.Linq.XComment]) {
                $CurrentParameterSetName = $CurrentNode.Value
                $CurrentNode = $CurrentNode.NextNode
              } else {
                $CurrentParameterSetName = $i
              }
              if ($CurrentParameterSetName -like $ParameterSetName) {
                # Process the syntax items
                $CurrentNode.Elements((GetXNamespace 'command') + 'parameter').
                             ForEach( {
                               $DocumentItem = New-Object Indented.PowerShell.Help.DocumentItem(
                                 'Syntax',
                                 $CommandInfo,
                                 $_
                               )
                               $DocumentItem.ItemName = "Syntax\{0}\{1}" -f $CurrentParameterSetName, $DocumentItem.Properties["name"]
                               if ($DocumentItem.Properties['name'] -like $ParameterName) {
                                 $DocumentItem
                               }
                             } )
              }

              # Get the next node
              $CurrentNode = $CurrentNode.NextNode
              $i++
            } until ($CurrentNode -eq $null)
          }
        }
      }
  }
}