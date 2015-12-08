function UpdateHelpSyntax {
  # .SYNOPSIS
  #   Set the syntax section of the help file.
  # .DESCRIPTION
  #   Syntax is generated from the CommandInfo. ParameterSets are documented and an appropriate number of attribute are set for each parameter.
  #
  #   The XML schema shows the same values available for both the syntax and parameters sections. The majority of the information which may be written (as stated in the schema) is ignored when help is read.
  # .PARAMETER CommandInfo
  #   The command to add.
  # .INPUTS
  #   System.Management.Automation.CommandInfo
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

  [CmdletBinding()]
  [OutputType([System.Xml.Linq.XDocument])]
  param(
    [System.Management.Automation.CommandInfo]$CommandInfo,
    
    [System.Xml.Linq.XDocument]$XDocument
  )

  # Get-HelpDocumentItem -Item 'Syntax/'

  $XElements = SelectXPathXElement `
    -XPathExpression "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/command:syntax[command:syntaxItem/maml:name='$($CommandInfo.Name)']/*" `
    -XContainer $XDocument
      
  # Remove the placeholder taken from the template
  SelectXPathXElement `
      -XPathExpression "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/command:syntax[command:syntaxItem/maml:name='']/*" `
      -XContainer $XDocument |
    ForEach-Object {
      $_.Remove() 
    }
      
  $CommandInfo.ParameterSets |
    Where-Object { $_.Parameters } |
    ForEach-Object {
      $ParameterSetName = $_.Name
      Write-Verbose "    Creating syntax\syntaxItem for $ParameterSetName"
      
      $SyntaxItemXElement = GetTemplateXElement 'command:syntaxItem'
      # This will have the place-holder as well.
      $SyntaxItemXElement.Element((GetXNamespace 'command') + 'parameter').Remove()
      $SyntaxItemXElement.Element((GetXNamespace 'maml') + 'name').Value = $CommandInfo.Name
      
      $_.Parameters |
        Where-Object { $_.Name -notin (GetReservedParameterNames) } |
        ForEach-Object {
          Write-Verbose "      Creating syntax\syntaxItem\parameter for $($_.Name)"
          
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
          
          # ParameterValue
          if ($_.ParameterType -eq [Switch]) {
            $ParameterXElement.Element((GetXNamespace 'command') + 'parameterValue').Remove()
          } else {
            $ParameterXElement.Element((GetXNamespace 'command') + 'parameterValue').Value = $_.ParameterType.Name
          }
          
          $ParameterXElement
        } |
        AddXElement -XContainer $SyntaxItemXElement -Parent '.'

      AddXElement `
        -XElement $SyntaxItemXElement `
        -XContainer $XDocument `
        -Parent "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/command:syntax" `
        -Comment $ParameterSetName
    }
}