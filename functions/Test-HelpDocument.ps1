function Test-HelpDocument {
  # .SYNOPSIS
  #   Test validation of the help document against the schema.
  # .DESCRIPTION
  #   The schema set held in $PSHOME\Schemas\PSMaml is used to verify the content of a help document.
  # .PARAMETER Path
  #   The path to an existing help document.
  # .PARAMETER Detailed
  #   By default Test-HelpDocument returns true or false, a detailed report of errors may be returned by setting this parameter.
  # .PARAMETER XDocument
  #   An existing help document to verify.
  # .INPUTS
  #   System.String
  #   System.Xml.Linq.XDocument
  # .OUTPUTS
  #   System.Boolean
  #   System.Management.Automation.PSObject[] (Indented.Xml.Linq.ValidationResult[])
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     06/11/2015 - Chris Dent - Added Line Info.
  #     03/11/2015 - Chris Dent - Created.
  
  [CmdletBinding(DefaultParameterSetName = 'FromXDocument')]
  [OutputType([System.Boolean], [System.Management.Automation.PSObject[]])]
  param(
    [Parameter(Mandatory = $true, ParameterSetName = 'FromPath')]
    [ValidateScript( { Test-Path $_ } )]
    [String]$Path,

    [Parameter(ParameterSetName = 'FromXDocument')]
    [System.Xml.Linq.XDocument]$XDocument,
    
    [Switch]$Template,
    
    [Switch]$Detailed
  )
  
  $XDocument = GetHelpXDocument @psboundparameters
  if ($psboundparameters.ContainsKey('XDocument') -or -not $psboundparameters.ContainsKey('Path')) {
    # XDocument may have been loaded from a file, but if it only exists in memory LineInfo will not be available.
    # Fabricate a temp file for the XDocument, save and reload it to allow positional information to be returned
    # regardless of the origin.
    $TempPath = [System.IO.Path]::GetTempFileName() + '.xml'
    $XDocument.Save($TempPath, [System.Xml.Linq.SaveOptions]::OmitDuplicateNamespaces)
    $XDocument = [System.Xml.Linq.XDocument]::Load($TempPath, [System.Xml.Linq.LoadOptions]::SetLineInfo)
  }
  
  $XmlSchemaSet = New-Object System.Xml.Schema.XmlSchemaSet
  $null = $XmlSchemaSet.Add('http://schemas.microsoft.com/maml/2004/10', (Join-Path $pshome 'Schemas\PSMaml\maml.xsd'))
  
  $List = [System.Collections.ArrayList]::Synchronized((New-Object System.Collections.ArrayList))
  
  [System.Xml.Schema.Extensions]::Validate(
    $XDocument,
    $XmlSchemaSet,
    {
      param($XObject, $Exception)
      
      $List.Add([PSCustomObject]@{
        XObject   = $XObject
        Exception = $Exception
      })
    },
    $true
  )
 
  if ($TempPath) {
    # If a temp file was created for positional tracking, delete it.
    Remove-Item $TempPath
  }
 
  if ($Detailed) {
    $List | 
      ForEach-Object {
        [PSCustomObject]@{
          Name         = $_.XObject.Name
          NodeType     = $_.XObject.NodeType
          Error        = $_.Exception.Message
          LineNumber   = $_.XObject.LineNumber
          LinePosition = $_.XObject.LinePosition
          XObject      = $_.XObject
        } | Add-Member -TypeName Indented.Xml.Linq.ValidationResult -PassThru
      }
  } else {
    if ($List.Count -eq 0) {
      return $true 
    } else {
      return $false 
    }
  }
}