# Older Laptop, Newer Monitor

## :seedling: Setup
1. MSI GF63 Thin 2021 Edition (Intel I5, Nvidia Gtx 1650 Max Q)
2. Xiaomi 4K 60Hz Monito A27Ui
3. Vention USB to Dual HDMI MST Adpater

## :sweat_drops: Problem Statement
Due to the old HDMI 1.4 and data-only USB-C port, the laptop needs a dedicate DisplayLink adapter to drive the external monitor with optimized color fidelity & resolution. 

Normally, the GPU connects directly to physical video traces on the motherboard that lead straight to a video output. But since MSI GF63 Thin's USB-C port is wired solely for USB data protocol pins, the native video signal physically can't reach the port. 
> [!NOTE]
> On the GF63 Thin, the HDMI port is routed through the Intel integrated graphics (iGPU), not the NVIDIA GTX 1650.

```
[Intel iGPU] ──(Direct Hardware Traces)──> [HDMI Port] ──> [Monitor]
[Intel iGPU] ──(Direct Hardware Traces)──> [USB-C Port (Data Only)] ✖ [Signal Terminated]
```

DisplayLink adapter however, ignored the physical video traces entirely. It uses the CPU to compress the display data into standard network/ USB packets, and send it across the data pins of the USB-C port. Then, the GPU chip inside the adapter will do the heavy lifting of rebuilding the video signal.

<img width="512" height="280" alt="image" src="https://github.com/user-attachments/assets/f74cdc9b-d23d-47c7-9ae9-de65c5ea3ebb" />

<br>
<br>

## :sunny: Troubleshooting Steps
### Step #1: Clean Driver Wipe
Corrupted display profiles often force incorrect scaling or limited color depth, resulting in a pixelated image. A clean installation resets the baseline output.

1. Download Display Driver Uninstaller (DDU). 
```
# 1. Create the target directory and navigate into it
mkdir C:\DDU
cd C:\DDU

# 2. Curl the payload directly from the developer's server
# Note: This points to v18.0.7.4. If it 404s, they pushed an update, and you just swap the version numbers.
curl.exe -L -O "https://www.wagnardsoft.com/DDU/download/DDU%20v18.0.7.4.exe"

# 3. The payload is a self-extracting 7-Zip archive. Execute it silently (-y answers 'yes' to prompts).
.\DDU%20v18.0.7.4.exe -y
```
<br>

2. Disconnect from the internetand boot to Safe Mode so Windows Update doesn't immediately try to download generic drivers.
> [!IMPORTANT]
> Once your laptop boots up in Safe Mode, the graphics will look sharper. That is normal.

```
# Disables Wi-Fi to stop Windows Update from downloading generic drivers
Disable-NetAdapter -Name "*" -Confirm:$false

# Forces the next restart into Safe Mode
bcdedit /set "{current}" safeboot minimal

# Restarts the laptop immediately
Restart-Computer
```
<br>

3. Wipe NVIDIA, then Intel GPU drivers, and automatically restart your laptop back into normal Windows.
```
# Navigate to the DDU folder you created
cd "C:\DDU"

# Silently wipe the GTX 1650 Max-Q driver without restarting
.\Display Driver Uninstaller.exe -silent -nvidiaspecific -cleannorestart

# Remove the Safe Mode flag so the laptop boots normally next time
bcdedit /deletevalue "{current}" safeboot

# Silently wipe the Intel UHD driver and automatically restart
.\Display Driver Uninstaller.exe -silent -intelspecific -cleanrestart
```
<br>

5. Reconnect & reinstall:
```
# Turn the Wi-Fi back on
Enable-NetAdapter -Name "*" -Confirm:$false

# Automatically download and install the Intel UHD Graphics Driver
winget install -e --id Intel.GraphicsDriver --accept-package-agreements --accept-source-agreements

# Automatically download and install the NVIDIA GeForce Driver
winget install -e --id Nvidia.GeForceGameReadyDriver --accept-package-agreements --accept-source-agreements
```
<br>

### Step #2: Bandwidth Limit and Chroma Subsampling Calibration
