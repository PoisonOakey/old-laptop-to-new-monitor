<#
.SYNOPSIS
    Phase 1: Environment Preparation and Network Isolation.
.DESCRIPTION
    Downloads DDU, disables physical network adapters to prevent generic driver
    injection, and reboots the system into Safe Mode.
#>

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Elevated PowerShell terminal required (Run as Administrator)."
    Exit
}

$DDUFolder = "C:\DDU"
if (-not (Test-Path $DDUFolder)) { New-Item -ItemType Directory -Path $DDUFolder | Out-Null }

Write-Information "[+] Phase 1: Deploying infrastructure and fetching DDU..."
Set-Location $DDUFolder
if (-not (Test-Path "$DDUFolder\Display Driver Uninstaller.exe")) {
    curl.exe -L -O "https://www.wagnardsoft.com/DDU/download/DDU%20v18.0.7.4.exe"
    .\DDU%20v18.0.7.4.exe -y | Out-Null
}

Write-Information "[+] Isolating physical network adapters to block Windows Update..."
Disable-NetAdapter -Physical -Confirm:$false

Write-Information "[+] Configuring system for Safe Mode boot state..."
bcdedit /set "{current}" safeboot minimal | Out-Null

Write-Information "[!] Phase 1 Complete. Restarting into Safe Mode in 5 seconds..."
Start-Sleep -Seconds 5
Restart-Computer