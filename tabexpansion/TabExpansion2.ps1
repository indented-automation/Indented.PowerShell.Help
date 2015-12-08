function Enable-HelpDocumentTabExpansion {
  [CmdletBinding()]
  param( )

  Rename-Item function:TabExpansion2 TabExpansion2_IndentedPowerShellHelp
  Rename-Item function:TabExpansion2_IndentedPowerSHellHelp


  function:TabExpansion2 function:



# It'd be really nice to make this work...
$completion_Module = {
  param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

  Get-Module |
    Where-Object { $_.Name -like $wordToComplete } |
    ForEach-Object {
      New-Object System.Management.Automation.CompletionResult(
        $_.Name,
        $_.Name,
        'ParameterValue',
        $_.Name
      )
    }
}

function Disable-HelpDocumentTabExpansion {
  [CmdletBinding()]
  param(

  )

  if (Test-Path Script:TabExpansion2_IndentedPowerShellHelp) {
    Remove-Item function:TabExpansion2
    Rename-Item function:TabExpansion2_IndentedPowerShellHelp TabExpansion2
  }
}