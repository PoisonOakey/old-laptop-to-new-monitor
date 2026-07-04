<#
.SYNOPSIS
    Phase 3: Network Restoration and DisplayLink Deployment.
.DESCRIPTION
    Re-enables network adapters and deploys DisplayLink drivers via Winget.
#>

# 1. Force all silent errors to instantly trigger the Catch block
$ErrorActionPreference = 'Stop'

$DDUFolder = "C:\DDU"
$LogPath = "$DDUFolder\Phase3_Log.txt"
Start-Transcript -Path $LogPath -Append -Force

# 2. The "Try" Block: Execute the dangerous code
try {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Elevated PowerShell terminal required (Run as Administrator)."
    }

    Write-Information "[+] Phase 3: Standard mode restored. Re-establishing physical network links..."
    Enable-NetAdapter -Physical -Confirm:$false

    Write-Information "    [-] Waiting for adapter lease and network stability (15 seconds)..."
    Start-Sleep -Seconds 15

    Write-Information "[+] Deploying DisplayLink Core Driver..."
    winget install -e --id Synaptics.DisplayLink --accept-package-agreements --accept-source-agreements --quiet

    Write-Information "[+] Deploying DisplayLink Manager from MS Store..."
    winget install --id 9N09F8V8FS02 --source msstore --accept-package-agreements --accept-source-agreements --quiet

    Write-Information "[!] Remediation pipeline complete. Plug in the DisplayLink adapter."
}
# 3. The "Catch" Block: If ANYTHING fails above, execution instantly jumps here
catch {
    Write-Information "`n[X] CRITICAL PIPELINE FAILURE"
    Write-Information "Error Details: $($_.Exception.Message)"
    Write-Information "[!] Manual intervention required for package deployment."
}
# 4. The "Finally" Block: This runs no matter what happens
finally {
    Write-Information "[+] Stopping transcript log..."
    Stop-Transcript
}
