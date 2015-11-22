function Get-HelpDocumentItem {
  # .SYNOPSIS
  #   Get an item from an existing MAML help document.
  # .DESCRIPTION
  #   Get-HelpDocument element returns an object view of an element from an XML document.
  # .PARAMETER XDocument
  # .PARAMETER Item
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     14/11/2015 - Chris Dent - Created.

  [CmdletBinding()]
  [OutputType([Indented.Help.Document.Item])]
  param(
    [Parameter(Position = 1)]
    [String]$Item = 'All',

    [ValidateNotNullOrEmpty()]
    [System.Management.Automation.CommandInfo]$CommandInfo,

    [System.String]$Path,

    [System.Xml.Linq.XDocument]$XDocument
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
        if (-not $psboundparameters.ContainsKey('CommandInfo')) {
          $CommandInfo = Get-Command $CommandName
        }

        # Start by retrieving each element considered interesting
        $InputTypeName = $OutputTypeName = $ParameterName = $ParameterSetName = '*'
        switch -RegEx ($Item) {
          '^(Details|All)$' {
            $DocumentItem = New-Object Indented.PowerShell.Help.DocumentItem(
              'Details',
              $CommandInfo,
              $XElement.Element((GetXNamespace 'command') + 'details')
            )
            $DocumentItem.Properties = @{
              name = $DocumentItem.XElement.Element((GetXNamespace 'command') + 'name').Value
              verb = $DocumentItem.XElement.Element((GetXNamespace 'command') + 'verb').Value
              noun = $DocumentItem.XElement.Element((GetXNamespace 'command') + 'noun').Value
            }
            $DocumentItem
          }
          '^(Description|All)$' {
            $DocumentItem = New-Object Indented.PowerShell.Help.DocumentItem(
              'Description',
              $CommandInfo,
              $XElement.Element((GetXNamespace 'maml') + 'description')
            )
            $DocumentItem.Properties = @{
              'para' = $DocumentItem.XElement.Elements((GetXNamespace 'maml') + 'para').
                                              ForEach( { $_.Value } )
            }
            $DocumentItem
          }
          '^(Example|All)$' {
            $i = 1
            $XElement.Element((GetXNamespace 'command') + 'examples').
                      Elements((GetXNamespace 'command') + 'example').
                      ForEach( {
                        $DocumentItem = New-Object Indented.PowerShell.Help.DocumentItem(
                          "Example\$i",
                          $CommandInfo,
                          $_
                        )
                        # Properties
                        $DocumentItem
                        $i++
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
                        $DocumentItem = New-Object Indented.PowerShell.Help.DocumentItem(
                          'Inputs',
                          $CommandInfo,
                          $_
                        )
                        $DocumentItem.Properties = @{
                          'name'        = $DocumentItem.XElement.Element((GetXNamespace 'dev') + 'type').
                                                                 Element((GetXNamespace 'maml') + 'name').
                                                                 Value
                          'description' = $DocumentItem.XElement.Element((GetXNamespace 'maml') + 'description').Value
                        }
                        $DocumentItem.ItemName = "Inputs\$($DocumentItem.Properties['name'])"
                        $DocumentItem
                      } )
          }
          '^(Links|All)$' {
            $XElement.Element((GetXNamespace 'maml') + 'relatedLinks').
                      Elements((GetXNamespace 'maml') + 'navigationLink').
                      Where( { $_.Element((GetXNamespace 'maml') + 'linkText').Value -ne '' } ).
                      ForEach( {
                        $DocumentItem = New-Object Indented.PowerShell.Help.DocumentItem(
                          'Links',
                          $CommandInfo,
                          $_
                        )
                        $DocumentItem.Properties = @{
                          'linkText' = $DocumentItem.XElement.Element((GetXNamespace 'maml') + 'linkText').Value
                          'uri'      = $DocumentItem.XElement.Element((GetXNamespace 'maml') + 'uri').Value
                        }
                        $DocumentItem.ItemName = "Outputs\$($DocumentItem.Properties['LinkText'])"
                        $DocumentItem
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
                        $DocumentItem = New-Object Indented.PowerShell.Help.DocumentItem(
                          'Outputs',
                          $CommandInfo,
                          $_
                        )
                        $DocumentItem.Properties = @{
                          'name'        = $DocumentItem.XElement.Element((GetXNamespace 'dev') + 'type').
                                                                 Element((GetXNamespace 'maml') + 'name').
                                                                 Value
                          'description' = $DocumentItem.XElement.Element((GetXNamespace 'maml') + 'description').Value
                        }
                        $DocumentItem.ItemName = "Outputs\$($DocumentItem.Properties['name'])"
                        $DocumentItem
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
                        $DocumentItem = New-Object Indented.PowerShell.Help.DocumentItem(
                          'Parameter',
                          $CommandInfo,
                          $_
                        )
                        $DocumentItem.Properties = @{
                          'name'           = $DocumentItem.XElement.Element((GetXNamespace 'maml') + 'name').Value
                          'description'    = $DocumentItem.XElement.Element((GetXNamespace 'maml') + 'description').Value
                          'parameterValue' = $DocumentItem.XElement.Element((GetXNamespace 'command') + 'parameterValue').Value
                          'globbing'       = $DocumentItem.XElement.Attribute('globbing').Value
                          'pipelineInput'  = $DocumentItem.XElement.Attribute('pipelineInput').Value
                          'position'       = $DocumentItem.XElement.Attribute('position').Value
                          'required'       = $DocumentItem.XElement.Attribute('required').Value
                          'variableLength' = $DocumentItem.XElement.Attribute('variableLength').Value
                        }
                        $DocumentItem.ItemName = "Parameter\$($DocumentItem.Properties['name'])"
                        $DocumentItem
                      } )
          }
          '^(Synopsis|All)$' {
            $DocumentItem = New-Object Indented.PowerShell.Help.DocumentItem(
              'Synopsis',
              $CommandInfo,
              $XElement.Element((GetXNamespace 'command') + 'details').
                        Element((GetXNamespace 'maml') + 'description')
            )
            $DocumentItem.Properties = @{
              'para' = $DocumentItem.XElement.Elements((GetXNamespace 'maml') + 'para').
                                              ForEach( { $_.Value } )
            }
            $DocumentItem
          }
          '^Syntax[\\/](?<ParameterSetName>.+)$' {
            $ParameterSetName = $matches.ParameterSetName
            $ParameterName = '*'
          }
          '^Syntax[\\/](?<ParameterSetName>[^\\/]+)[\\/](?<ParameterName>.+)$' {
            $ParameterSetName = $matches.ParameterSetName
            $ParameterName = $matches.ParameterName
          }
          '^(Syntax|All)$' {
            # This will either present a numeric parameter set index or a name if the help file was generated by this
            $Syntax = $XElement.Element((GetXNamespace 'command') + 'syntax')
            if ($Syntax.FirstNode -is [System.Xml.Linq.XComment]) {
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
                                 $DocumentItem.Properties = @{
                                   'name'           = $DocumentItem.XElement.Element((GetXNamespace 'maml') + 'name').Value
                                   'parameterValue' = $DocumentItem.XElement.Where( { $_.Element((GetXNamespace 'command') + 'parameterValue') } ).ForEach( { $_.Element((GetXNamespace 'command') + 'parameterValue').Value } )
                                   'globbing'       = $DocumentItem.XElement.Attribute('globbing').Value
                                   'pipelineInput'  = $DocumentItem.XElement.Attribute('pipelineInput').Value
                                   'position'       = $DocumentItem.XElement.Attribute('position').Value
                                   'required'       = $DocumentItem.XElement.Attribute('required').Value
                                   'variableLength' = $DocumentItem.XElement.Attribute('variableLength').Value
                                 }
                                 $DocumentItem.ItemName = "Syntax\$ThisParameterSetName\$($DocumentItem.Properties['name'])"
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
}