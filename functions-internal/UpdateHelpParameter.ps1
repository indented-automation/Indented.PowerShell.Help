function UpdateHelpParameter {
  # .SYNOPSIS
  #   Update the parameters section of the help file.
  # .DESCRIPTION
  #   Update the parameters section based on the param block of a command.
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
  #   Set-HelpParameters (Get-Command Get-Process)
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
      
  # Remove the placeholder taken from the template if it's still present and there are parameters which may be added
  $Parameters = $CommandInfo.Parameters.Values |
    Where-Object { $_.Name -notin (GetReservedParameterNames) }

  if ($Parameters) {
    SelectXPathXElement `
        -XPathExpression "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/command:parameters[command:parameter/maml:name='']/*" `
        -XContainer $XDocument |
      ForEach-Object {
        $_.Remove() 
      }
  
    $Parameters |
      ForEach-Object {
          $IsNew = $false

          # Attempt to select an existing instance of the parameter
          $ParameterXElement = SelectXPathXElement `
            -XPathExpression "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/command:parameters[command:parameter/maml:name='$($_.Name)']/*" `
            -XContainer $XDocument
          
          if ($ParameterXElement.Count -gt 0) {
            Write-Verbose "$($CommandInfo.Name): Updating parameters\parameter block for $($_.Name)"
          } else {
            Write-Verbose "$($CommandInfo.Name): Creating parameters\parameter block for $($_.Name)"
            $ParameterXElement = GetTemplateXElement 'command:parameters/command:parameter'
            $ParameterXElement.Element((GetXNamespace 'maml') + 'name').Value = $_.Name
            $IsNew = $true
          }
          
          # Aliases - Doesn't appear to be supported by the Schema. It'll be interesting if Help uses them anyway, we'll see when we get to testing.
          #$Aliases = ''
          #if ($_.Aliases) {
          #  $Aliases = $_.Aliases -join ', '
          #}
          
          # pipelineInput
          $ValueFromPipeline = $ValueFromPipelineByPropertyName = $false
          $_.ParameterSets.Values |
            ForEach-Object {
              if ($_.ValueFromPipeline) { $ValueFromPipeline = $true } 
              if ($_.ValueFromPipelineByPropertyName) { $ValueFromPipelineByPropertyName = $true } 
            }
          $PipelineInput = 'false'
          if ($ValueFromPipeline -and $ValueFromPipelineByPropertyName) {
            $PipelineInput = "true (ByValue, ByPropertyName)" 
          } elseif ($ValueFromPipeline) {
            $PipelineInput = "true (ByValue)" 
          } elseif ($ValueFromPipelineByPropertyName) {
            $PipelineInput = "true (ByPropertyName)" 
          }
          $ParameterXElement.Attribute('pipelineInput').Value = $PipelineInput
          
          # position
          $Position = 'named'
          if ($CommandInfo.DefaultParameterSet) {
            $Key = $CommandInfo.DefaultParameterSet 
          } else {
            $Key = 0 
          }
          if ($_.ParameterSets[$Key].Position -ne $null -and $_.ParameterSets[$Key].Position -gt [Int32]::MinValue) {
            $Position = $_.ParameterSets[$Key].Position
          }
          $ParameterXElement.Attribute('position').Value = $Position
          
          # required (Mandatory)
          $IsMandatory = [Boolean]($_.ParameterSets.Values.IsMandatory | Where-Object { $_ -eq $true })
          $ParameterXElement.Attribute('required').Value = $IsMandatory.ToString().ToLower()
  
          # ParameterValue
          $ParameterXElement.Element((GetXNamespace 'command') + 'parameterValue').Value = $_.ParameterType.Name
  
          # ParameterType
          $ParameterXElement.Element((GetXNamespace 'dev') + 'type').`
                             Element((GetXNamespace 'maml') + 'name').`
                             Value = $_.ParameterType.Name
                             
          # Validation - Including these may not be desirable, or the default values may need to be tweaked a bit.
          $_.Attributes |
            Where-Object { $_ -is [System.Management.Automation.ValidateArgumentsAttribute] } |
            ForEach-Object {
              $Validator = $_
              switch ($Validator.TypeId) {
                ([System.Management.Automation.ValidateCountAttribute]) {
                  $ParameterXElement.Element((GetXNamespace 'command') + 'validation').`
                                     Element((GetXNamespace 'command') + 'minCount').`
                                     Value = $Validator.MinLength
                  $ParameterXElement.Element((GetXNamespace 'command') + 'validation').`
                                     Element((GetXNamespace 'command') + 'maxCount').`
                                     Value = $Validator.MaxLength
                  break
                }
                ([System.Management.Automation.ValidateLengthAttribute]) {
                  $ParameterXElement.Element((GetXNamespace 'command') + 'validation').`
                                     Element((GetXNamespace 'command') + 'minLength').`
                                     Value = $Validator.MinLength
                  $ParameterXElement.Element((GetXNamespace 'command') + 'validation').`
                                     Element((GetXNamespace 'command') + 'maxLength').`
                                     Value = $Validator.MaxLength
                  break
                }
                ([System.Management.Automation.ValidatePatternAttribute]) {
                  $ParameterXElement.Element((GetXNamespace 'command') + 'validation').`
                                     Element((GetXNamespace 'command') + 'pattern').`
                                     Value = $Validator.RegexPattern
                  break
                }
                ([System.Management.Automation.ValidateRangeAttribute]) {
                  $ParameterXElement.Element((GetXNamespace 'command') + 'validation').`
                                     Element((GetXNamespace 'command') + 'minRange').`
                                     Value = $Validator.MinRange
                  $ParameterXElement.Element((GetXNamespace 'command') + 'validation').`
                                     Element((GetXNamespace 'command') + 'maxRange').`
                                     Value = $Validator.MaxRange
                  break
                }
              }
            }
  
        if ($IsNew) {
          $ParameterXElement
        }
      } |
      AddXElement -XContainer $XDocument `
        -Parent "/helpItems/command:command[command:details/command:name='$($CommandInfo.Name)']/command:parameters" `
        -SortBy './maml:name'
  }
  
  return $XDocument
}