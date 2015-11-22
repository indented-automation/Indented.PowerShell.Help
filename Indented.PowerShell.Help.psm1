#
# Module loader for Indented.PowerShell.Help
#
# Change log:
#   28/10/2015 - Chris Dent - Created.

Set-StrictMode -Version Latest

#
# Classes
#

[Array]$Classes = 'Indented.PowerShell.Help.DocumentItem'

if ($Classes.Count -ge 1) {
  $Classes |
    Where-Object { -not ($_ -as [Type]) } |
    ForEach-Object {
      $Params = @{
        TypeDefinition = (Get-Content "$psscriptroot\classes\$_.cs" -Raw)
        Language       = 'CSharp'
      }
      if (Test-Path "$psscriptroot\classes\$_.ref") {
        $Params.Add('ReferencedAssemblies', (Get-Content "$psscriptroot\classes\$_.ref"))
      }
      
      Add-Type @Params
    }
}

#
# Public
#

[Array]$Public = 'ConvertFrom-CommentBasedHelp',
                 'ConvertTo-CommentBasedHelp',
                 'Get-ActiveHelpDocument',
                 'Get-CmdletInfo',
                 'Get-FunctionInfo',
                 'Get-HelpDocumentElement',
                 'New-HelpDocument',
                 'Remove-HelpDocumentElement',
                 'Save-ActiveHelpDocument',
                 'Set-ActiveHelpDocument',
                 'Test-HelpDocument',
                 'Update-HelpDocument'

if ($Public.Count -ge 1) {
  $Public |
    ForEach-Object {
      Import-Module "$psscriptroot\functions\$_.ps1" 
    }
}

#
# Internal
#

[Array]$Internal = 'AddHelpCommandElement',
                   'AddHelpItemsRootElement',
                   'AddXElement',
                   'GetHelpXDocument',
                   'GetNamespaceManager',
                   'GetReservedParameterNames',
                   'GetTemplateXElement',
                   'GetXNamespace',
                   'RegisterNamespace',
                   'SelectXPathXElement',
                   'SetHelpFormattedText',
                   'UpdateHelpExample',
                   'UpdateHelpInput',
                   'UpdateHelpLink',
                   'UpdateHelpOutput',
                   'UpdateHelpParameter',
                   'UpdateHelpSyntax'

if ($Internal.Count -ge 1) {
  $Internal |
    ForEach-Object {
      Import-Module "$psscriptroot\functions-internal\$_.ps1" 
    }
}

RegisterNamespace -Name 'command' -URI 'http://schemas.microsoft.com/maml/dev/command/2004/10'
RegisterNamespace -Name 'dev' -URI 'http://schemas.microsoft.com/maml/dev/2004/10'
RegisterNamespace -Name 'maml' -URI 'http://schemas.microsoft.com/maml/2004/10'

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
