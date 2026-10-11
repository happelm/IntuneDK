---
title: 'Lab 6.1 – Trace a platform script'
lab:
    title: 'Lab 6.1 – Trace a platform script'
    module: 'Day 3 – Operations, troubleshooting, automation'
---

# Lab 6.1 – Trace a platform script

**Estimated time:** 30 minutes

> **New:** The remediation part of this lab has not been run in a class yet. If a step behaves differently, tell the trainer.

**Goal:** Follow a platform script and a remediation from the assignment to the result on CL3.

1. Intune admin center → Devices → Scripts and remediations → Platform scripts → Add → Windows 10 and later: platform script `etcX-Folder` with `createtestfolder.ps1` from the [Labfiles](https://github.com/happelm/MDDMI-Doka/tree/main/Labfiles), assigned to `studentXdevices`:

   | Setting | Value |
   |---|---|
   | Run this script using the logged on credentials | No (runs as System) |
   | Enforce script signature check | No |
   | Run script in 64-bit PowerShell host | No |

2. In `Detect-LabKey.ps1` and `Remediate-LabKey.ps1` from the Labfiles, replace `etcX` with your prefix.
3. Intune admin center → Devices → Scripts and remediations → Remediations → **Create script package**: `etcX-Reg` with both scripts, assigned to `studentXdevices`, schedule **Hourly**:

   | Setting | Value |
   |---|---|
   | Run this script using the logged-on credentials | No |
   | Enforce script signature check | No |
   | Run script in 64-bit PowerShell | Yes |

4. CL3, elevated PowerShell: restart the IME.

   ```powershell
   Restart-Service -Name IntuneManagementExtension
   ```

5. Follow `etcX-Folder` in `IntuneManagementExtension.log` and `AgentExecutor.log`.
6. Follow `etcX-Reg` in `HealthScripts.log`: detection, remediation, detection again.
7. Intune admin center: compare the device status of both scripts for CL3.

### Checkpoint

- [ ] `C:\TestFolder` exists on CL3
- [ ] Exit code of `etcX-Folder` found in `AgentExecutor.log`
- [ ] `etcX-Reg`: issue found, then fixed – `HKLM\SOFTWARE\etcX\Lab` exists on CL3

**Note:** Detection exits with `1` when the key is missing – only exit code `1` starts the remediation. A platform script that fails is retried three times at the next three IME check-ins, then it stays failed until the script or the policy changes.

**Why 64-bit:** A 32-bit PowerShell host writes `HKLM\SOFTWARE` to `HKLM\SOFTWARE\WOW6432Node`. The remediation would then fix a different key than the one you check.
