function GetReservedParameterNames {
  # .SYNOPSIS
  #   Get parameter names which are reserved and not necessarily expected to be documented.
  # .DESCRIPTION
  #   Internal use only.
  # .OUTPUTS
  #   System.String[]
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log
  #     13/11/2015 - Chris Dent - Created.

  if ($script:ReservedParameterNames) {
    return $script:ReservedParameterNames
  } else {
    $script:ReservedParameterNames = ([System.Management.Automation.Internal.CommonParameters]).GetProperties() | Select-Object -ExpandProperty Name
    $script:ReservedParameterNames += ([System.Management.Automation.Internal.ShouldProcessParameters]).GetProperties() | Select-Object -ExpandProperty Name
  }
}