#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Script to analyze a folder of powershell scripts recursively.
.EXAMPLE
    PS C:\> ./test.ps1
.PARAMETER Path
    Specifies the path of the target folder.
    Standard is the current folder.
.PARAMETER ExcludeAnalyzerRules
    Array of Rules for the ScriptAnalyzer
    Standard is @("PSUseApprovedVerbs")
#>

param ( 
    $Path = "$PSScriptRoot",
    $ExcludeAnalyzerRules = @("PSUseApprovedVerbs")
)

function Analyze-Syntax {
    <#
    .SYNOPSIS
    Function to start analyzing of a folder with powershell scripts recursively.
    
    .PARAMETER Path
    Specifies the path of the folder to recursively analyze.
    Standard is current script path
    
    .PARAMETER Severity
    Specifies the servity.
    Standard is Error & Warning
    
    .PARAMETER ExcludeRules
    Specifies Rules to exclude.
    
    .EXAMPLE
    Analyze-Syntax -Path $FolderPath -ExcludeRules $ExcludeAnalyzerRules
    #>
    param(
        [string]$Path = "$PSScriptRoot",
        [array]$Severity = @("Error", "Warning"),
        [array]$ExcludeRules = @()
    )

    Write-Host "Analyzing $Path recursively"
    $Result = Invoke-ScriptAnalyzer -Path $Path -Severity $Severity -Recurse -ExcludeRule $ExcludeRules

    # if Invoke-ScriptAnalyzer finds something
    if ($Result) {
        $Result | Format-Table  
        if ($Result.SuggestedCorrections.Count -gt 0) {
            Write-Error -Message "$($Result.SuggestedCorrections.Count) linting errors or warnings were found. The build cannot continue."
        }
        EXIT 1
    }
}

function Install-Dependency {
    param (
        [String]$Name
    )
    # set PSGallery to trusted repository
    $policy = Get-PSRepository -Name "PSGallery" | Select-Object -ExpandProperty "InstallationPolicy"
    if ($policy -ne "Trusted") {
        Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
    }

    # install module if not local available
    if (!(Get-Module -Name $Name -ListAvailable)) { 
        Install-Module -Name $Name -Scope CurrentUser
    }
}

Install-Dependency -Name "PSScriptAnalyzer"
Install-Dependency -Name "Pester"

Analyze-Syntax -Path $Path -ExcludeRules $ExcludeAnalyzerRules