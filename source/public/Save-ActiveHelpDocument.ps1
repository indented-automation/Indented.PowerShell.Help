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
  #     11/11/2015 - Chris Dent - Moved parameter validation into the body of the code, throws as terminating errors.
  #     05/11/2015 - Chris Dent - Created.

  [CmdletBinding()]
  param(
    [Parameter(Position = 1)]
    [ValidatePattern( '\.xml$' )]
    [String]$Path
  )
  
  $ActiveHelpDocument = Get-ActiveHelpDocument
  if (-not $ActiveHelpDocument) {
    $pscmdlet.ThrowTerminatingError((
      New-Object System.Management.Automation.ErrorRecord(
        (New-Object System.InvalidOperationException "Unable to find an active help document."),
        'NullNotAllowed,Indented.PowerShell.Help.Save-ActiveHelpDocument',
        'OperationStopped',
        $ActiveHelpDocument
      )
    ))
  }
  if ($ActiveHelpDocument.Path) {
    $Path = $ActiveHelpDocument.Path 
  } elseif (-not $psboundparameters.ContainsKey('Path')) {
    $pscmdlet.ThrowTerminatingError((
      New-Object System.Management.Automation.ErrorRecord(
        (New-Object System.ArgumentException "Cannot bind argument to parameter 'Path' because it is null."),
        'ParameterArgumentValidationErrorNullNotAllowed,Indented.PowerShell.Help.Save-ActiveHelpDocument',
        'InvalidArgument',
        $Path
      )
    ))
  }
  
  if (-not [System.IO.Path]::IsPathRooted($Path)) {
    $Path = Join-Path $pwd.Path $Path
  }

  if (Test-Path (Split-Path $Path -Parent)) {
    (Get-ActiveHelpDocument).Save($Path, [System.Xml.Linq.SaveOptions]::OmitDuplicateNamespaces)
  } else {
    $pscmdlet.ThrowTerminatingError((
      New-Object System.Management.Automation.ErrorRecord(
        (New-Object System.ArgumentException "The specified path does not exist."),
        'ParentPathValidation,Indented.PowerShell.Help.Save-ActiveHelpDocument',
        'InvalidArgument',
        $Path
      )
    ))
  }
}