# DisplayLink Automated Remediation Pipeline

A modular PowerShell automation suite designed to resolve degraded video output, pixelation, and bandwidth throttling when bypassing physical GPU bottlenecks via DisplayLink hardware.

## 🌱 The Hardware Bottleneck (Setup)
* **Laptop:** MSI GF63 Thin 2021 Edition (Intel Core i5, NVIDIA GTX 1650 Max-Q)
* **Monitor:** Xiaomi 4K 60Hz Monitor A27Ui
* **Adapter:** Vention USB to Dual HDMI MST Adapter (DisplayLink)

## 💦 Problem Statement
Due to the legacy HDMI 1.4 port and a data-only USB-C port, this architecture requires a dedicated DisplayLink adapter to drive the external 4K monitor with optimized color fidelity and resolution. 

On the MSI GF63 Thin, the physical video traces do not route to the USB-C port:

```text
[Intel iGPU] ──(Direct Hardware Traces)──> [HDMI Port] ──> [Monitor]
[Intel iGPU] ──(Direct Hardware Traces)──> [USB-C Port (Data Only)] ✖ [Signal Terminated]
```

**The Solution:** The DisplayLink adapter bypasses the physical motherboard traces entirely. It utilizes the CPU to compress display data into standard USB packets, routes them through the data-only USB-C port, and relies on a dedicated Synaptics decoder chip inside the adapter to rebuild the video signal. 

When corrupted legacy display profiles force incorrect scaling or limit color depth over this USB pipeline, the result is heavy macroblocking and pixelation. This script suite completely automates the deep-level remediation of those corrupted profiles.

## ⚙️ Pipeline Architecture
Because a true graphics driver purge requires isolating the OS and altering boot states, this automation is segregated into three blast-radius-contained phases:

1. **`01-Isolate-And-BootSafe.ps1`**: Fetches payloads, severs physical network adapters to block generic Windows Update driver injection, and configures the BCD for a Safe Mode reboot.
2. **`02-Purge-Drivers.ps1`**: Executes silently within Safe Mode, purging both NVIDIA and Intel architectures via DDU, and restores the standard boot flag.
3. **`03-Deploy-DisplayLink.ps1`**: Re-establishes network links and sequentially deploys the DisplayLink core drivers and the MS Store Manager app via Winget.

## 🚀 Execution Instructions

**Prerequisites:** Disconnect your DisplayLink adapter before beginning. Ensure you are running an elevated PowerShell terminal (`Run as Administrator`).

### Step 1: Isolate & Reboot
Run the first script. The system will download the required uninstaller, disable your Wi-Fi, and automatically reboot your machine into Safe Mode.
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\01-Isolate-And-BootSafe.ps1
```

### Step 2: The Purge
Once logged into Safe Mode, run the second script. It will silently wipe the corrupted Intel and NVIDIA drivers and reboot back to normal Windows.
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\02-Purge-Drivers.ps1
```

### Step 3: Deploy & Reconnect
Once back in standard Windows, run the final script to restore your internet connection and pull down the clean DisplayLink drivers. 
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\03-Deploy-DisplayLink.ps1
```

*Once Step 3 completes, plug the DisplayLink adapter back into the laptop.*
