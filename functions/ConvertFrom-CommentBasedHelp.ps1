function ConvertFrom-CommentBasedHelp {
  # .SYNOPSIS
  #   Convert command-based help for a command into MAML help.
  # .DESCRIPTION
  #   ConvertFrom-CommentBasedHelp reads existing comment based help and writes the content to a MAML help file.
  # .PARAMETER CommandInfo
  #   A FunctionInfo (derived from CommandInfo) object returned from either Get-Command or Get-FunctionInfo.
  # .PARAMETER Path
  # .PARAMETER XDocument
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
      Get-Command -Module $Module |
        Where-Object { $_.Name -in (Get-Module $Module).ExportedCommands.Keys } |
        ConvertFrom-CommentBasedHelp @psboundparameters
    }
  }
  
  process {
    if ($psboundparameters.ContainsKey('CommandInfo')) {
      $HelpContent = $CommandInfo.ScriptBlock.Ast.GetHelpContent()
      
      $CommonParams = @{
        CommandInfo = $CommandInfo
        XDocument   = $XDocument
      }
      
      Update-HelpDocument @CommonParams
      Update-HelpDocument -Item Synopsis -Value $HelpContent.Synopsis @CommonParams
      Update-HelpDocument -Item Description -Value $HelpContent.Description @CommonParams
      Update-HelpDocument -Item Links -Value $HelpContent.Links @CommonParams
      Update-HelpDocument -Item Example -Value $HelpContent.Examples @CommonParams
      # Update-HelpDocument -Item Notes -Value $HelpContent.Notes -XDocument $XDocument @CommonParams
    
      if ($HelpContent.Outputs) {
        # Update-HelpDocument -Item Outputs -Value $HelpContent.Outputs @CommonParams
      }
      $HelpContent.Parameters.Keys |
        ForEach-Object {
          Update-HelpDocument -Item "Parameter\$_\Description" -Value $HelpContent.Parameters[$_] @CommonParams
        }
    }
  }
}