# Exploring allowing this notation to create elements / documents
#helpitem {
#  command {
#    name = New-HelpDocument
#    description = New document.
#    example {
#      title   = hello world
#      code    = { Get-Process }
#      remarks = Gets a running process.
#    }
#  }
#  command {
#    name = Update-HelpDocument
#    description = Update document.
#  }
#}

function helpitem {
  [CmdletBinding()]
  param(
    [ScriptBlock]$ScriptBlock
  )

  GetAstImmediateChildren $ScriptBlock |
    ForEach-Object {
      $ItemName = $_.CommandElements[0].Value
      
      
      
    }
}

function command {
  [CmdletBinding()]
  param(
    [ScriptBlock]$ScriptBlock
  )
  
  ConvertFromScriptBlock $ScriptBlock
}

function GetAstImmediateChildren {
  [CmdletBinding()]
  param(
    [ScriptBlock]$ScriptBlock
  )
  
  $ScriptBlock.Ast.EndBlock.Statements.PipelineElements |
    ForEach-Object {
      $_
    }
}

