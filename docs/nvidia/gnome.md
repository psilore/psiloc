# ThinkPad P15s Gen 1 - Debian 13 Optimization Guide

This guide documents the configuration required to fix "Black Screen on Resume," optimize battery life via Hybrid Graphics (Optimus), and enable hardware video acceleration.

## 1. System Specifications
* **CPU:** Intel Core i7-10xxx (Comet Lake)
* **GPU 1:** Intel UHD Graphics (Primary)
* **GPU 2:** NVIDIA Quadro P520 (Discrete / On-Demand)

* **OS:** Debian 13 (Trixie) / Testing
* **Kernel:** 6.12+

---

## 2. Bootloader Configuration (GRUB)
The most critical fixes are handled at the kernel level. 

**File:** `/etc/default/grub`  
**Action:** Update `GRUB_CMDLINE_LINUX_DEFAULT` to include:

```text
# i915.enable_guc=3 -> Enables HuC/GuC for Intel video acceleration
# nvidia.NVreg_DynamicPowerManagement=0x02 -> Allows NVIDIA to enter D3Cold
# nvidia.NVreg_PreserveVideoMemoryAllocations=1 -> Fixes black screen on wake
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash i915.enable_guc=3 nvidia.NVreg_DynamicPowerManagement=0x02 nvidia.NVreg_PreserveVideoMemoryAllocations=1"
```

Apply changes:

```bash
sudo update-grub
```

## 3. NVIDIA Power Management
To allow the NVIDIA GPU to sleep when not in use (preventing the "Lid Close Crash"):

**File:** `/etc/modprobe.d/nvidia-power-management.conf`  

```text
options nvidia "NVreg_DynamicPowerManagement=0x02"
options nvidia "NVreg_PreserveVideoMemoryAllocations=1"
options nvidia "NVreg_TemporaryFilePath=/var/tmp"
```

**File:** `/etc/udev/rules.d/80-nvidia-pm.rules`  

```text
# Enable runtime PM for NVIDIA VGA/3D controller devices
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", ATTR{power/control}="auto"
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", ATTR{power/control}="auto"
```

**Enable Systemd Services:**

```bash
sudo systemctl enable nvidia-suspend.service nvidia-resume.service nvidia-hibernate.service
```

## 4. GNOME / Desktop Environment
To ensure the laptop wakes up reliably, GNOME must run on the Intel card by default.

**Session Type:** Use Wayland (Select "GNOME" at login, not "GNOME on Xorg").

**File:** `/etc/environment`  

```text
# Force Intel for the primary shell rendering
__NV_PRIME_RENDER_OFFLOAD=0
__EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json
```

## 5. Battery & Thermal Management (TLP)
Install TLP to manage ThinkPad-specific battery thresholds.

```bash
sudo apt install tlp tlp-rdw
sudo tlp start
# Set thresholds to stop charging at 80% to preserve battery health
sudo tlp setcharge 75 80
```

## 6. Verification Commands
Use these to verify the setup is working:

- **Check Sleep Mode:** `cat /sys/power/mem_sleep` (Should show `[s2idle]`)
- **Check GPU State:** `cat /sys/bus/pci/devices/0000:2d:00.0/power_state` (Should show `D3cold` when idle)
- **Check Video Accel:** `sudo dmesg | grep -i huc` (Should show authenticated)
- **Run App on NVIDIA:** `__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia [app_name]`

---
