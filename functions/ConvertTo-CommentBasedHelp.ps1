function ConvertTo-CommentBasedHelp {
  # .SYNOPSIS
  #   Convert MAML to comment based help.
  # .DESCRIPTION
  #   Convert a MAML help document to comment based help.
  # .PARAMETER CommentStyle
  # .PARAMETER ElementStyle
  # .PARAMETER MaximumLineLength
  # .PARAMETER Path
  # .PARAMETER XDocument
  # .INPUTS
  #   System.String
  #   System.Xml.XDocument
  # .OUTPUTS
  #   TBC
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     14/11/2015 - Chris Dent - Created.

  [CmdletBinding()]
  [OutputType([System.String])]
  param(
    [System.Management.Automation.CommandInfo]$CommandInfo,

    [ValidateSet('Block', 'SingleLine')]
    [String]$CommentStyle = 'Block',

    [ValidateSet('LowerCase', 'UpperCase', 'PascalCase')]
    [String]$ElementStyle = 'PascalCase',
    
    [String]$IndentString = "`t",
    
    [Int32]$MaximumLineLength
  )

  process {
    if ($CommandInfo -isnot [System.Management.Automation.FunctionInfo]) {
      Write-Warning "$($CommandInfo.Name) is not a function."
    }
  
    $StringBuilder = New-Object System.Text.StringBuilder
  
    if ($CommentStyle -eq 'Block') {
      $null = $StringBuilder.AppendLine('<#')
      $LineFormat = '{0}{1}'
    } else {
      $LineFormat = '{0}#{1}'
    }
    
    $CommandMAML = SelectXPathXElement `
      -XPathExpression "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']" `
      -XContainer $XDocument
    
    # Tomorrow...
    
    # Synopsis
    
    #$Synopsis |
    #  ForEach-Object {
    #    $StringBuilder.AppendLine((
    #      $LineFormat -f $IndentString, $_
    #    ))
    #  }
      
    return $StringBuilder.ToString()
  }
}