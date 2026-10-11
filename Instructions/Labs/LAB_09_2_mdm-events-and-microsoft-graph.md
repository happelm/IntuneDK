---
title: 'Lab 9.2 – MDM events and Microsoft Graph'
lab:
    title: 'Lab 9.2 – MDM events and Microsoft Graph'
    module: 'Day 3 – Operations, troubleshooting, automation'
---

# Lab 9.2 – MDM events and Microsoft Graph

**Estimated time:** 30 minutes

> **New:** This lab has not been run in this environment yet. If a step behaves differently, tell the trainer.

**Goal:** Find MDM errors on the device without scrolling through thousands of events, and read and sync your devices through Microsoft Graph instead of the portal.

### Part A – MDM events on the device

1. CL3: Event Viewer → Applications and Services Logs → Microsoft → Windows → DeviceManagement-Enterprise-Diagnostics-Provider → **Admin**.
2. Action → **Filter Current Log**: Event level **Error** and **Warning** only. Note the three most recent entries and the policy area they name.
3. Action → **Create Custom View** with the same filter, save it as `MDM errors`. From now on it is one click under Custom Views.
4. Same query in PowerShell – useful in a remote session or in a remediation:

   ```powershell
   Get-WinEvent -LogName 'Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Admin' -MaxEvents 200 | Where-Object { $_.Level -in 2, 3 } | Select-Object TimeCreated, Id, LevelDisplayName, Message | Format-List
   ```

5. Pick one error and find the matching setting in the MDM report from [Lab 2.1](LAB_02_1_collect-and-read-intune-logs.html) or under `HKLM\SOFTWARE\Microsoft\PolicyManager\current\device`.

### Part B – Microsoft Graph

6. Open Graph Explorer (`https://aka.ms/ge`) and sign in with your user `etcX`.
7. List the managed devices you can see:

   ```text
   GET https://graph.microsoft.com/v1.0/deviceManagement/managedDevices?$select=id,deviceName,lastSyncDateTime,complianceState,osVersion
   ```

8. Find `CL3-yourname` in the result and copy its `id`. Read the device alone:

   ```text
   GET https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/{id}
   ```

9. Trigger a sync of CL3 through Graph (request body empty), then compare `lastSyncDateTime` with the device page in the Intune admin center a few minutes later:

   ```text
   POST https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/{id}/syncDevice
   ```

10. **Optional – PowerShell:** the same as a script, for example for a helpdesk report.

    ```powershell
    Install-Module Microsoft.Graph.DeviceManagement -Scope CurrentUser
    Connect-MgGraph -Scopes 'DeviceManagementManagedDevices.Read.All'
    Get-MgDeviceManagementManagedDevice -All | Where-Object DeviceName -like 'CL*-yourname' | Select-Object DeviceName, LastSyncDateTime, ComplianceState
    ```

### Checkpoint

- [ ] Custom view `MDM errors` shows only errors and warnings
- [ ] One MDM error traced to its setting
- [ ] Graph returns `CL3-yourname`
- [ ] Sync triggered through Graph, `lastSyncDateTime` updated

**Note:** Graph Explorer and Microsoft Graph PowerShell ask for permissions (scopes) when you sign in. In this tenant the trainer has granted them in advance. Your Intune role still decides what you see and which actions you may run.

**Why:** Everything the Intune admin center does is a Graph call. A query you built once in Graph Explorer becomes a script, a report or a helpdesk tool.
