# This test set attempts to test coding standards to the content of this module.
#
# Help content
#
# * MUST provide a synopsis for the command.
# * MUST provide a description of the command.
# * MUST provide descriptions for every non-default parameter.
# * SHOULD include an Author in notes.
# * SHOULD include a change log in notes.
#
# * SHOULD use a single-line comment when using comment-based help.
#   - Affects appearance in Get-Help. Formatting (line breaks) are discarded when using a comment block.
#
# Module
#
# * MUST use approved verbs for all exported members.
# * MUST provide a description of the module.
# * MUST provide an author.
# * SHOULD provide a minimum PowerShell version.
#
# Commands
#
# * SHOULD support ShouldProcess for the verbs New, Set and Remove if the command makes changes.
#   - This is a subjective test. Should be treated as a warning.
# * SHOULD implement the OutputTypes attribute
#   - Aids discovery.
#
# Functions
#
# * MUST not mix indentation styles
# * MUST use $psboundparameters.ContainsKey to test for uninitialised values passed as parameters.
# * MUST use Test-Path variable:<SomeVariable> to test for existence of potentially uninitialised variables.
# * MUST NOT use Import-Module to load other modules when RequiredModules is the better choice.
#   - Unnecessary loading of modules as a nested module when a dependency chain was intended should be flagged.
# * SHOULD use consistent indentation
#   - Difficult to test (compared a simple check for mixed), many differing styles, none are objectively wrong.
# * SHOULD use [PSCustomObject] to create new objects instead of New-Object PSObject / New-Object PSCustomObject.
#   - Subjective, consistency checking.
# * SHOULD NOT use Add-Type within an exported member.
#   - Warning / subjective, cannot overwrite types on multiple writes.
# * SHOULD NOT use assignment to null to drop output.
#   - Warning / subjective, fine for single "simple" types. Not so good for large arrays (memory loading / paging).
#   - Object is built in memory before assignment and discard.
#   - Pipeline to Out-Null or redirection to $null are better options.
# * SHOULD NOT coerce to Void to drop output.
#   - Warning / subjective, fine for single "simple" types. Not so good for large arrays (memory loading / paging).
#   - Object is built in memory before coersion and discard.
#   - Pipeline to Out-Null or redirection to $null are better options.
# * SHOULD NOT use += to add items to arrays.
#   - Arrays are immutable in .NET. Effectively creates a new array, then uses Array.Copy for each addition.
#
# Functions (Optional)
#
# * MUST use double-space indentation style.
#   - Indentation is very personal. If indentation is being inspected it can also be tested.