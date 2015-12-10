# Indented.PowerShell.Help

A help authoring toolset which automatically generates help content and converts between help document types (comment based -> MAML; MAML -> comment based).

## Features

### Help file generator

 - [x] Light-weight modification - Automatically create document when any writer is called. Provided through ConvertFrom-CommentBasedHelp and Update-HelpDocument.
 - [x] Generate CmdletInfo or FunctionInfo without Import-Module. Note: CmdletInfo still requires an imported assembly. Provided by Get-CmdletInfo and Get-FunctionInfo.
 - [x] Generate framework document from CmdletInfo or FunctionInfo. Provided by Update-HelpDocument.
 - [x] Generate framework document from Module. Provided by Update-HelpDocument; Module must be loaded (or able to load).
 - [x] Validate help file against schema. Provided by Test-HelpDocument.

The light-weight generator is exhibited as follows:
```
Update-HelpDocument -Module SomeModule -Verbose
Save-HelpDocument -Path C:\Temp\NewHelpFile.xml
```
A similar approach has been taken for the conversion between comment-based and MAML:
```
ConvertFrom-CommentBasedHelp -Module SomeModule -Verbose
Save-HelpDocument -Path C:\Temp\NewHelpFile.xml
```

### Help file generator / editor

#### Automatically set items

Each of the following items is discoverable by the module and automatically written to a MAML file.

 - [x] SyntaxItems (contains a bug where the param block is empty. Must leave a schema compliant empty element for syntax)
 - [x] Parameters
   - [x] Name
   - [x] Position
   - [x] Required / Mandatory
   - [x] Validators
   - [ ] Default value
   - [ ] Aliases (not part of the document schema; to be confirmed since it's used in a number of MS help documents)
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
   - [x] Description (set manually, or import from comment based help)
 - [x] Inputs (where commenting of the type, or manual addition of a type is required)
 - [x] Outputs (where commenting of the type, or manual addition of a type is required)
 - [x] Examples
 - [ ] Links
 - [x] Notes

### Help file converter

 - [x] Convert from comment-based help to MAML help.
 - [ ] Convert from MAML help to comment-based help.
 - [ ] Replace comment-based help with an external help reference for existing functions and modules (using AST, must backup files prior to modification).
 - [ ] Replace an external help reference with comment based help for existing functions and modules (using AST, must backup files prior to modification).
 - [x] Customisable comment-based help formatting (comment character, indentation, key-work case, position). Partial implementation in ConvertTo-CommentBasedHelp.

### To-do / Experimental

The following are potential features, but should remain as notes until the core functionality described above is complete.

 - [ ] Allow automatic / elective insertion of default descriptions for parameters.
 - [ ] Generate and update comment-based help block from function code (can be done as it is, but uses Update-HelpDocument -> MAML -> ConvertTo-CommentBasedHelp which is very wasteful).
 - [ ] Script block style document / item creation.
 - [ ] Validation / comparison of comment based help content.
 - [ ] Bulk editing of comment based help.
