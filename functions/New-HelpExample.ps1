function New-HelpExample {
  # .SYNOPSIS
  #   Creates a new example fragment for a help document.
  # .DESCRIPTION
  #   New-HelpExample is used to create a new Example fragment for a help document.
  #
  #   New-HelpExample is a best-effort parser. If both Code and Remarks parameters have values no assumptions are made. If a value is only supplied for Code the content is split. Everything up to the first blank line is considered Code, everything after Remarks. Remarks are then assigned to paragraphs based on any other blank lines in the content.
  # .PARAMETER Code
  #   The lines of PowerShell that make up the example.
  # .PARAMETER Remarks
  #   Descriptive text for the example.
  # .INPUTS
  #   System.String
  # .OUTPUTS
  #   Indented.PowerShell.Help.DocumentItem.
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     25/11/2015 - Chris Dent - Created.
    
  [CmdletBinding()]
  [OutputType([Indented.PowerShell.Help.DocumentItem])]
  param(
    [Parameter(Mandatory = $true)]
    [String[]]$Code,
    
    [String[]]$Remarks,
    
    [String]$Title = 'Example'
  )

  # Handler for conversion from comment based help where the first line is taken to be code, and all subsequent lines remarks.
  # This method assigns everything up to the first blank line as code, everything after that blank line as the description.
  $Code = $Code -split '\r?\n' | ForEach-Object { $_.TrimEnd() }
  if ($psboundparameters.ContainsKey('Remarks')) {
    $Remarks = $Remarks | ForEach-Object { $_.Trim() }
  } else {    
    $Index = $Code.IndexOf('')
    if ($Index -gt -1) {
      $TempCode = New-Object String[] $Index
      [Array]::Copy($Code, $TempCode, $Index)
      if ($Index -gt ($TempCode.Length - 1)) {
        $Remarks = New-Object String[] ($Code.Count - $Index)
        [Array]::Copy($Code, $Index, $Remarks, 0, $Remarks.Length)
      }

      $Code = $TempCode
    }
  }
  
  $XElement = GetTemplateXElement 'command:example'
  $XElement.Element((GetXNamespace 'maml') + 'title').Value = $Title
  
  if ($Remarks) {
    SetHelpFormattedText -Text ($Remarks -join "`r`n") -XPathExpression './dev:remarks' -XContainer $XElement
  }
  
  $XElement.Element((GetXNamespace 'dev') + 'code').Value = $Code -join "`r`n"
  
  return New-Object Indented.PowerShell.Help.DocumentItem(
    $Title,
    $XElement
  )
}