function Save-ActiveHelpDocument {
  # .SYNOPSIS
  #   Save the active help document to a file.
  # .DESCRIPTION
  #   Saves the active help document to a file at the specified path.
  # .PARAMETER Path
  #   A valid path to an XML file.
  # .INPUTS
  #   System.String
  # .EXAMPLE
  #   Save-ActiveHelpDocument -Path en-US\module.help.ps1xml
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     05/11/2015 - Chris Dent - Created.

  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [ValidatePattern( '\.xml$' )]
    [String]$Path
  )

  # This needs to be able to act on a path if the active document was loaded from one.

  if (-not [System.IO.Path]::IsPathRooted($Path)) {
    $Path = Join-Path $pwd.Path $Path
  }

  if (Get-ActiveHelpDocument) {
    if (Test-Path (Split-Path $Path -Parent)) {
      (Get-ActiveHelpDocument).Save($Path, [System.Xml.Linq.SaveOptions]::OmitDuplicateNamespaces)
    } else {
      Write-Error "The specified path does not exist ($(Split-Path $Path -Parent))"
    }
  } else {
    Write-Warning "An active help document was not found."
  }
}