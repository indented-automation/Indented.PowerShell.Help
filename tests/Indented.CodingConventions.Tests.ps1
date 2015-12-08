function Get-ItemFromAst {
  # .SYNOPSIS
  #   Get an item from the abstract syntax tree. 
  # .DESCRIPTION
  #   Searches for an item using the specified predicate.
  # .PARAMETER Ast
  #   The base of the tree to search from.
  # .PARAMETER Query
  #   Used to create the predicate.
  # .INPUTS
  #   System.Management.Automation.Language.Ast
  #   System.String
  # .OUTPUTS
  #   System.Management.Automation.PSObject
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     07/12/2015 - Chris Dent - Created.
  
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, Position = 1)]
    [System.Management.Automation.Language.Ast]$Ast,
    
    [Parameter(Mandatory = $true, Position = 2)]
    [String]$Query
  )
  
  $Predicate = [ScriptBlock]::Create(('param( $Ast ); {0}' -f $Query))
  $MatchedElements = $Ast.FindAll($Predicate, $true) |
    Where-Object { $_ }
  if ($MatchedElements) {
    return $MatchedElements |
      ForEach-Object {
        '{0} at line {1}, position {2}: {3}' -f $_.Extent.Text, $_.Extent.StartLineNumber, $_.Extent.StartColumnNumber, $_.Parent.Extent.Text
      }
  } else {
    return $false 
  }
}

function Test-FunctionStructure {
  # .SYNOPSIS
  #   Use the abstract syntax tree to explore the content of a command.
  # .DESCRIPTION
  #   Test-FunctionStructure is used to analyse the content of a function to support the standards described below.
  # .PARAMETER ScriptBlock
  #   A script block to operate against.
  # .INPUTS 
  #   System.Management.Automation.ScriptBlock
  # .OUTPUTS
  #   System.Management.Automation.PSObject
  # .EXAMPLE
  #   Get-Command New-GRXPathNavigator | Test-FunctionStructure
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #    07/12/2015 - Chris Dent - Created.
  
  [CmdletBinding()]
  [OutputType([System.Management.Automation.PSObject])]
  param(
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [ScriptBlock]$ScriptBlock
  )

  process {
    return [PSCustomObject]@{
      HasNestedFunctions    = (Get-ItemFromAst $ScriptBlock.Ast.Body '$Ast -is [System.Management.Automation.Language.FunctionDefinitionAst]')
      IsUsingAddType        = (Get-ItemFromAst $ScriptBlock.Ast '$Ast -is [System.Management.Automation.Language.StringConstantExpressionAst] -and $Ast.Value -eq "Add-Type"')
      IsUsingAliases        = (Get-ItemFromAst $ScriptBlock.Ast '$Ast -is [System.Management.Automation.Language.StringConstantExpressionAst] -and $Ast.Parent -isnot [System.Management.Automation.Language.MemberExpressionAst] -and $Ast.StringConstantType -eq [System.Management.Automation.Language.StringConstantType]::BareWord -and (Test-Path -LiteralPath alias:$($Ast.Value))')
      IsUsingNewObject      = (Get-ItemFromAst $ScriptBlock.Ast '$Ast -is [System.Management.Automation.Language.PipelineAst] -and $Ast.Extent.Text -match "New-Object (-TypeName )?(Object|PSObject|PSCustomObject)"')
      IsUsingThrow          = (Get-ItemFromAst $ScriptBlock.Ast '$Ast -is [System.Management.Automation.Language.StringConstantExpressionAst] -and $Ast.Value -eq "throw"')
      IsUsingWriteErrorStop = (Get-ItemFromAst $ScriptBlock.Ast '$Ast -is [System.Management.Automation.Language.StringConstantExpressionAst] -and $Ast.Value -eq "Write-Error" -and $Ast.Parent.Extent.Text -match "-ErrorAction (1|Stop)"')
    }
  }
}

