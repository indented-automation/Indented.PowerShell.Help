function Get-HelpDocumentElement {
  # .SYNOPSIS
  #   Get an element from an existing MAML help document.
  # .DESCRIPTION
  #   Get-HelpDocument element returns an object view of an element from an XML document.
  # .PARAMETER XDocument
  # .PARAMETER Item
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     14/11/2015 - Chris Dent - Created.

  # This command potentially deprecates SelectXPathXElement. That should, perhaps, be the goal.
  
  [CmdletBinding()]
  [OutputType([System.Management.Automation.PSObject])]
  param(
    [Parameter(Mandatory = $true, Position = 1)]
    [ValidateSet('Command', 'Description', 'Example', 'Inputs', 'Links', 'Outputs', 'Synopsis', 'Syntax', 'Parameter')]
    [String]$Item,

    [System.Management.Automation.CommandInfo]$CommandInfo,

    [System.Xml.Linq.XDocument]$XDocument,
    
    [System.String]$Path
  )
  
  begin {
    $XDocument = GetHelpXDocument @psboundparameters
  }
  
  process {
    $CommandElements = $XDocument.Element('helpItems').`
                                  Elements((GetXNamespace 'command') + 'command').`
                                  Where( {
                                    $CommandName = $_.Element((GetXNamespace 'command') + 'details').`
                                                      Element((GetXNamespace 'command') + 'name').`
                                                      Value
                                                      
                                    -not $psboundparameters.ContainsKey('CommandInfo') -or $CommandName -eq $Command.Name
                                  } )

    $CommandElements |
      ForEach-Object {
        $XElement = $_

        $CommandName = $XElement.Element((GetXNamespace 'command') + 'details').
                                 Element((GetXNamespace 'command') + 'name').
                                 Value

        if ($Item -eq 'Parameter') {
          $Parameters = $XElement.Element((GetXNamespace 'command') + 'parameters').
                                  Elements((GetXNamespace 'command') + 'parameter')
          $Parameters |
            ForEach-Object {
              $Properties = @{}
              $_.Attributes() |
                ForEach-Object {
                  $Properties.Add($_.Name, $_.Value)
                }
              $Properties.Add(
                'Name',
                $_.Element((GetXNamespace 'maml') + 'name').Value
              )
              $Properties.Add(
                'Description',
                $_.Element((GetXNamespace 'maml') + 'description').
                   Where( { $_.Element((GetXNamespace 'maml') + 'para') } ).
                   ForEach( { $_.Value } )
              )
              $Properties.Add(
                'parameterValue',
                $_.Element((GetXNamespace 'command') + 'parameterValue').Value
              )
              [PSCustomObject]@{
                Name        = $CommandName
                Item        = $Item
                Properties  = $Properties
                CommandInfo = (Get-Command $CommandName)
                XElement    = $XElement
              } |
                Add-Member -TypeName 'Indented.PowerShell.Help.DocumentElement' -PassThru
            }
        } elseif ($Item -eq 'Syntax') {
          

        } else {
          $Properties = @{}

          switch ($Item) {
            'Command' {
              $Properties.Add('Name', $CommandName)
              $Properties.Add(
                'Synopsis',
                $XElement.Element((GetXNamespace 'command') + 'details').
                          Element((GetXNamespace 'maml') + 'description').
                          Elements((GetXNamespace 'maml') + 'para').
                          ForEach( { $_.Value } )
              )
              $Properties.Add(
                'Verb',
                $XElement.Element((GetXNamespace 'command') + 'details').
                          Element((GetXNamespace 'command') + 'verb').
                          Value
              )
              $Properties.Add(
                'Noun',
                $XElement.Element((GetXNamespace 'command') + 'details').
                          Element((GetXNamespace 'command') + 'verb').
                          Value
              )
              break
            }
            'Description' {
              $Properties.Add(
                'Description',
                $XElement.Element((GetXNamespace 'maml') + 'description').
                          Where( { $_.Element((GetXNamespace 'maml') + 'para') } ).
                          ForEach( { $_.Element((GetXNamespace 'maml') + 'para').Value } )
              )
              break
            }
            'Example' {
              break                                   
            }
            'Inputs' {
              $Properties.Add(
                'Type',
                $XElement.Element((GetXNamespace 'command') + 'inputTypes').
                          Element((GetXNamespace 'command') + 'inputType').
                          Element((GetXNamespace 'dev') + 'type').
                          Element((GetXNamespace 'maml') + 'name').
                          Value
              )
              break 
            }
            'Links' {
              break 
            }
            'Outputs' {
              $Properties.Add(
                'Type',
                $XElement.Element((GetXNamespace 'command') + 'returnValues').
                          Element((GetXNamespace 'command') + 'returnValue').
                          Element((GetXNamespace 'dev') + 'type').
                          Element((GetXNamespace 'maml') + 'name').
                          Value
              )
              break
            }
            'Synopsis' {
              $Properties.Add(
                'Description',
                $XElement.Element((GetXNamespace 'command') + 'details').
                          Element((GetXNamespace 'maml') + 'description').
                          Where( { $_.Element((GetXNamespace 'maml') + 'para') } ).
                          ForEach( { $_.Element((GetXNamespace 'maml') + 'para').Value } )
              )
              break
            }
          }
  
          [PSCustomObject]@{
            Name        = $CommandName
            Item        = $Item
            Properties  = $Properties
            CommandInfo = (Get-Command $CommandName)
            XElement    = $XElement
          } |
            Add-Member -TypeName 'Indented.PowerShell.Help.DocumentElement' -PassThru
        }
      }
  }
}