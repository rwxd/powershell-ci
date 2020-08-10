﻿function Start-Analyzing {
    param(
        [string]$Path = "$PSScriptRoot\",
        [array]$Severity = @("Error", "Warning")
    )

    $Result = Invoke-ScriptAnalyzer -Path $Path -Severity $Severity -Recurse

    # if Invoke-ScriptAnalyzer finds something
    if ($Result) {
        $Result | Format-Table  
        Write-Error -Message "$($Result.SuggestedCorrections.Count) linting errors or warnings were found. The build cannot continue."
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

Start-Analyzing -Path "/mnt/shared/git/private/powershell-analyzer/"

# $ScriptFromGithHub = Invoke-WebRequest https://raw.githubusercontent.com/tomarbuthnot/Run-PowerShell-Directly-From-GitHub/master/Run-FromGitHub-SamplePowerShell.ps1
# Invoke-Expression $($ScriptFromGithHub.Content)