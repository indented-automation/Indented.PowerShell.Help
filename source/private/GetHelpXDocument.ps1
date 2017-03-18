function GetHelpXDocument {
  # .SYNOPSIS
  #   Get an XDocument from whatever parameters are supplied.
  # .DESCRIPTION
  #   GetHelpXDocument intentially allows parameter overloading so it can work with either a Path or XDocument depending on the caller. If neither is passed a blank help document is created.
  # .PARAMETER Path
  #   A path to an existing XML document.
  # .PARAMETER Template 
  #   Use the help document template as the working file.
  # .PARAMETER XDocument
  #   An in-memory XDocument to work on.
  # .INPUTS
  #   System.String
  #   System.Xml.Linq.XDocument
  # .OUTPUTS
  #   System.Xml.Linq.XDocument
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     28/10/2015 - Chris Dent - Created.
  
  param(
    [String]$Path,
    
    [System.Xml.Linq.XDocument]$XDocument,
    
    [Switch]$Template
  )

  if ($Template) {
    return [System.Xml.Linq.XDocument]::Load("$psscriptroot\..\variables\template.xml", [System.Xml.Linq.LoadOptions]::SetLineInfo) 
  } else {
    $Caller = Get-PSCallStack | Select-Object -First 1 -Skip 1 -ExpandProperty Command
    if ($psboundparameters.ContainsKey('Path')) {
      if (-not (Test-Path $Path)) {
        Write-Verbose "${Caller}: Creating a new empty help document at $Path"
        (New-HelpDocument).Save($Path, [System.Xml.Linq.SaveOptions]::OmitDuplicateNamespaces)
      }
      Write-Verbose "${Caller}: Loading help content from $Path"
      $XDocument = [System.Xml.Linq.XDocument]::Load($Path, [System.Xml.Linq.LoadOptions]::SetLineInfo)
    } elseif (-not $psboundparameters.ContainsKey('XDocument')) {
      if (Get-ActiveHelpDocument) {
        Write-Verbose "${Caller}: Using active help document"
        $XDocument = Get-ActiveHelpDocument 
      } else {
        Write-Verbose "${Caller}: Creating a new help document and setting as active"
        $XDocument = Set-ActiveHelpDocument -PassThru
      }
    }
  
    return ($XDocument | AddHelpItemsRootElement)
  }
}