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
  
  [CmdletBinding()]
  [OutputType([System.Management.Automation.PSObject])]
  param(
    [Parameter(Mandatory = $true, Position = 1)]
    [ValidateSet('Command', 'Description', 'Example', 'Inputs', 'Links', 'Outputs', 'Synopsis', 'Syntax', 'Parameter')]
    [String]$Item,

    [Parameter(Mandatory = $true, Position = 2)]
    [System.Management.Automation.CommandInfo]$CommandInfo,

    [System.Xml.Linq.XDocument]$XDocument,
    
    [System.String]$Path
  )
  
  begin {
    $XDocument = GetHelpXDocument @psboundparameters
    
    $XPathExpression = switch ($Item) {
      'Command'      { "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']"; break }
      'Description'  { "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/maml:description"; break }
      'Example'      { "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/command:examples"; break }
      'Inputs'       { "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/command:inputTypes"; break }
      'Links'        { "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/command:links"; break }
      'Outputs'      { "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/command:returnTypes"; break }
      'Synopsis'     { "/helpItems/command:command/command:details[command:name='$($CommandInfo.Name)']/maml:description"; break }
      'Syntax'       { "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/command:syntax"; break }
      'Parameter'    { "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/command:parameters"; break }
    }
    
    SelectXPathXElement -XPathExpression $XPathExpression -XContainer $XDocument |
      ForEach-Object {
        switch ($Item) {
          'Command' {
            [PSCustomObject]@{
              
            }
          } 
        }
        
      }
  }
}