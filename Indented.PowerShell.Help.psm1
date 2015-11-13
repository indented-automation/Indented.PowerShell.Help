#
# Module loader for Indented.PowerShell.Help
#
# Change log:
#   03/11/2015 - Chris Dent - Added Add-XElement and Set-HelpSyntax.
#   28/10/2015 - Chris Dent - Created.

#
# Public
#

[Array]$Public = 'Get-ActiveHelpDocument',
                 'Get-CmdletInfo',
                 'Get-FunctionInfo',
                 'Get-HelpDocumentElement',
                 'New-HelpDocument',
                 'Remove-HelpDocumentElement',
                 'Save-ActiveHelpDocument',
                 'Set-ActiveHelpDocument',
                 'Test-HelpDocument',
                 'Update-HelpDocument'

$Public |
  ForEach-Object {
    Import-Module "$psscriptroot\functions\$_.ps1" 
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

$Internal |
  ForEach-Object {
    Import-Module "$psscriptroot\functions-internal\$_.ps1" 
  }

RegisterNamespace -Name 'command' -URI 'http://schemas.microsoft.com/maml/dev/command/2004/10'
RegisterNamespace -Name 'dev' -URI 'http://schemas.microsoft.com/maml/dev/2004/10'
RegisterNamespace -Name 'maml' -URI 'http://schemas.microsoft.com/maml/2004/10'