function Test-IndentationStyle {
  # .SYNOPSIS
  #   Test a scriptblock for subjectively incorrect use of white space.
  # .DESCRIPTION
  #   Test-IndentationStyle looks at the content of a script and attempts to determine if the indentation style is somewhat consistent or not.
  #
  #   As a by-product this function also checks for trailing white space.
  # .PARAMETER ScriptBlock
  #   The script block to analyse.
  # .INPUTS
  #   System.Management.Automation.ScriptBlock
  # .OUTPUTS
  #   System.Management.Automation.PSObject
  # .EXAMPLE
  #   Get-Command ConvertTo-GRString | Test-IndentationStyle
  # .NOTES
  #   Author: Chris Dent
  # 
  #   Change log:
  #     08/12/2015 - Chris Dent - Created.
  
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
    [ScriptBlock]$ScriptBlock
  )
  
  process {
    $Indentation = [PSCustomObject]@{
      Character          = $null
      Description        = ''
      HasMixed           = $false
      HasIncorrectIndent = $false
      HasTrailingSpaces  = $false
      Length             = 0
      IncorrectIndent    = (New-Object System.Collections.Generic.List[Int])
      TrailingSpaces     = (New-Object System.Collections.Generic.List[Int]) 
    }
    
    $Definition = $ScriptBlock.ToString() -split '\r?\n'
    
    $BraceStack = New-Object System.Collections.Stack
    $CommentBlock = $EscapedLineBreak = $PipelinedStack = $false
    for ($i = 0; $i -lt $Definition.Length; $i++) {
      if ($Definition[$i].Trim().Length -gt 0) {
        $Tokens = [System.Management.Automation.PSParser]::Tokenize($Definition[$i], [Ref]$null)
        
        # Establish if this is a comment block or not. Tokenize would be able to tell us this more easily if it weren't line-by-line processing.
        $Tokens |
          Where-Object { $_.Type -eq 'Comment' } |
          ForEach-Object {
            if ($_.Content -eq '<#') {
              $CommentBlock = $true 
            } elseif ($_.Content -eq '#>') {
              $CommentBlock = $false
            }
          }
        
        # Attempt to establish the indentation style
        if (-not $CommentBlock) {
          if ($Indentation.Character -eq $null -and $Definition[$i] -match '^([\s\t]+)') {
            $Indentation.Character = [String]($matches[1][0])
            $Indentation.Length = $matches[1].Length
            $Indentation.Description = switch ($Indentation.Length) {
              1 { 'single' }
              2 { 'double' }
              3 { 'triple' }
              4 { 'quad' }
              default { 'long' }
            }
            $Indentation.Description += switch ($Indentation.Character) {
              ' '  { '-space' }
              "`t" { '-tab' }
            }
          }
        }
        
        # Simple tests
        
        # Mixed indentation character
        if ($Definition[$i] -match '^(\s+\t|\t+\s)') {
          $Indentation.HasMixed = $true 
        } elseif ($Indentation.Character -eq ' ' -and $Definition[$i] -match '^\t') {
          $Indentation.HasMixed = $true 
        } elseif ($Indentation.Character -eq "`t" -and $Defintion[$i] -match ' ') {
          $Indentation.HasMixed = $true 
        }
        # Trailing spaces
        if ($Definition[$i] -match ' +$') {
          $Indentation.TrailingSpaces.Add($i + 1) 
        }
        
        # Account for opening and closing braces
        # A little extra work is required to handle close first then open.
        $Control = 0
        $Tokens |
          Where-Object { $_.Type -in 'GroupStart', 'GroupEnd' } |
          ForEach-Object {
            if ($_.Type -eq 'GroupStart') {
              $Control++
              $null = $BraceStack.Push($_.Content)
            } else {
              $Control--
              $null = $BraceStack.Pop()
            }
          }
        
        if ($Control -eq 0 -and $Tokens[0].Type -eq 'GroupEnd') {
          $IndentCount = $BraceStack.Count
        } elseif ($Control -lt 0 -and $Tokens.Count -gt 1 -and $Tokens[-1].Type -eq 'GroupEnd') {
          # Attempting to account for  "   Thing)", but not "} thing (Stuff)"
          # Where the last character is a closing group, but is not preceeded by the equivalent opening group
          $GroupEnd = $Tokens[-1].Content
          $GroupStart = switch ($GroupEnd) {
            ')' { '(' }
            ']' { '[' }
            '}' { '}' }
          }
          if (-not ($Tokens | Where-Object { $_.Type -eq 'GroupStart' -and $_.Content -eq $GroupStart })) {
            $IndentCount = $BraceStack.Count + 2
          } else {
            $IndentCount = $BraceStack.Count + 1 
          }
        } elseif ($Control -gt 0) {
          $IndentCount = $BraceStack.Count
        } else {
          $IndentCount = $BraceStack.Count + 1
        }

        # Handle escape characters at the end of the line, allow extra indentation to follow. PSParser cannot see these characters.
        # This will apply to the next line, but will not affect the overall count.
        
        # Extra indentation based on an occurence of this one the preceeding line.
        if ($EscapedLineBreak) {
          $IndentCount++ 
        }
        # Set the control variable if this has occured on this line.
        if (-not $EscapedLineBreak -and $Definition[$i] -match '`$' -and $Tokens[-1].Type -ne 'Comment') {
          $EscapedLineBreak = $true
        }
        
        # Handle lines ending with |.
        # Indentation on the following line will be allowed but there's no way to track the end of the block with this style.
        if ($PipelinedStack) {#
          $IndentCount++
        }
        if ($Tokens[-1].Type -eq 'Operator' -and $Tokens[-1].Content -eq '|') {
          $PipelinedStack = $true
        }

        # A final check for the PipelinedStack
        if ($PipelinedStack) {
          $TempIndentString = $Indentation.Character * $Indentation.Length * ($IndentCount - 1)
          if ($Definition[$i] -match "^$TempIndentString\S+") {
            $PipelinedStack = $false
            $IndentCount--
          }
        }

        # The amount the code is expected to be indented.
        $IndentString = $Indentation.Character * $Indentation.Length * $IndentCount

        # Test it
        
        if ($Definition[$i] -notmatch "^$IndentString\S+") {
          Write-Debug ("Fail: ^$IndentString\S+".PadRight(40, ' ') + "Line " + ([String]($i + 1)).PadRight(6, ' ') + $Definition[$i])
          $Indentation.IncorrectIndent.Add($i + 1)
        } else {
          Write-Debug ("Pass: ^$IndentString\S+".PadRight(40, ' ') + "Line " + ([String]($i + 1)).PadRight(6, ' ') + $Definition[$i])
        }
        
        # If the line was previously marked as escaped, but this one is not, unset the value now testing of indentation levels have been performed.
        if ($EscapedLineBreak -and $Definition[$i] -notmatch '`$' -and $Tokens[-1].Type -ne 'Comment') {
          $EscapedLineBreak = $false
        }
      }
    }
    
    if ($Indentation.IncorrectIndent.Count -gt 0) {
      $Indentation.HasIncorrectIndent = "Lines: $($Indentation.IncorrectIndent.ToArray())"
    }
    if ($Indentation.TrailingSpaces.Count -gt 0) {
      $Indentation.HasTrailingSpaces = "Lines: $($Indentation.TrailingSpaces.ToArray())"
    }
    
    $Indentation
  }
}

