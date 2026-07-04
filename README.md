# DisplayLink Automated Remediation

A 3-phase PowerShell pipeline that clean-installs DisplayLink drivers on older laptops to enable 4K external monitor output. Handles Safe Mode cycling, dual-GPU driver purging (via DDU), and automated DisplayLink deployment — all with transcript logging and fail-safe error handling.

## Prerequisites

- **OS**: Windows 10 / 11
- **Shell**: PowerShell 5.1+
- **Privileges**: Run as Administrator (all 3 scripts require elevation)
- **Tools**: [Winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/) (pre-installed on Windows 11; install via MS Store on Windows 10)
- **Network**: Active internet connection (Phase 1 disables adapters; Phase 3 re-enables them)

## How It Works

The pipeline runs across **two reboots** in three sequential phases:

| Phase | Script | What It Does |
|-------|--------|-------------|
| 1 | `01-Isolate-And-BootSafe.ps1` | Downloads DDU, disables network adapters, reboots into Safe Mode |
| 2 | `02-Purge-Drivers.ps1` | Silently purges NVIDIA + Intel GPU drivers via DDU, exits Safe Mode, reboots |
| 3 | `03-Deploy-DisplayLink.ps1` | Re-enables network, installs DisplayLink Core Driver + Manager via Winget |

> **Note**: Each phase must be run manually after the preceding reboot. They are not daisy-chained automatically because Safe Mode restricts script execution.

## Usage

Run each script **as Administrator** in order, rebooting between phases:

```powershell
# Phase 1 — Run in normal Windows, triggers Safe Mode reboot
powershell.exe -ExecutionPolicy Bypass -File ".\scripts\01-Isolate-And-BootSafe.ps1"

# Phase 2 — Run after booting into Safe Mode
powershell.exe -ExecutionPolicy Bypass -File ".\scripts\02-Purge-Drivers.ps1"

# Phase 3 — Run after rebooting back to normal Windows
powershell.exe -ExecutionPolicy Bypass -File ".\scripts\03-Deploy-DisplayLink.ps1"
```

## Safety Features

- **Transcript logging**: Every phase writes a timestamped log to `C:\DDU\`
- **Safe Mode boot loop prevention**: Phase 2 removes the Safe Mode flag in both the `try` and `catch` blocks, so a DDU crash won't strand the user
- **Network failsafe**: Phase 1 re-enables adapters if it fails after disabling them
- **Admin check**: All scripts abort immediately if not running elevated

## Logs

Transcript logs are written to:

```
C:\DDU\Phase1_Log_<timestamp>.txt
C:\DDU\Phase2_Log.txt
C:\DDU\Phase3_Log.txt
```

## License

[MIT](LICENSE)
