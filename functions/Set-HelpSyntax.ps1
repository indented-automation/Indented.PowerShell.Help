function Set-HelpSyntax {
  # .SYNOPSIS
  #   Set the syntax section of the help file.
  # .DESCRIPTION
  #   Syntax is generated from the CommandInfo. ParameterSets are documented and an appropriate number of attribute are set for each parameter.
  #
  #   The XML schema shows the same values available for both the syntax and parameters sections. The majority of the information which may be written (as stated in the schema) is ignored when help is read.
  # .PARAMETER CommandInfo
  #   The command to add.
  # .PARAMETER Force
  #   Overwrite an existing document section. All existing information will be lost.
  # .PARAMETER Path
  #   An XML file which should contain the 
  # .PARAMETER XDocument
  #
  # .INPUTS
  #   System.Management.Automation.CommandInfo
  #   System.String
  #   System.Xml.Linq.XDocument
  # .OUTPUTS
  #   System.Xml.Linq.XDocument
  # .EXAMPLE
  #   Set-HelpSyntax (Get-Command Get-Process)
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     03/11/2015 - Chris Dent - Created.

  [CmdletBinding(DefaultParameterSetName = 'FromXDocument')]
  [OutputType([System.Xml.Linq.XDocument])]
  param(
    [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true)]
    [System.Management.Automation.CommandInfo]$CommandInfo,

    [Parameter(ParameterSetName = 'FromPath')]
    [String]$Path,

    [Parameter(ParameterSetName = 'FromXDocument')]
    [System.Xml.Linq.XDocument]$XDocument,

    [Switch]$Force
  )

  begin {
    $XDocument = GetHelpXDocument @psboundparameters
    
    $CommonParameters = ([System.Management.Automation.Internal.CommonParameters]).GetProperties() | Select-Object -ExpandProperty Name
    $ShouldProcessParameters = ([System.Management.Automation.Internal.ShouldProcessParameters]).GetProperties() | Select-Object -ExpandProperty Name
  }

  process {
    if (-not (SelectXPathXElement -XPathExpression "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']" -XContainer $XDocument)) {
      $XDocument = Add-HelpCommand $CommandInfo -XDocument $XDocument
    }
    $XElements = SelectXPathXElement `
      -XPathExpression "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/command:syntax[command:syntaxItem/maml:name='$($CommandInfo.Name)']/*" `
      -XContainer $XDocument
      
    if ($XElements -and $Force) {
      $XElements | ForEach-Object { $_.Remove() }
      $XElements = $null
    }

    if ($XElements) {
      Write-Warning "Syntax for $($CommandInfo.Name) has already been added to the document."
    } else {
      # Remove the placeholder taken from the template
      SelectXPathXElement `
          -XPathExpression "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/command:syntax[command:syntaxItem/maml:name='']/*" `
          -XContainer $XDocument |
        ForEach-Object {
          $_.Remove() 
        }
      
      $CommandInfo.ParameterSets |
        ForEach-Object {
          $SyntaxItemXElement = GetTemplateXElement 'command:syntaxItem'
          # This will have the place-holder as well.
          $SyntaxItemXElement.Element((GetXNamespace 'command') + 'parameter').Remove()
          $SyntaxItemXElement.Element((GetXNamespace 'maml') + 'name').Value = $CommandInfo.Name
          
          $_.Parameters |
            Where-Object { $_.Name -notin $CommonParameters -and $_.Name -notin $ShouldProcessParameters } |
            ForEach-Object {
              $ParameterXElement = GetTemplateXElement 'command:syntaxItem/command:parameter'
              $ParameterXElement.Element((GetXNamespace 'maml') + 'name').Value = $_.Name
              
              # pipelineInput (ValueFromPipeline*)
              $PipelineInput = "false"
              if ($_.ValueFromPipeline -and $_.ValueFromPipelineByPropertyName) {
                $PipelineInput = "true (ByValue, ByPropertyName)" 
              } elseif ($_.ValueFromPipeline) {
                $PipelineInput = "true (ByValue)" 
              } elseif ($_.ValueFromPipelineByPropertyName) {
                $PipelineInput = "true (ByPropertyName)" 
              }
              $ParameterXElement.Attribute('pipelineInput').Value = $PipelineInput
              
              # position
              $Position = 'named'
              if ($_.Position -ne [Int32]::MinValue) {
                $Position = $_.Position
              }
              $ParameterXElement.Attribute('position').Value = $Position

              # required (Mandatory)
              $ParameterXElement.Attribute('required').Value = $_.IsMandatory.ToString().ToLower()
              
              $ParameterXElement
            } |
            AddXElement -XContainer $SyntaxItemXElement -Parent '.'
            
          $SyntaxItemXElement
        } |
        AddXElement -XContainer $XDocument `
          -Parent "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/command:syntax"
    }
  }

  end {
    if ($psboundparameters.ContainsKey('XDocument')) {
      return $XDocument 
    } elseif ($psboundparameters.ContainsKey('Path')) {
      $XDocument.Save($Path, [System.Xml.Linq.SaveOptions]::OmitDuplicateNamespaces)
    }
  }
}