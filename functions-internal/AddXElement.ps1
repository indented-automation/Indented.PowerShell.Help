function AddXElement {
  # .SYNOPSIS
  #   Add an XElement into an existing XDocument.
  # .DESCRIPTION
  #   Internal use only.
  #
  #   AddXElement adds items to a document in alphabetical order.
  # .PARAMETER Parent
  #   The parent element which is expected to contain the XElement.
  # .PARAMETER SortBy
  #   SortBy expects an XPath Expression which will resolve the ID in both the new XElement and the supplied XDocument.
  # .PARAMETER XDocument
  #   A valid XDocument.
  # .INPUTS
  #   System.String
  #   System.Xml.Linq.XElement
  #   System.Xml.Linq.XDocument
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     03/11/2015 - Chris Dent - Created.
 
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [System.Xml.Linq.XElement]$XElement,
    
    [Parameter(Mandatory = $true)]
    [System.Xml.Linq.XContainer]$XContainer,
    
    [Parameter(Mandatory = $true)]
    [String]$Parent,
    
    [String]$SortBy
  )

  process {
	  if ($psboundparameters.ContainsKey('SortBy')) {
		  $NewElementID = SelectXPathXElement -XPathExpression $SortBy -XContainer $XElement | Select-Object -ExpandProperty Value
		  
		  $PrecedingXElement = $null
		  SelectXPathXElement -XPathExpression "$Parent/*" -XContainer $XContainer |
		    ForEach-Object {
		      $ElementID = SelectXPathXElement -XPathExpression $SortBy -XContainer $_ | Select-Object -ExpandProperty Value
		      if ($ElementID -lt $NewElementID) {
		        $PrecedingXElement = $_
		      }
		    }
		}
	  
	  if ($PrecedingXElement) {
	    $PrecedingXElement.AddAfterSelf($XElement)
	  } else {
	  	$ParentXElement = SelectXPathXElement -XPathExpression $Parent -XContainer $XContainer
	  	if ($psboundparameters.ContainsKey('SortBy')) {
	  		$ParentXElement.AddFirst($XElement)
	  	} else {
	  		$ParentXElement.Add($XElement)
	  	}
	  }
	}
}