function Set-HelpDescription {
  # .SYNOPSIS
  #   Set the synopsis text.
  # .DESCRIPTION
  #   Set the synopsis text. If the synopsis text is multi-line each line is treated as a paragraph.
  # .PARAMETER CommandInfo
  # .PARAMETER Path
  # .PARAMETER XDocument
  # .PARAMETER Synopsis
  #   The text to set.
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     11/11/2015 - Chris Dent - Created.
    
  # Abstract this, have a text-field handler instead.


  [CmdletBinding(DefaultParameterSetName = 'FromXDocument')]
  [OutputType([System.Xml.Linq.XDocument])]
  param(
    [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true)]
    [System.Management.Automation.CommandInfo]$CommandInfo,

    [Parameter(ParameterSetName = 'FromPath')]
    [String]$Path,

    [Parameter(ParameterSetName = 'FromXDocument')]
    [System.Xml.Linq.XDocument]$XDocument,

    [String]$Synopsis
  )

  begin {
    $XDocument = GetHelpXDocument @psboundparameters
  }
  
  process {
    if (-not (SelectXPathXElement -XPathExpression "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']" -XContainer $XDocument)) {
      $XDocument = Add-HelpCommand $CommandInfo -XDocument $XDocument
    }
    
    # Remove any existing text.
    SelectXPathXElement `
        -XPathExpression "/helpItems/command:command/command:details[command:name='$($CommandInfo.Name)']/maml:description/*" `
        -XContainer $XDocument |
      ForEach-Object { $_.Remove() }

    # Add new text (if there is any)    
    $Synopsis.Split("`n", [System.StringSplitOptions]::RemoveEmptyEntries) |
      ForEach-Object {
        New-Object System.Xml.Linq.XElement((
          [System.Xml.Linq.XName]((GetXNamespace 'maml') + 'para'),
          [String]$_
        ))
      } |
      AddXElement -XContainer $XDocument `
        -Parent "/helpItems/command:command/command:details[command:name='$($CommandInfo.Name)']/maml:description"
  }
  
  end {
    if ($psboundparameters.ContainsKey('XDocument')) {
      return $XDocument 
    } elseif ($psboundparameters.ContainsKey('Path')) {
      $XDocument.Save($Path, [System.Xml.Linq.SaveOptions]::OmitDuplicateNamespaces)
    }
  }
}