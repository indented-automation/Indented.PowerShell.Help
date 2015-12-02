function Remove-HelpDocumentItem {
  [CmdletBinding()]
  param(
    [Parameter(ValueFromPipeline = $true)]
    [Indented.PowerShell.Help.DocumentItem]$Item
  )
  
  process {
    $Item.XElement.Remove()
  }
}