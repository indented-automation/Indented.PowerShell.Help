function ConvertTo-CommentBasedHelp {
  # .SYNOPSIS
  #   Convert MAML to comment based help.
  # .DESCRIPTION
  #   Convert a MAML help document to comment based help.
  # .PARAMETER CommandInfo
  #   Draw help content from MAML for the specified command.
  # .PARAMETER CommentStyle
  #   Generated help text may use either a line comment or a block comment.
  #
  #   Valid values are Block or Line. The default is Block.
  # .PARAMETER IndentString
  #   Indent help using the specified string. This only applies where help appears within the body of the function.
  # .PARAMETER ItemStyle
  #   The item style dictates the appearance of the key-words in the help text. For example, the .Description key word.
  #
  #   Valid values are LowerCase, UpperCase and PascalCase. By default key words are written in pascal casing (.Synopsis, .Parameter, etc).
  # .PARAMETER MaximumLineLength
  #   Adds an automatic line-break in the text when the length limit is reached. The value is assessed on a word-by-word basis.
  #
  #   When using a line comment a fixed length line may make help content confusing should the line length exceed the console width. In such cases PowerShell is better left to handle the line breaking.
  #
  #   When using a block comment extra line-breaks are dropped, help content may be safely formatted using a fixed-length.
  # .PARAMETER Path
  #   Draw help content from the specified path.
  # .PARAMETER XDocument
  #   Draw help content from the specified XDocument.
  # .EXAMPLE
  #   ConvertTo-CommentBasedHelp -Path C:\Indented.PowerShell.Help-help.xml
  #
  #   Convert the XML file to comment-based help.
  # .EXAMPLE
  #   ConvertTo-CommentBasedHelp -CommandInfo (Get-Command Update-HelpDocument)
  #
  #   Convert help for the specified command to comment 
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

    [ValidateSet('Block', 'Line')]
    [String]$CommentStyle = 'Block',

    [ValidateSet('LowerCase', 'UpperCase', 'PascalCase')]
    [String]$ItemStyle = 'PascalCase',
    
    [String]$IndentString = "    ",
    
    [Int32]$MaximumLineLength = 115
  )

  process {
    if ($CommandInfo -isnot [System.Management.Automation.FunctionInfo]) {
      Write-Warning "$($CommandInfo.Name) is not a function."
    }

    $DocumentItems = Get-HelpDocumentItem -CommandInfo (Get-Command Update-HelpDocument) |
      Where-Object Item -notin 'Syntax', 'Details' |
      Sort-Object {
        switch ($_.Item) {
          'Synopsis'    { 1 }
          'Description' { 2 }
          'Parameter'   { 3 }
          'Inputs'      { 4 }
          'Outputs'     { 5 }
          'Notes'       { 6 }
          'Example'     { 7 }
          'Links'       { 8 } 
        }
      }

    $Comment = New-Object System.Text.StringBuilder
  
    if ($CommentStyle -eq 'Block') {
      $null = $Comment.AppendLine('<#')
      $KeywordFormat = '{0}.{1}'
      $ContentFormat = '{0}{0}{1}'
    } else {
      $KeywordFormat = '{0}# .{1}'
      $ContentFormat = '{0}#{0}{1}'
    }

    $LastItem = ""
    $DocumentItems | ForEach-Object {
      $Item = $_.Item
      if ($ItemStyle -eq 'UpperCase') {
        $Item = $Item.ToUpper()
      } elseif ($ItemStyle -eq 'LowerCase') {
        $Item = $Item.ToLower()
      }

      if ($Item -eq 'Parameter') {
        $Item = '{0} {1}' -f $Item, $Properties['name']
      }
      if ($Item -ne $LastItem -or -not $_.Item.EndsWith('s')) {
        $null = $Comment.AppendLine(($KeywordFormat -f $IndentString, $Item))
        $LastItem = $_.Item
      }

      $ContentLines = New-Object System.Collections.Generic.List[String]
      $Properties = $_.Properties
      switch -Regex ($_.Item) {
        'Example' {
          $ContentLines.Add($Properties['code'])
          $ContentLines.Add($Properties['remarks'])
        }
        'Notes|Parameter' { $Properties['paragraphs'] | ForEach-Object { $ContentLines.Add($_) } }
        'Inputs|Outputs'  { $ContentLines.Add($Properties['name']) }
        default           { $ContentLines.Add($Properties['description']) }
      }
      
      $ContentLines | ForEach-Object {
        $null = $Comment.AppendLine(($ContentFormat -f $IndentString, $_))
      }
    }
    
    $Comment.ToString()
  }
}