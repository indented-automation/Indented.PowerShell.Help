Describe 'ConvertFrom-CommentBasedHelp' {
  It "Converts comment based help to maml" {
    ConvertFrom-CommentBasedHelp -Module Indented.PowerShell.Help | Should Be $null
  }
  
  It "Returns a help document when passed an XDocument" {
    (ConvertFrom-CommentBasedHelp -CommandInfo (Get-Command Get-Process) -XDocument (New-HelpDocument)).GetType() | Should Be [System.Xml.Linq.XDocument]
  }
  
  It "Writes a help document to disk when passed a file name" {
    if (Test-Path "$env:TEMP\Test.xml") {
      Remove-Item "$env:TEMP\Test.xml"
    }
    ConvertFrom-CommentBasedHelp -CommandInfo (Get-Command Get-Process) -Path "$env:TEMP\temp.xml"
    Test-Path "$env:TEMP\Temp.xml" | Should Be $true
    Remove-Item "$env:TEMP\Test.xml"
  }
}

Describe 'Get-HelpDocumentItem' {
  It "Gets details from template" {
    (Get-HelpDocumentItem -Item 'Details' -Template).XElement.Name | Should Be ([System.Xml.Linq.XName]((GetXNamespace 'command') + "details"))
  }

  It "Gets description from template" {
    (Get-HelpDocumentItem -Item 'Description' -Template).XElement.Name | Should Be ([System.Xml.Linq.XName]((GetXNamespace 'maml') + "description"))
  }

  It "Gets parameter from template" {
    (Get-HelpDocumentItem -Item 'Parameter' -Template).XElement.Name | Should Be ([System.Xml.Linq.XName]((GetXNamespace 'command') + "parameter"))
  }

  It "Gets synopsis from template" {
    (Get-HelpDocumentItem -Item 'Synopsis' -Template).XElement.Name | Should Be ([System.Xml.Linq.XName]((GetXNamespace 'maml') + "description"))
  }

  It "Gets syntax from template" {
    (Get-HelpDocumentItem -Item 'Syntax' -Template).XElement.Name | Should Be ([System.Xml.Linq.XName]((GetXNamespace 'command') + "syntax"))
  }
}

Describe 'New-HelpDocument' {
  $HelpDocument = New-HelpDocument

  It "Creates an XDocument" {
    $HelpDocument -is [System.Xml.Linq.XDocument] | Should Be $true 
  }
}

Describe 'New-HelpExample' {
  $Example = New-HelpExample -Example '
    Get-Process |
      Where-Object { $_.Name -eq "powershell" }
      
    Gets the PowerShell process.'
  
  If "Separates code from example" {
    $Example.Code -match '^Get-Process| ShouldBe 
  }
}

Describe 'Test-HelpDocument' {
  It 'Tests the template help document' {
    Test-HelpDocument -Template | Should Be $true 
  }

  It 'Tests the active help document' {
    ConvertFrom-CommentBasedHelp -Command (Get-Command Get-Process)
    Test-HelpDocument | Should Be $true 
  }
  
  It 'Provides detailed error information' {
    # Break a help document
    (Test-HelpDocument -Detailed | Select-Object -First 1).PSObject.TypeNames -contains 'Indented.Xml.Linq.ValidationResult' |
      Should Be $true
  }
}