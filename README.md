# DisplayLink Automated Remediation Pipeline

A modular PowerShell automation suite designed to resolve degraded video output, pixelation, and bandwidth throttling when bypassing physical GPU bottlenecks via DisplayLink hardware.

## 🌱 The Hardware Bottleneck
* **Laptop:** MSI GF63C Thin (Intel Core i5, NVIDIA GTX 1650 Max-Q)
* **Monitor:** Xiaomi 4K 60Hz Monitor A27Ui
* **Adapter:** Vention USB to Dual HDMI MST Adapter (DisplayLink)

## 💦 Problem Statement
The MSI GF63 Thin's USB-C port is data-only. It lacks physical video traces to the GPU:

```text
[Intel iGPU] ──(Direct Traces)──> [HDMI 1.4 Port] ──> [Monitor]
[Intel iGPU] ──(Direct Traces)──> [USB-C Port] ✖ [Signal Terminated]
```

To drive a 4K monitor, a DisplayLink adapter is required to bypass the motherboard and route compressed video data over standard USB protocols. When legacy display drivers corrupt this USB pipeline, it causes severe macroblocking and pixelation. This suite automates the deep-level OS remediation required to restore a clean 5Gbps video stream.

<img width="1024" height="559" alt="articwimds" src="https://github.com/user-attachments/assets/34bf3727-9313-45cb-8734-f1db923f9dca" />


## ⚙️ Pipeline Architecture
A true graphics driver purge requires isolating the OS and altering boot states. To contain the blast radius across system restarts, the execution is segregated into three distinct phases:

```text
📁 DisplayLink-Automated-Remediation/
├── 📄 01-Isolate-And-BootSafe.ps1  # Prepares environment & forces Safe Mode
├── 📄 02-Purge-Drivers.ps1         # Silently executes DDU dual-GPU wipe
└── 📄 03-Deploy-DisplayLink.ps1    # Restores network & installs clean DisplayLink UI/Drivers
```

## 🚀 Execution Instructions

**Prerequisites:** Disconnect your DisplayLink adapter before beginning. Ensure you are running an elevated PowerShell terminal (`Run as Administrator`).

### Step 1: Isolate & Reboot
Downloads uninstaller payloads, disables physical network adapters to block Windows Update hijacking, and automatically reboots into Safe Mode.
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\01-Isolate-And-BootSafe.ps1
```

### Step 2: The Purge
*(Run after logging into Safe Mode)*. Silently wipes corrupted Intel/NVIDIA drivers and reboots back to standard Windows.
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\02-Purge-Drivers.ps1
```

### Step 3: Deploy & Reconnect
*(Run after returning to normal Windows)*. Restores internet connectivity and pulls clean DisplayLink drivers via Winget.
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\03-Deploy-DisplayLink.ps1
```

*Once Step 3 completes, plug the DisplayLink adapter back into the laptop.*

## License

[MIT](LICENSE)
