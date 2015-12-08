$psake.use_exit_on_error = $true
properties {
    $currentDir = resolve-path .
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value
    $baseDir = $psake.build_script_dir
    $version = git.exe describe --abbrev=0 --tags
    $nugetExe = "$baseDir\vendor\tools\nuget"
    $targetBase = "tools"
}

Task default -depends Version-Module

Task Version-Module {

}