<#
.SYNOPSIS
    Phase 3: Network Restoration and DisplayLink Deployment.
.DESCRIPTION
    Re-enables physical network adapters and deploys the DisplayLink core drivers
    and Microsoft Store Manager application via Winget.
#>

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Elevated PowerShell terminal required (Run as Administrator)."
    Exit
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