#
# Main
#

$ModuleName = Split-Path $psscriptroot -Leaf

$ReservedParameterNames = ([System.Management.Automation.Internal.CommonParameters]).GetProperties() | Select-Object -ExpandProperty Name
$ReservedParameterNames += ([System.Management.Automation.Internal.ShouldProcessParameters]).GetProperties() | Select-Object -ExpandProperty Name

#
# Functions tests
#

Describe 'Function help content' {
  Get-Command -Module $ModuleName |
    ForEach-Object {
      $CommandInfo = $_
      $HelpContent = Get-Help $CommandInfo.Name -Full
  
      Context $CommandInfo.Name {
        It 'Must have a synopsis' {
          $HelpContent.synopsis | Should Not BeNullOrEmpty
        }
    
        It 'Must have a description' {
          $HelpContent.description.text | Should Not BeNullOrEmpty
        }

        $CommandInfo.Parameters.Values |
          Where-Object { $_.Name -notin $ReservedParameterNames } |
          ForEach-Object {
            It "Must have a description for Parameters\$($_.Name)" {
             (Get-Help $CommandInfo.Name -Parameter $_.Name).description.Text | Should Not BeNullOrEmpty 
            }
          }
       
        It 'Must have at least 1 example' {
          ($HelpContent.examples.example | Measure-Object).Count | Should BeGreaterThan 0
        }
        
        It 'Must have an author in notes' {
          $HelpContent.alertSet.alert.Text | Should Match 'Author: +.+'
        }
        
        It 'Must have a change log in notes' {
          $HelpContent.alertSet.alert.Text | Should Match 'Change log:'
        }
      }
    }
}

