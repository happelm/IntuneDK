---
title: 'Lab 5.3 – Force the reinstall of a required app'
lab:
    title: 'Lab 5.3 – Force the reinstall of a required app'
    module: 'Day 2 – Policy and application management'
---

# Lab 5.3 – Force the reinstall of a required app

**Estimated time:** 25 minutes

**Goal:** Give the helpdesk a way to reinstall a required Win32 app on one device – with a remediation that runs on demand.

**Why:** Intune has no repair action for Win32 apps. For a required app, Reinstall in the Company Portal does nothing while detection is positive, and Uninstall is not passed to the device. The lever that remains is the detection rule: remove what detection looks for, and the IME installs the app again.

1. CL3: note the date of `C:\Windows\CMTrace.exe` – the detection file of `etcX-CMTrace` from Lab 5.1.
2. Download `Detect-ReinstallCMTrace.ps1` and `Remediate-ReinstallCMTrace.ps1` from the [Labfiles](https://github.com/happelm/IntuneDK/tree/main/Labfiles).
3. Intune admin center → Devices → Scripts and remediations → Remediations → **Create script package**: `etcX-Reinstall-CMTrace` with both scripts.

   | Setting | Value |
   |---|---|
   | Run this script using the logged-on credentials | No |
   | Enforce script signature check | No |
   | Run script in 64-bit PowerShell | Yes |

4. On the Assignments page select **no group**. The remediation runs on demand only.
5. Intune admin center → Devices → All devices → `CL3-yourname` → … → **Run remediation** → `etcX-Reinstall-CMTrace`.
6. CL3: follow `HealthScripts.log` in `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs`: the detection script exits with `1`, the remediation runs, `CMTrace.exe` is gone.
7. About three minutes later the IME restarts. Follow `AppWorkload.log`: `etcX-CMTrace` is not detected, the install command runs, detection succeeds.
8. Check the date of `C:\Windows\CMTrace.exe` again and the install status in the Intune admin center.

### Checkpoint

- [ ] `HealthScripts.log`: detection with issue, remediation ran
- [ ] `AppWorkload.log`: `etcX-CMTrace` reinstalled
- [ ] `CMTrace.exe` is newer than in step 1
- [ ] You can explain why the remediation must not be assigned to a group

**Note:** The remediation deletes the GRS keys under `HKLM\SOFTWARE\Microsoft\IntuneManagementExtension\Win32Apps`. They hold the re-evaluation schedule of the Win32 apps; with the keys gone, the IME runs detection at its next check-in instead of waiting for the schedule. The line clears the schedule for all apps on the device: apps with a positive detection are left alone, failed apps are retried earlier. Deleting `LastFullReportTimeUtc` under `...\Win32Apps\Reporting` makes the next status report a full one – without it the reinstall happens, but the Intune admin center shows it much later.

**Why the delay:** The remediation itself runs inside the IME. Restarting the service at once would stop the script before its result is reported, so a separate process waits three minutes, then restarts the IME.

**Why no assignment:** Assigned to a group, the remediation would delete the detection file at every schedule run and reinstall the app again and again.
