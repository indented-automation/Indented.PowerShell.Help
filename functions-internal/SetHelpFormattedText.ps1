function SetHelpFormattedText {
  # .SYNOPSIS
  #   Sets text for any field expected to hold formatted text.
  # .DESCRIPTION
  #   SetHelpFormattedText is used to handle the setting of any field which is expected to hold formatted text such as:
  #
  #     * Command description
  #     * Command synopsis
  #     * Parameter description
  #
  # .PARAMETER XDocument
  #   An XDocument to operate against.
  # .PARAMETER XPathExpression
  #   An XPathExpression which denotes the element to update.
  # .PARAMETER Text
  #   The text to parse and insert.
  # .INPUTS
  #   System.String
  #   System.Xml.Linq.XDocument
  # .OUTPUTS
  #   System.Xml.Linq.XDocument
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     11/11/2015 - Chris Dent - Created.

  [CmdletBinding()]
  [OutputType([System.Xml.Linq.XDocument])]
  param(
    [String]$Text,

    [Parameter(ParameterSetName = 'UsingXPath')]
    [String]$XPathExpression,

    [Parameter(ParameterSetName = 'UsingXPath')]
    [System.Xml.Linq.XContainer]$XContainer
  )

  # Remove any existing text.
  SelectXPathXElement `
      -XPathExpression "$XPathExpression/*" `
      -XContainer $XContainer |
    ForEach-Object { $_.Remove() }

  # Add new text (if there is any)    
  $Text.Split("`n", [System.StringSplitOptions]::RemoveEmptyEntries) |
    ForEach-Object {
      # Should go a little more advanced than just this.
      New-Object System.Xml.Linq.XElement((
        [System.Xml.Linq.XName]((GetXNamespace 'maml') + 'para'),
        [String]$_
      ))
    } |
    AddXElement -XContainer $XContainer -Parent $XPathExpression
}