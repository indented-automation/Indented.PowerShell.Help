function Set-ActiveHelpDocument {
  # .SYNOPSIS
  #   Set the help document which should be edited by default..
  # .DESCRIPTION
  #   Set-ActiveHelpDocument creates an in-memory representation of an XML document. Changes are cumulatively made to the document.
  #
  #   The active document must be manually saved after editing or changes will be lost.
  # 
  #   If neither Path or XDocument is specified a new blank document is created and made active.
  # .PARAMETER PassThru
  #   Return the active XDocument. By default this command does not provide a return value.
  # .PARAMETER Path
  #   Load an existing XDocument from the specified path.
  # .PARAMETER XDocument
  #   An existing XDocument to make active.
  # .INPUTS
  #   System.String
  #   System.Xml.Linq.XDocument
  # .OUTPUTS
  #   System.Xml.Linq.XDocument
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     11/11/2015 - Chris Dent - Added a Path property to the XDocument created when a Path is passed. Consumed by Save-HelpDocument.
  #     29/10/2015 - Chris Dent - Created.

  [CmdletBinding(DefaultParameterSetName = 'FromXDocument')]
  [OutputType([System.Xml.Linq.XDocument])]
  param(
    [Parameter(ParameterSetName = 'FromXDocument')]
    [System.Xml.Linq.XDocument]$XDocument,

    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'FromPath')]
    [Alias('FullName')]
    [String]$Path,
    
    [Switch]$PassThru
  )

  if ($pscmdlet.ParameterSetName -eq 'FromPath') {
    $Path = (Get-Item $Path).FullName
    $XDocument = [System.Xml.Linq.XDocument]::Load($Path, [System.Xml.Linq.LoadOptions]::SetLineInfo)
    $XDocument | Add-Member Path -MemberType NoteProperty -Value $Path
  }

  if (-not $XDocument) {
    $XDocument = New-HelpDocument
  }
  $XDocument = $XDocument | AddHelpItemsRootElement

  $Script:ActiveHelpDocument = $XDocument
  if ($PassThru) {
  	$XDocument
  }
}