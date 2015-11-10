function Update-HelpDocument {
# Description for a specific parameter and a specific command
#Update-HelpDocument -Command ... -Item Parameter\SomeParam\Description -Value '...'
# Globbing for a specific parameter and specific command
#Update-HelpDocument -Command ... -Item Parameter\SomeParam\Globbing -Value $true
# Globbing for all instances of Parameter (all commands)
#Update-HelpDocument -Item Parameter\SomeParam\Globbing -Value $true
# Synopsis for a particular command
#Update-HelpDocument -Command ... -Item Synopsis -Value '...'
# All parameter instances (from CommandInfo)
#Update-HelpDocument -Item Parameter
# All Syntax instances (from CommandInfo)
#Update-HelpDocument -Item Syntax
# All Inputs (from CommandInfo)
#Update-HelpDocument -Item Inputs
# Outputs - Manual
#Update-HelpDocument -CommandInfo ... -Item Outputs -Value [Type1], [Type2]
# Outputs - Discover
#Update-HelpDocument -CommandInfo ... -Item Outputs
# Links
#Update-HelpDocument -CommandInfo ... -Item Links -Value 'Value1', 'Value2'
}