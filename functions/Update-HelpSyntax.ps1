function Update-HelpSyntax {
  # .SYNOPSIS
  #   Update the syntax section of the help file.
  # .DESCRIPTION
  #   Syntax is automatically generated from the CommandInfo. ParameterSets are documented and an appropriate number of attribute are set for each parameter.
  #
  #   The XML schema shows the same values available for both the syntax and parameters sections. The majority of the information which may be written (as stated in the schema) is ignored when help is read.
  # .PARAMETER CommandInfo
  #   The command to add.
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
    [System.Xml.Linq.XDocument]$XDocument
  )

  process {
    Set-HelpSyntax @psboundparameters -Force
  }
}