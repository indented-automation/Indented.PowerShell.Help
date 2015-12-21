function Get-FunctionInfo {
  # .SYNOPSIS
  #   Get an instance of FunctionInfo.
  # .DESCRIPTION
  #   FuncitonInfo does not present a public constructor. This function calls an internal / private constructor on FunctionInfo to create a description of a function from a script block or file containing one or more functions.
  # .PARAMETER IncludeNested
  #   By default functions nested inside other functions are ignored. Setting this parameter will allow nested functions to be discovered.
  # .PARAMETER Path
  #   The path to a file containing one or more functions.
  # .PARAMETER ScriptBlock
  #   A script block containing one or more functions.
  # .INPUTS
  #   System.String
  #   System.Management.Automation.ScriptBlock
  # .OUTPUTS
  #   System.Management.Automation.FunctionInfo
  # .EXAMPLE
  #   Get-ChildItem -Filter *.psm1 | Get-FunctionInfo
  #
  #   Get all functions declared within the *.psm1 file and construct FunctionInfo.
  # .EXAMPLE
  #   Get-ChildItem C:\Scripts -Filter *.ps1 -Recurse | Get-FunctionInfo
  #
  #   Get all functions declared in all ps1 files in C:\Scripts.
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     10/12/2015 - Chris Dent - Improved error handling.
  #     28/10/2015 - Chris Dent - Created.
  
  [CmdletBinding(DefaultParameterSetName = 'FromPath')]
  [OutputType([System.Management.Automation.FunctionInfo])]
  param(
    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'FromPath')]
    [ValidateNotNullOrEmpty()]
    [Alias('FullName')]
    [String]$Path,
    
    [Parameter(ParameterSetName = 'FromScriptBlock')]
    [ValidateNotNullOrEmpty()]
    [ScriptBlock]$ScriptBlock,
    
    [Switch]$IncludeNested
  )
  
  begin {
    $ExecutionContextType = [System.Reflection.Assembly]::GetAssembly([System.Management.Automation.PSCmdlet]).GetType('System.Management.Automation.ExecutionContext')

    $Constructor = [System.Management.Automation.FunctionInfo].GetConstructor(
      ([System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::Instance),
      $null,
      ([System.Reflection.CallingConventions]::Standard -bor [System.Reflection.CallingConventions]::HasThis),
      ([System.String], [System.Management.Automation.ScriptBlock], $ExecutionContextType),
      $null
    )
  }
  
  process {
    if ($pscmdlet.ParameterSetName -eq 'FromPath') {
      try {
        $ScriptBlock = [ScriptBlock]::Create((Get-Content $Path -Raw))
      } catch {
        $ErrorRecord = @{
          Exception = $_.Exception.InnerException
          ErrorId   = 'InvalidScriptBlock.Indented.PowerShell.Help\Get-FunctionInfo'
          Category  = 'OperationStopped'
        }
        Write-Error @ErrorRecord
      }
    }
    
    if ($ScriptBlock -ne $null) {
      $ScriptBlock.Ast.FindAll(
        { 
          param( $Item )
          
          $Item -is [System.Management.Automation.Language.FunctionDefinitionAst]
        },
        $IncludeNested
      ) | ForEach-Object {
        try {
          $InternalScriptBlock = $_.Body.GetScriptBlock()
        } catch {
          # Discard exceptions raised, if any, by this method and skip the content 
        }
        if ($InternalScriptBlock) {
          $Constructor.Invoke((
            [String]$_.Name,
            $InternalScriptBlock,
            $null
          ))
        }
      }
    }
  }
}