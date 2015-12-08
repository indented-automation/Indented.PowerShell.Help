InModuleScope Indented.PowerShell.Help {
  Describe 'ConvertFrom-CommentBasedHelp' {
    It 'Converts comment based help to maml' {
      ConvertFrom-CommentBasedHelp -Module Indented.PowerShell.Help | Should Be $null
    }
    
    It 'Returns a help document when passed an XDocument' {
      (ConvertFrom-CommentBasedHelp -CommandInfo (Get-Command Update-HelpDocument) -XDocument (New-HelpDocument)).GetType().FullName | Should Be "System.Xml.Linq.XDocument"
    }
    
    It 'Writes a help document to disk when passed a file name' {
      if (Test-Path $env:TEMP\Test.xml) {
        Remove-Item $env:TEMP\Test.xml
      }
      ConvertFrom-CommentBasedHelp -CommandInfo (Get-Command Update-HelpDocument) -Path $env:TEMP\temp.xml
      
      Test-Path $env:TEMP\Temp.xml | Should Be $true
      
      if (Test-Path $env:TEMP\Test.xml) {
        Remove-Item $env:TEMP\Test.xml
      }
    }
  }
  
  Describe 'Get-HelpDocumentItem (from the template)' {
    It 'Gets details from the template' {
      (Get-HelpDocumentItem -Item 'Details' -Template).XElement.Name | Should Be ([System.Xml.Linq.XName]((GetXNamespace 'command') + 'details'))
    }
  
    It 'Gets description from the template' {
      (Get-HelpDocumentItem -Item 'Description' -Template).XElement.Name | Should Be ([System.Xml.Linq.XName]((GetXNamespace 'maml') + 'description'))
    }
  
    It 'Gets example from the template' {
      (Get-HelpDocumentItem -Item 'Example' -Template).XElement.Name | Should Be ([System.Xml.Linq.XName]((GetXNamespace 'command') + 'example'))
    }
  
    It 'Gets inputs from the template' {
      (Get-HelpDocumentItem -Item 'Inputs' -Template).XElement.Name | Should Be ([System.Xml.Linq.XName]((GetXNamespace 'command') + 'inputType'))
    }
  
    It 'Gets parameter from the template' {
      (Get-HelpDocumentItem -Item 'Notes' -Template).XElement.Name | Should Be ([System.Xml.Linq.XName]((GetXNamespace 'maml') + 'alert'))
    }
  
    It 'Gets outputs from the template' {
      (Get-HelpDocumentItem -Item 'Outputs' -Template).XElement.Name | Should Be ([System.Xml.Linq.XName]((GetXNamespace 'command') + 'returnValue'))
    }
  
    It 'Gets parameter from the template' {
      (Get-HelpDocumentItem -Item 'Parameter' -Template).XElement.Name | Should Be ([System.Xml.Linq.XName]((GetXNamespace 'command') + 'parameter'))
    }
  
    It 'Gets synopsis from the template' {
      (Get-HelpDocumentItem -Item 'Synopsis' -Template).XElement.Name | Should Be ([System.Xml.Linq.XName]((GetXNamespace 'maml') + 'description'))
    }
  
    It 'Gets syntax from the template' {
      (Get-HelpDocumentItem -Item 'Syntax' -Template).XElement.Name | Should Be ([System.Xml.Linq.XName]((GetXNamespace 'command') + 'parameter'))
    }
  }
  
  Describe 'New-HelpDocument' {
    $HelpDocument = New-HelpDocument
  
    It 'Creates an XDocument' {
      $HelpDocument -is [System.Xml.Linq.XDocument] | Should Be $true 
    }
  }
  
  Describe 'New-HelpExample' {
    $Text = 'Get-Process |
        Where-Object { $_.Name -eq "powershell" }
        
      Gets the PowerShell process.'
  
    $Example = New-HelpExample $Text
  
    It 'Creates a DocumentItem' {
      $Example -is [Indented.PowerShell.Help.DocumentItem] | Should be $true
    }
    
    It 'Separates code' {
      $Example.Properties['code'] -match '\}$' | Should be $true
    }
    
    It 'Separates descriptive text' {
      $Example.Properties['remarks'] -eq 'Gets the PowerShell process.' | Should be $true
    }
  }
  
  Describe 'Test-HelpDocument' {
    It 'Tests the template help document' {
      Test-HelpDocument -Template | Should Be $true 
    }
  
    It 'Tests the active help document' {
      $XDocument = ConvertFrom-CommentBasedHelp -Command (Get-Command Update-HelpDocument) -XDocument (New-HelpDocument)
      Test-HelpDocument -XDocument $XDocument | Should Be $true 
    }
    
    It 'Provides detailed error information' {
      # Break a help document
      (Test-HelpDocument -Detailed | Select-Object -First 1).PSObject.TypeNames -contains 'Indented.Xml.Linq.ValidationResult' |
        Should Be $true
    }
  }
}