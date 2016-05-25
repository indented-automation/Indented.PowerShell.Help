# Descriptive document creation
function helpdocument {
    # .SYNOPSIS
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 1)]
        [String]$Name,

        [Parameter(Mandatory = $true, Position = 2)]
        [ScriptBlock]$Document
    )
    
    # Validate the script block is reasonable
    
    $Predicate = { 
        param(
            $Ast
        )
        
        
    }
    if ($Document.Ast.FindAll($Predicate, $false)) {
        # Die, invalid script block
    }

    # Create or open the help document
    
    if (Test-Path $Name) {
        $Path = $pscmdlet.GetResolvedProviderPathFromPSPath($Name, [Ref]$null)
    } elseif ($Name.EndsWith('.xml')) {
        $Path = $pscmdlet.GetUnresolvedProviderPathFromPSPath($Name)
    } elseif ($($Module = Get-Module $Name; $Module)) {
        $Path = $Module.ModuleBase
    } elseif ($($Module = Get-Module $Name -ListAvailable; $Module)) {
        $Path = $Module.ModuleBase
    }
    
    $functionsToDefine = Get-Command -Module $myinvocation.MyCommand.ModuleName
    $Document.InvokeWithContext($functionsToDefine, $null)
}

function command {
    [CmdletBinding()]
    param( 
        [Object]$CommandInfo,
        
        [ScriptBlock]$Content
    )
    
    if ($CommandInfo -isnot [System.Management.Automation.CommandInfo]) {
        # Attempt to find the command
        if ($($CommandInfo = Get-Command -Name $CommandInfo.ToString(); -not $CommandInfo)) {
            # Die
        }
    }
    
    $Content.InvokeWithContext($functionsToDefine, $null)
}

function synopsis {
    [CmdletBinding()]
    param(
        [String]$Synopsis
    )
    
}

function description {
    [CmdletBinding()]
    param(
        [String]$Description
    )
    
}

function parameter {
    [CmdletBinding()]
    param(
        [String]$Name,
        
        [Hashtable]$Properties
    )
}

function inputs {
    [CmdletBinding()]
    param(
        [String[]]$Inputs
    )
}

function outputs {
    [CmdletBinding()]
    param(
        [String[]]$Inputs
    )
    
}

function example {
    [CmdletBinding()]
    param(
        [String]$Name,
        
        [String]$Comment,
        
        [String]$Code
    )
}

function notes {
    [CmdletBinding()]
    param(
        [String]$Notes
    )
    
}

function ConvertFrom-CommentBasedHelp {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [Object]$InputObject
    )
    
    process {
        # Attempt to resolve whatever has been passed to either a command or module.
        if ($InputObject -isnot [System.Management.Automation.CommandInfo] -and $InputObject -isnot [System.Management.Automation.PSModuleInfo]) {
            if ($($moduleInfo = Get-Module -Name $InputObject.ToString(); $moduleInfo)) {
                $InputObject = $ModuleInfo
            } elseif ($($moduleInfo = Get-Module -Name $InputObject.ToString() -ListAvailable; $moduleInfo)) {
                $InputObject = $moduleInfo
            } elseif ($($functionInfo = Get-Command -Name $InputObject.ToString(); $functionInfo)) {
                $InputObject = $functionInfo
            } else {
                $errorRecord = New-Object System.Management.Automation.ErrorRecord(
                    (New-Object InvalidArgumentException $Script:LocalizedData.InvalidCommandOrModule),
                    'InvalidCommandOrModule',
                    [System.Management.Automation.ErrorCategory]::InvalidArgument,
                    $InputObject
                )
                $pscmdlet.ThrowTerminatingError($errorRecord)
            }
        }

        # If this is a module, get the functions exported by the module.
        if ($InputObject -is [System.Management.Automation.PSModuleInfo]) {
            $InputObject.ExportedCommands.Values.Where( { $_ -is [System.Management.Automation.FunctionInfo] } ) | ConvertFrom-CommentBasedHelp
        }
        
        # If it's a function, begin conversion.
        if ($InputObject -is [System.Management.Automation.FunctionInfo]) {
            Write-Verbose -Message ($Script:LocalizedData.ConvertingFromCommentHelp -f $InputObject.Name)

            if ($InputObject.ModuleName) {
                $documentHandle = $InputObject.ModuleName
            } else {
                $documentHandle = $InputObject.Name
            }
            
            # Working document
            
        } elseif ($InputObject -is [System.Management.Automation.CommandInfo]) {
            Write-Verbose -Message ($Script:LocalizedData.NotFunctionInfo -f $InputObject.Name)
        }
    }
}