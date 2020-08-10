# powershell-analyzer
Script to analyze powershell code syntax.

## Manual execution
Execute with
```powershell
$ScriptFromGithHub = Invoke-WebRequest https://raw.githubusercontent.com/ProfileID/powershell-ci/master/test.ps1
Invoke-Expression $($ScriptFromGithHub.Content)
```

