# Indented.PowerShell.Help

A MAML help authoring toolset which, as far as it is possible to do so, automatically generates help content.

## Features

### Help file generator

 - [x] Light-weight modification - Automatically create document when a writer is called.
 - [x] Generate CmdletInfo or FunctionInfo without Import-Module. Note: CmdletInfo still requires an imported assembly (Get-CmdletInfo, Get-FunctionInfo).
 - [x] Generate framework document from CmdletInfo or FunctionInfo (Update-HelpDocument).
 - [x] Generate framework document from Module (Update-HelpDocument).
 - [x] Validate help file against schema (Test-HelpDocument).

The light-weight generator is exhibited as follows:
```
Update-HelpDocument -Module SomeModule -Verbose
Save-HelpDocument -Path C:\Temp\NewHelpFile.xml
```
A similar approach will be taken for the conversion between comment-based and MAML:
```
ConvertFrom-CommentBasedHelp -Module SomeModule -Verbose
Save-HelpDocument -Path C:\Temp\NewHelpFile.xml
```
However, conversion is not yet fully operational.

### Help file generator / editor

#### Automatically set items

Each of the following items is discoverable by the module and automatically written to a MAML file.

 - [x] SyntaxItems
 - [x] Parameters
   - [x] Name
   - [x] Position
   - [x] Required / Mandatory
   - [x] Validators
   - [ ] Default value
 - [x] Inputs
 - [x] Outputs (where an [OutputType] attribute is declared)

#### Manually set items

The majority of these may be imported from comment-based help.

 - [x] Synopsis
 - [x] Description
 - [x] Parameter descriptions
   - [x] Name
   - [x] Globbing (wildcard support) 
   - [x] variableLength
   - [x] Description (May import from comment-based help)
 - [ ] Inputs (where commenting of the type, or manual addition of a type is required)
 - [ ] Outputs (where commenting of the type, or manual addition of a type is required)
 - [ ] Examples
 - [ ] Links
 - [ ] Notes

### Help file converter

 - [ ] Convert from comment-based help to MAML help.
 - [ ] Convert from MAML help to comment-based help.
 - [ ] Replace comment-based help with an external help reference for existing functions and modules (may always be experimental).
 - [ ] Replace an external help reference with comment based help for existing functions and modules (may always be experimental).
 - [ ] Customisable comment-based help formatting (comment character, indentation, key-work case, position.