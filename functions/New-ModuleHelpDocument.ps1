function Update-ModuleHelpDocument {
  [CmdletBinding(DefaultParameterSetName = 'ByModuleName')]
  param(
    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByModuleName')]
    [Alias('Name')]
    [String]$ModuleName,
    
    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByPath')]
    [Alias('FullName')]
    [String]$Path
  )

  


}