#
# Code analysis - Valid only for FunctionInfo in the context of a module
#  

Describe 'Function structure' {
  Get-Command -Module $ModuleName -CommandType Function |
    ForEach-Object {
      $CommandInfo = $_
      $StructuralAnalysis = $CommandInfo | Test-FunctionStructure
      $IndentationStyle = $CommandInfo | Test-IndentationStyle

      Context $CommandInfo.Name {
        if ($CommandInfo.Name -match '-') {
          It "Must use an approved verb" {
            Get-Verb $CommandInfo.Verb | Should Not BeNullOrEmpty
          }
        }
        
        It 'Must declare the CmdletBinding attribute to prevent parameter overloading' {
          $CommandInfo.CmdletBinding | Should Be $true 
        }
        
        It 'Must use PSCustomObject in place of New-Object' {
          $StructuralAnalysis.IsUsingNewObject | Should Be $false
        }
        
        It 'Must not use Add-Type inside the body of a function' {
          $StructuralAnalysis.IsUsingAddType | Should Be $false
        }
        
        It 'Must not contain nested functions' {
          $StructuralAnalysis.HasNestedFunctions | Should Be $false
        }
        
        It "Must not use aliases" {
          $StructuralAnalysis.IsUsingAliases | Should Be $false
        }
        
        It "Must not mix space and tab indentation" {
          $IndentationStyle.HasMixed | Should Be $false
        }
      }
    }
}

Describe 'Function structure (recommended)' {
  Get-Command -Module $ModuleName -CommandType Function |
    ForEach-Object {
      $CommandInfo = $_
      $CommandMetadata = New-Object System.Management.Automation.CommandMetadata($CommandInfo)
      $StructuralAnalysis = $CommandInfo | Test-FunctionStructure
      $IndentationStyle = $CommandInfo | Test-IndentationStyle

      Context $CommandInfo.Name {
        if ($CommandInfo.Verb -in 'Set', 'New', 'Remove') {
          It 'Should implement SupportsShouldProcess' {
            $CommandMetadata.SupportsShouldProcess | Should Be $true
          }
        }
        
        if ($CommandInfo.Verb -in 'Get', 'Import') {
          It 'Should implement the OutputType attribute if returning output' {
            $CommandInfo.OutputType.Length | Should BeGreaterThan 0
          }
        }
        
        It 'Should not use throw' {
          $StructuralAnalysis.IsUsingThrow | Should Be $false
        }
        
        It 'Should not use Write-Error -Stop' {
          $StructuralAnalysis.IsUsingWriteErrorStop | Should Be $false 
        }
        
        It "Should be consistently indented" {
          $IndentationStyle.HasIncorrectIndent | Should Be $false
        }

        It "Should not have unnecessary trailing white space" {
          $IndentationStyle.HasTrailingSpaces | Should Be $false 
        }
      }
    }
}