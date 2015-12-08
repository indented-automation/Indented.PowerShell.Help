function ConvertFrom-CommentBasedHelp {
  # .SYNOPSIS
  #   Convert command-based help for a command into MAML help.
  # .DESCRIPTION
  #   ConvertFrom-CommentBasedHelp reads existing comment based help and writes the content to a MAML help file.
  #
  #   Parsing of items that cannot be discovered, such as the free-form text in descriptive fields is best effort. All content should be checked after conversion.
  # .PARAMETER CommandInfo
  #   A FunctionInfo (derived from CommandInfo) object returned from either Get-Command or Get-FunctionInfo.
  # .PARAMETER Path
  #   The path to the help document. If a help document does not exist at the specified path it will be created.
  # .PARAMETER XDocument
  #   All help entries will be written to the existing XDocument object. The modified XDocument will be returned by this command.
  # .INPUTS
  #   System.Management.Automation.FunctionInfo
  #   System.String
  #   System.Xml.Linq.XDocument
  # .OUTPUTS
  #   System.Xml.Linq.XDocument
  # .EXAMPLE
  #   ConvertFrom-CommentBasedHelp -CommandInfo (Get-Command Update-HelpDocument)
  #
  #   Update or add help for Update-HelpDocument to an active help document.
  # .EXAMPLE
  #   ConvertFrom-CommentBasedHelp -Module Indented.PowerShell.Help
  #
  #   Convert all comment based help in the module Indented.PowerShell.Help to MAML.
  # .EXAMPLE
  #   ConvertFrom-CommentBasedHelp -CommandInfo (Get-Command Update-HelpDocument) -Path C:\Indented.PowerShell.Help-help.xml
  #
  #   Convert from comment based help and write the generated help content to the specified path.
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     14/11/2015 - Chris Dent - Created.

  [CmdletBinding(DefaultParameterSetName = 'FromCommandInfo')]
  param(
    [Parameter(ParameterSetName = 'FromCommandInfo', ValueFromPipeline = $true)]
    [System.Management.Automation.FunctionInfo]$CommandInfo,
   
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
      # This is a messy work-around.
      $XDocument = Get-Command -Module $Module |
        Where-Object { $_.Name -in (Get-Module $Module).ExportedCommands.Keys } |
        ConvertFrom-CommentBasedHelp @psboundparameters -XDocument $XDocument
    }
  }
  
  process {
    if ($psboundparameters.ContainsKey('CommandInfo')) {
      $CommonParams = @{
        CommandInfo = $CommandInfo
        XDocument   = $XDocument
      }
      
      Update-HelpDocument @CommonParams

      $HelpContent = $CommandInfo.ScriptBlock.Ast.GetHelpContent()
      if ($HelpContent) {
        Update-HelpDocument -Item Synopsis -Value $HelpContent.Synopsis @CommonParams
        Update-HelpDocument -Item Description -Value $HelpContent.Description @CommonParams

        $HelpContent.Parameters.Keys |
          ForEach-Object {
            Update-HelpDocument -Item "Parameter\$_\Description" -Value $HelpContent.Parameters[$_] @CommonParams
          }

        if ($HelpContent.Examples) {
          $i = 1
          $HelpContent.Examples |
            ForEach-Object {
              $Example = New-HelpExample $_ -Title "Example $i"
              Update-HelpDocument -Item Example -Value $Example -Append @CommonParams
              $i++
            }
        }
        if ($HelpContent.Links) {
          # Update-HelpDocument -Item Links -Value $HelpContent.Links @CommonParams
        }
        if ($HelpContent.Notes) {
          Update-HelpDocument -Item Notes -Value $HelpContent.Notes @CommonParams
        }
        if ($HelpContent.Outputs) {
          # Update-HelpDocument -Item Outputs -Value $HelpContent.Outputs @CommonParams
        }
      }
    }
  }
  
  end {
    if ($psboundparameters.ContainsKey('Path')) {
      $XDocument.Save($Path, [System.Xml.Linq.SaveOptions]::OmitDuplicateNamespaces)
    } elseif ($psboundparameters.ContainsKey('XDocument')) {
      return $XDocument
    }
  }
}