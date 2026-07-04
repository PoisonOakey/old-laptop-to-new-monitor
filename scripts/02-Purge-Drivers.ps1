<#
.SYNOPSIS
    Phase 2: Dual-GPU Driver Purge.
.DESCRIPTION
    Executes a silent DDU wipe for NVIDIA and Intel within Safe Mode.
    Includes automated transcript logging and a fail-safe to prevent Safe Mode boot loops.
#>

$ErrorActionPreference = 'Stop'

$DDUFolder = "C:\DDU"
$LogPath = "$DDUFolder\Phase2_Log.txt"
Start-Transcript -Path $LogPath -Append -Force

try {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Elevated PowerShell terminal required (Run as Administrator)."
    }

    if (-not (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SafeBoot\Option" -ErrorAction SilentlyContinue)) {
        throw "Safe Mode environment not detected. Aborting purge to protect live system."
    }

    Write-Information "[+] Phase 2: Safe Mode confirmed. Initiating silent DDU purge..."
    Set-Location -Path $DDUFolder

    Write-Information "    [-] Evicting NVIDIA driver allocations..."
    .\Display Driver Uninstaller.exe -silent -nvidiaspecific -cleannorestart

    Write-Information "    [-] Evicting Intel Graphics driver allocations..."
    .\Display Driver Uninstaller.exe -silent -intelspecific -cleannorestart

    Write-Information "[+] Dismantling Safe Mode configuration flag..."
    bcdedit /deletevalue "{current}" safeboot | Out-Null

    Write-Information "[!] Purge phase complete. Reverting to standard operating environment..."
    Start-Sleep -Seconds 3
    Restart-Computer
}
catch {
    Write-Information "`n[X] CRITICAL PIPELINE FAILURE"
    Write-Information "Error Details: $($_.Exception.Message)"
    Write-Information "[!] Applying emergency Boot Configuration fix to prevent Safe Mode trap..."
    # Failsafe: If DDU crashes, remove the safeboot flag anyway so the user isn't stuck forever.
    bcdedit /deletevalue "{current}" safeboot | Out-Null
}
finally {
    Write-Information "[+] Stopping transcript log..."
    Stop-Transcript
}