---
title: 'Lab 9.3 – Build a software report with Graph'
lab:
    title: 'Lab 9.3 – Build a software report with Graph'
    module: 'Day 3 – Operations, troubleshooting, automation'
---

# Lab 9.3 – Build a software report with Graph

**Estimated time:** 30 minutes

> **Draft:** This lab is new and has not been run in this environment yet. If a step behaves differently, tell the trainer.

**Goal:** Answer a typical helpdesk question with data from Intune: which versions of an app are installed, on how many devices, on which ones – as a CSV file for Excel.

**Why:** The Intune admin center shows the answer one app at a time (Apps → Monitor → Discovered apps). Graph gives you the same data for any app, filtered, combined and exported – the basis for every recurring report.

### Part A – Explore in Graph Explorer

1. Graph Explorer (`https://aka.ms/ge`), signed in as `etcX` as in [Lab 9.2](LAB_09_2_mdm-events-and-microsoft-graph.html). Method **GET** – list the discovered apps:

   ```text
   https://graph.microsoft.com/v1.0/deviceManagement/detectedApps?$select=id,displayName,version,publisher,deviceCount
   ```

2. Scroll to the top and the end of the response: `@odata.count` is the total, but the list stops after the first 1000 apps (sorted by name) and ends with `@odata.nextLink`. Graph returns large results in pages – the next page is the `nextLink` URL. Instead of paging, let Graph filter. Method **GET**:

   ```text
   https://graph.microsoft.com/v1.0/deviceManagement/detectedApps?$filter=contains(displayName,'Visual C')&$select=id,displayName,version,publisher,deviceCount
   ```

   Every version is a separate entry with its own `deviceCount`. Run the same query for `Greenshot` from Lab 5.2.
3. Copy the `id` of the Greenshot entry and method **GET** – list the devices that have it (replace `{id}`):

   ```text
   https://graph.microsoft.com/v1.0/deviceManagement/detectedApps/{id}/managedDevices?$select=deviceName,lastSyncDateTime
   ```

4. Intune admin center → Apps → Monitor → **Discovered apps**: compare the device count for Greenshot with Graph.

### Part B – Report with PowerShell

5. CL3: download `Get-SoftwareReport.ps1` from the [Labfiles](https://github.com/happelm/IntuneDK/tree/main/Labfiles) and read it: which two Graph calls does it make, and which one runs once per app version?
6. Run it in PowerShell (not elevated) from the download folder. Confirm the prompts for the NuGet provider and the PowerShell Gallery with `Y`, sign in with `etcX` when asked.

   ```powershell
   PowerShell.exe -ExecutionPolicy Bypass -File .\Get-SoftwareReport.ps1 -Name 'Visual C' -OutFile 'C:\Temp\etcX-VCRedist.csv'
   ```

7. Open the CSV in Excel. Insert → PivotTable: rows `Version`, values count of `Device`. How many devices have which version?
8. Run the script once more for an app that matters in your own environment, for example a browser or a PDF reader.

### Checkpoint

- [ ] Graph Explorer shows the discovered apps and the devices for one app
- [ ] Device count in Graph and in the Intune admin center match
- [ ] CSV report created and pivoted by version in Excel

**Note:** Discovered apps is inventory, not a live view: an app installed a few minutes ago can be missing. Discovered apps lists what is installed on the device, wherever it came from – the install status of an app you deploy is in the app itself (Apps → your app → Device install status).

**Note:** Scripts never page by hand: `-All` in Microsoft Graph PowerShell follows every `nextLink`.

**Note:** Your Intune role decides which devices you see – in this tenant you can read all lab devices, so the report covers every participant.
