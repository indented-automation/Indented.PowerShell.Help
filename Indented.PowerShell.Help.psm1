#
# Module loader for Indented.PowerShell.Help
#
# Change log:
#   03/11/2015 - Chris Dent - Added Add-XElement and Set-HelpSyntax.
#   28/10/2015 - Chris Dent - Created.

#
# Public
#

[Array]$Public = 'Add-HelpCommand',
                 'Get-ActiveHelpDocument',
                 'Get-CmdletInfo',
                 'Get-FunctionInfo',
                 'New-HelpDocument',
                 'Save-ActiveHelpDocument',
                 'Set-ActiveHelpDocument',
                 'Set-HelpInputs',
                 'Set-HelpSyntax',
                 'Test-HelpDocument',
                 'Update-HelpParameter',
                 'Update-HelpSyntax'

$Public |
  ForEach-Object {
    Import-Module "$psscriptroot\functions\$_.ps1" 
  }

#
# Internal
#

[Array]$Internal = 'AddHelpItemsElement',
                   'AddXElement',
                   'GetHelpXDocument',
                   'GetNamespaceManager',
                   'GetTemplateXElement',
                   'GetXNamespace',
                   'RegisterNamespace',
                   'SelectXPathXElement'

$Internal |
  ForEach-Object {
    Import-Module "$psscriptroot\functions-internal\$_.ps1" 
  }

RegisterNamespace -Name 'command' -URI 'http://schemas.microsoft.com/maml/dev/command/2004/10'
RegisterNamespace -Name 'dev' -URI 'http://schemas.microsoft.com/maml/dev/2004/10'
RegisterNamespace -Name 'maml' -URI 'http://schemas.microsoft.com/maml/2004/10'
