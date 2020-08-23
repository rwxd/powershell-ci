#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Script to lint a folder of powershell scripts recursively and run pester tests.
.EXAMPLE
    PS C:\> ./build.ps1
.PARAMETER Path
    Specifies the path of the target folder.
    Default is the current folder.
.PARAMETER ExcludeAnalyzerRules
    Array of Rules for the ScriptAnalyzer.
    Default is @("PSUseApprovedVerbs").
.PARAMETER Linting
    Option to use linting with PSScriptAnalyzer.
    Default is true.
.PARAMETER Pester
    Option to use pester tests.
    Default is false.
    #>

param ( 
    $Path = "$PSScriptRoot",
    $ExcludeAnalyzerRules = @("PSUseApprovedVerbs"),
    $Linting = $true,
    $Pester = $false
)

function Run-Linting {
    <#
    .SYNOPSIS
    Function to start analyzing of a folder with powershell scripts recursively.
    
    .PARAMETER path
    Specifies the path of the folder to recursively analyze.
    Default is current script path
    
    .PARAMETER severity
    Specifies the servity.
    Default is Error & Warning.
    
    .PARAMETER exclude_rules
    Specifies Rules to exclude.
    
    .EXAMPLE
    Analyze-Syntax -Path $FolderPath -exclude_rules $ExcludeAnalyzerRules.
    #>
    param(
        [string]$path = "$PSScriptRoot",
        [array]$severity = @("Error", "Warning"),
        [array]$exclude_rules = @()
    )

    Write-Output -InputObject "Analyzing $path recursively"
    $Result = Invoke-ScriptAnalyzer -Path $path -Severity $severity -Recurse -ExcludeRule $exclude_rules

    # if Invoke-ScriptAnalyzer finds something
    if ($Result) {
        $Result | Format-Table  
        if ($Result.SuggestedCorrections.Count -gt 0) {
            Write-Error -Message "$($Result.SuggestedCorrections.Count) linting errors or warnings were found. The build cannot continue."
        }
        EXIT 1
    }
}

function Run-Tests {
    <#
    .SYNOPSIS
    Function to run Pester Tests in a folder.
    
    .PARAMETER path
    Specifies the path of the folder to recursively analyze.
    Default is current script path.
    
    .EXAMPLE
    Start-Tests
    
    .NOTES
    #>
    param (
        [string]$path = "$$PSScriptRoot"
    )

    $result = Invoke-Pester -Path $path -PassThru -Quiet

    # if errors in result
    if ($Result.FailedCount -gt 0) {
        Write-Output "$($Result.FailedCount) tests failed."

        # print each failed test
        foreach ($test in ($result | Where-Object { $_.Passed -eq $false } | Select-Object -Property Describe, Context, Name, Passed, Time)) {
            Write-Output $test
        }
        EXIT 1
    }
    
}

function Install-Dependency {
    <#
    .SYNOPSIS
    Function to install Dependencys.
    
    .PARAMETER name
    Name of the Powershell Module in the PSGallery.
    
    .EXAMPLE
    Install-Dependency -Name "PSScriptAnalyzer"
    Install-Dependency -Name "Pester"
    
    .NOTES
    #>
    param (
        [String]$name
    )
    # set PSGallery to trusted repository
    $policy = Get-PSRepository -Name "PSGallery" | Select-Object -ExpandProperty "InstallationPolicy"
    if ($policy -ne "Trusted") {
        Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
    }

    # install module if not local available
    if (!(Get-Module -Name $name -ListAvailable)) {
        Write-Output -InputObject "Installing Dependency $name" 
        Install-Module -Name $name -Scope CurrentUser
    }
}


if ($Linting) {
    Install-Dependency -Name "PSScriptAnalyzer"
    Run-Linting -Path $path -exclude_rules $ExcludeAnalyzerRules
}
if ($Pester) {
    Install-Dependency -Name "Pester"
    Run-Tests -Path $path
}