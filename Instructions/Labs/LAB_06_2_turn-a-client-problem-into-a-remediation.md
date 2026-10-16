---
title: 'Lab 6.2 – Turn a client problem into a remediation'
lab:
    title: 'Lab 6.2 – Turn a client problem into a remediation'
    module: 'Day 3 – Operations, troubleshooting, automation'
---

# Lab 6.2 – Turn a client problem into a remediation

**Estimated time:** 20 minutes


**Goal:** Detect and fix a client setting automatically – on a schedule and on demand – and read the result in the portal.

**Why:** A configuration baseline in Configuration Manager with a script setting and remediation has no settings catalog equivalent. The Intune counterpart is a remediation: discovery script and compliance rule become the detection script, the remediation script stays, the evaluation schedule becomes the schedule of the assignment.

1. CL4, elevated PowerShell: create something to fix.

   ```powershell
   Set-Service -Name RemoteRegistry -StartupType Manual
   ```

2. Download `Detect-RemoteRegistry.ps1` and `Remediate-RemoteRegistry.ps1` from the [Labfiles](https://github.com/happelm/IntuneDK/tree/main/Labfiles) and read both: which exit code means compliant, which one starts the remediation?
3. Intune admin center → Devices → Scripts and remediations → Remediations → **Create script package**: `etcX-RemoteRegistry` with both scripts.

   | Setting | Value |
   |---|---|
   | Run this script using the logged-on credentials | No |
   | Enforce script signature check | No |
   | Run script in 64-bit PowerShell | Yes |

4. Assign it to `studentXdevices`, schedule **Hourly**.
5. Do not wait for the schedule: Intune admin center → Devices → All devices → `CL4-yourname` → … → **Run remediation** → `etcX-RemoteRegistry`.
6. CL4: check the service and follow `HealthScripts.log` in `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs`.

   ```powershell
   Get-Service RemoteRegistry | Select-Object Name, StartType, Status
   ```

7. Intune admin center → Remediations → `etcX-RemoteRegistry` → Device status: add the columns for the detection output before and after the remediation.

### Checkpoint

- [ ] CL4: `RemoteRegistry` start type is `Disabled` again
- [ ] Device status shows **Issue fixed** with the output of both detection runs
- [ ] You can name what replaces the compliance rule and the evaluation schedule of a ConfigMgr baseline

**Note:** Everything a detection script writes with `Write-Output` shows up in the device status columns. Write a short, readable state – it is what the helpdesk sees first.
