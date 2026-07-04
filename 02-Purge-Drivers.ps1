<#
.SYNOPSIS
    Phase 2: Dual-GPU Driver Purge.
.DESCRIPTION
    Executes a silent DDU wipe for NVIDIA and Intel architectures within Safe Mode,
    removes the Safe Mode boot flag, and restarts the system.
#>

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Elevated PowerShell terminal required (Run as Administrator)."
    Exit
}

# Verify Safe Mode environment constraint
if (-not (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SafeBoot\Option" -ErrorAction SilentlyContinue)) {
    Write-Error "Critical error: Safe Mode environment not detected. Aborting purge."
    Exit
}

$DDUFolder = "C:\DDU"
Write-Information "[+] Phase 2: Safe Mode confirmed. Initiating silent DDU purge..."
Set-Location $DDUFolder

Write-Information "    [-] Evicting NVIDIA driver allocations..."
.\Display Driver Uninstaller.exe -silent -nvidiaspecific -cleannorestart

Write-Information "    [-] Evicting Intel Graphics driver allocations..."
.\Display Driver Uninstaller.exe -silent -intelspecific -cleannorestart

Write-Information "[+] Dismantling Safe Mode configuration flag..."
bcdedit /deletevalue "{current}" safeboot | Out-Null

Write-Information "[!] Purge phase complete. Reverting to standard operating environment..."
Start-Sleep -Seconds 3
Restart-Computer