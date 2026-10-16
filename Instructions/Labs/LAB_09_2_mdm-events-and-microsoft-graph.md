---
title: 'Lab 9.2 – MDM events and Microsoft Graph'
lab:
    title: 'Lab 9.2 – MDM events and Microsoft Graph'
    module: 'Day 3 – Operations, troubleshooting, automation'
---

# Lab 9.2 – MDM events and Microsoft Graph

**Estimated time:** 30 minutes


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

6. Open Graph Explorer (`https://aka.ms/ge`) and sign in with your user `etcX`. The method (GET, POST, …) is a drop-down left of the URL box: set it there, and paste only the URL from the code blocks below.
7. Method **GET** – list the managed devices you can see:

   ```text
   https://graph.microsoft.com/v1.0/deviceManagement/managedDevices?$select=id,deviceName,lastSyncDateTime,complianceState,osVersion
   ```

8. Find `CL3-yourname` in the result and copy its `id`. Method **GET** – read the device alone (replace `{id}`):

   ```text
   https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/{id}
   ```

9. Method **POST**, request body empty – trigger a sync of CL3, then compare `lastSyncDateTime` with the device page in the Intune admin center a few minutes later:

   ```text
   https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/{id}/syncDevice
   ```

10. More helpdesk questions, all method **GET**. Run each one and check the result against the Intune admin center:

    - Which devices are not compliant?

      ```text
      https://graph.microsoft.com/v1.0/deviceManagement/managedDevices?$filter=complianceState eq 'noncompliant'&$select=deviceName,userPrincipalName,complianceState,lastSyncDateTime
      ```

    - Which devices have not checked in for a week? Replace the date with today minus seven days:

      ```text
      https://graph.microsoft.com/v1.0/deviceManagement/managedDevices?$filter=lastSyncDateTime le 2026-10-09T00:00:00Z&$select=deviceName,userPrincipalName,lastSyncDateTime
      ```

    - Which devices does a user have – the first question when a user calls. Replace `etcX` with the user:

      ```text
      https://graph.microsoft.com/v1.0/deviceManagement/managedDevices?$filter=userPrincipalName eq 'etcX@mslablive.onmicrosoft.com'&$select=deviceName,operatingSystem,osVersion,complianceState,lastSyncDateTime
      ```

    - Which Windows devices are there, with model and serial number:

      ```text
      https://graph.microsoft.com/v1.0/deviceManagement/managedDevices?$filter=operatingSystem eq 'Windows'&$select=deviceName,model,serialNumber,osVersion
      ```

11. **Optional – PowerShell:** the same as a script, for example for a helpdesk report.

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
- [ ] At least two of the helpdesk queries run and checked against the Intune admin center

**Note:** In Graph Explorer, **Code snippets** next to the response shows the PowerShell command for the same request – a quick way from a query to a script.

**Note:** Graph Explorer and Microsoft Graph PowerShell ask for permissions (scopes) when you sign in. In this tenant the trainer has granted them in advance. Your Intune role still decides what you see and which actions you may run.

**Why:** Everything the Intune admin center does is a Graph call. A query you built once in Graph Explorer becomes a script, a report or a helpdesk tool.
