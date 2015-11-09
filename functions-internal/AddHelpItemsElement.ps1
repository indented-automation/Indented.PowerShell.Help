function AddHelpItemsElement {
  # .SYNOPSIS
  #   Add the helpItems root node to an XML document.
  # .DESCRIPTION
  #   Adds the helpItems root node to an existing XDocument.
  # .PARAMETER XDocument
  #   Any XDocument.
  # .INPUTS
  #   System.Xml.Linq.XDocument
  # .OUTPUTS
  #   System.Xml.Linq.XDocument
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     29/10/2015 - Chris Dent - Created.
  
  [CmdletBinding()]
  [OutputType([System.Xml.Linq.XDocument])]
  param(
    [Parameter(ValueFromPipeline = $true)]
    [System.Xml.Linq.XDocument]$XDocument
  )

  process {
    if (-not $XDocument.Element('helpItems')) {
      $XDocument.Add(
        [System.Xml.Linq.XElement](New-Object System.Xml.Linq.XElement(
          'helpItems',
          [System.Xml.Linq.XAttribute](New-Object System.Xml.Linq.XAttribute('schema', [String]'maml'))
        ))
      )
    }
    
    return $XDocument
  }
}