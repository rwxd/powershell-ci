# PowerShell-CI
![tests](https://github.com/ProfileID/powershell-ci/workflows/tests/badge.svg)

## About PowerShell-CI
Script to lint PowerShell code and run [Pester](https://pester.dev/docs/quick-start) tests. 

## Usage
Run on current folder.
```bash
pwsh ./build.ps1
```

Run on different folder.
```bash
pwsh ./build.ps1 -Path /tmp/script_folder/
```

Run with Pester Tests.
```bash
pwsh ./build.ps1 -Pester
```

Exclude Analyzer Rules
```bash
pwsh ./build.ps1 -ExcludeAnalyzerRules @("PSUseApprovedVerbs")
```

## Example Github Actions Workflow
```yaml
name: Example Workflow
on: [push]
jobs:
  build:
    runs-on: ${{ matrix.images }}
    strategy:
      matrix:
        images: ["ubuntu-latest"]
    steps:
    - uses: actions/checkout@v2
    - name: Install PowerShell & Git
      run: sudo apt install -y git powershell
    - name: Clone CI repository
      run: |
        git clone https://github.com/ProfileID/powershell-ci /tmp/powershell-ci
        chmod 755 -R /tmp/powershell-ci
    - name: Run build.ps1
      run: pwsh /tmp/powershell-ci/build.ps1 -Path $GITHUB_WORKSPACE
```