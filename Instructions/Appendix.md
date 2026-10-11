---
title: 'Appendix'
lab:
    title: 'Appendix'
    module: 'Appendix'
---

# Appendix

## Log map

One place to look per layer.

| Layer | Question | Where to look |
|---|---|---|
| Identity | Joined the way you think? PRT? | `dsregcmd /status` · Event Viewer → Applications and Services Logs → Microsoft → Windows → User Device Registration → Admin |
| Enrollment | Enrolled – once, with which MDM? | Settings → Accounts → Access work or school → Info · `HKLM\SOFTWARE\Microsoft\Enrollments` |
| Delivery | Did the MDM channel process it? | Event Viewer → Applications and Services Logs → Microsoft → Windows → DeviceManagement-Enterprise-Diagnostics-Provider → Admin |
| Execution – policies | Which value is applied? | `MDMDiagHtmlReport.html` · `HKLM\SOFTWARE\Microsoft\PolicyManager\current\device` |
| Execution – apps, scripts | Did the IME run it? | `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs` – `IntuneManagementExtension.log`, `AppWorkload.log`, `AgentExecutor.log`, `HealthScripts.log` |
| On the wire | What did the device send and receive? | SyncML Viewer (community tool) |

The IME is only installed once a script, Win32 app, remediation or custom compliance policy targets the device or user.

## Collecting logs from Windows

| Who | How | Result |
|---|---|---|
| User | Settings → Accounts → Access work or school → Export your management log files | `C:\Users\Public\Documents\MDMDiagnostics` |
| Admin | Intune admin center → Devices → All devices → device → Collect diagnostics | Package after about 15 minutes and a sync, kept 28 days |
| Command line | `mdmdiagnosticstool.exe -area "DeviceEnrollment;DeviceProvisioning;Autopilot" -zip "C:\Users\Public\Documents\MDMDiagReport.zip"` | Zip with MDM report, registry dump and event log |

## Intune Management Extension logs

| Log | Use it for |
|---|---|
| `IntuneManagementExtension.log` | Main log: check-ins, policy requests, processing, reporting |
| `AppWorkload.log` | Win32 app deployment |
| `AppActionProcessor.log` | Detection and applicability checks for assigned apps |
| `AgentExecutor.log` | PowerShell script execution |
| `HealthScripts.log` | Remediations |
| `ClientHealth.log` | Health of the IME itself |
