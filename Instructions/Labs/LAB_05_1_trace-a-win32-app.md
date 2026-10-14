---
title: 'Lab 5.1 – Trace a Win32 app'
lab:
    title: 'Lab 5.1 – Trace a Win32 app'
    module: 'Day 2 – Policy and application management'
---

# Lab 5.1 – Trace a Win32 app

**Estimated time:** 45 minutes

**Goal:** Follow one Win32 app from the assignment to **Installed** – in the log, the registry and the portal.

1. Download `cmtrace.intunewin` from the [Labfiles](https://github.com/happelm/IntuneDK/tree/main/Labfiles). The package already contains `cmtrace.exe`, `CmtraceInstall.ps1` and `CmtraceRemove.ps1`.
2. Intune admin center → Apps → Windows: add a **Windows app (Win32)** `etcX-CMTrace` from `cmtrace.intunewin` with these settings and assign it as **Required** to `studentXdevices`:

   | Setting | Value |
   |---|---|
   | Install command | `PowerShell.exe -ExecutionPolicy Bypass -File "CmtraceInstall.ps1"` |
   | Uninstall command | `PowerShell.exe -ExecutionPolicy Bypass -File "CmtraceRemove.ps1"` |
   | Install behavior | System |
   | Detection rule | File: `C:\Windows`, file or folder `CMTrace.exe`, file or folder exists |

3. Note the app ID of `etcX-CMTrace`: open the app in the Intune admin center – the ID is the GUID at the end of the browser URL.
4. CL3: open `AppWorkload.log` in CMTrace and highlight the app ID (CMTrace: Tools → Highlight; `Ctrl+F` jumps from hit to hit). Follow the highlighted lines from top to bottom and find the stages from the lifecycle slides in this order:
   1. the app policy with your app ID arrives
   2. detection before the install: the app is not detected
   3. content download, hash check, decryption and unzip into `C:\Windows\IMECache`
   4. the install command from step 2 runs and returns its exit code
   5. detection after the install: the app is detected
   6. the result is reported to Intune
5. **Optional:** if nothing about your app shows up in `AppWorkload.log` after 3–5 minutes, restart the IME in an elevated PowerShell:

   ```powershell
   Restart-Service -Name IntuneManagementExtension
   ```

6. CL3: `regedit` → `HKLM\SOFTWARE\Microsoft\IntuneManagementExtension\Win32Apps` – find the key with your app ID and its state.
7. Intune admin center: compare the install status of `etcX-CMTrace` on CL3 with what the log says.

### Checkpoint

- [ ] Download, install and detection of `etcX-CMTrace` found in `AppWorkload.log`
- [ ] App key and state message found in the registry
- [ ] Portal shows **Installed** for CL3

**Note:** Under `Win32Apps`, apps assigned to the device sit under the all-zeros GUID, apps assigned to a user under that user's Entra object ID.

**Why:** The detection rule decides **Installed** – not the exit code alone. When the portal and the log disagree, the log is right.
