<#
.SYNOPSIS
    Phase 1: Environment Preparation and Network Isolation.
.DESCRIPTION
    Downloads DDU, disables physical network adapters, and reboots into Safe Mode.
    Includes automated transcript logging and fail-safe error handling.
#>

# 1. Force all silent errors to instantly trigger the Catch block
$ErrorActionPreference = 'Stop'

# 2. Establish Logging
$DDUFolder = "C:\DDU"
if (-not (Test-Path $DDUFolder)) { New-Item -ItemType Directory -Path $DDUFolder | Out-Null }

$LogPath = "$DDUFolder\Phase1_Log_$(Get-Date -Format 'yyyyMMdd_HHmm').txt"
Start-Transcript -Path $LogPath -Append -Force

# 3. The "Try" Block: Execute the dangerous code
try {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Elevated PowerShell terminal required (Run as Administrator)."
    }

    Write-Information "[+] Phase 1: Deploying infrastructure and fetching DDU..."
    Set-Location -Path $DDUFolder
    if (-not (Test-Path "$DDUFolder\Display Driver Uninstaller.exe")) {
        Write-Information "    [-] Downloading payload..."
        curl.exe -L -O "https://www.wagnardsoft.com/DDU/download/DDU%20v18.0.7.4.exe"
        .\DDU%20v18.0.7.4.exe -y | Out-Null
    }

    Write-Information "[+] Isolating physical network adapters..."
    Disable-NetAdapter -Physical -Confirm:$false

    Write-Information "[+] Configuring system for Safe Mode boot state..."
    bcdedit /set "{current}" safeboot minimal | Out-Null

    Write-Information "[!] Phase 1 Complete. Restarting into Safe Mode in 5 seconds..."
    Start-Sleep -Seconds 5
    Restart-Computer
}
# 4. The "Catch" Block: If ANYTHING fails above, execution instantly jumps here
catch {
    Write-Information "`n[X] CRITICAL PIPELINE FAILURE"
    Write-Information "Error Details: $($_.Exception.Message)"
    Write-Information "[!] Aborting Safe Mode reboot to prevent system stranding."
    # Failsafe: Attempt to turn Wi-Fi back on in case it failed right after disabling it
    Enable-NetAdapter -Physical -Confirm:$false -ErrorAction SilentlyContinue
}
# 5. The "Finally" Block: This runs no matter what happens
finally {
    Write-Information "[+] Stopping transcript log..."
    Stop-Transcript
}