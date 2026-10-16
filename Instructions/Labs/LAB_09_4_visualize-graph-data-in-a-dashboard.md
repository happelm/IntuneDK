---
title: 'Lab 9.4 – Visualize Graph data in a dashboard'
lab:
    title: 'Lab 9.4 – Visualize Graph data in a dashboard'
    module: 'Day 3 – Operations, troubleshooting, automation'
---

# Lab 9.4 – Visualize Graph data in a dashboard

**Estimated time:** 15 minutes (optional)

**Goal:** Turn the Graph queries from Lab 9.2 and 9.3 into charts – compliance, operating systems, check-in age, Windows versions and the versions of one app – on a single HTML page.

**Why:** Graph Explorer shows JSON, not charts. A short script runs the same queries, counts the results and hands them to a chart library in the browser. No server, no Power BI, no extra module – one HTML file you can mail or open again later.

1. CL3: download `Get-IntuneDashboard.ps1` from the [Labfiles](https://github.com/happelm/IntuneDK/tree/main/Labfiles) and read it:
   - Which Graph call delivers the device data, and which properties does it ask for?
   - Where are the devices counted per chart?
   - How does the data get into the HTML page?
2. Run it in PowerShell (not elevated) from the download folder, sign in with `etcX` when asked:

   ```powershell
   PowerShell.exe -ExecutionPolicy Bypass -File .\Get-IntuneDashboard.ps1 -App 'Visual C' -OutFile 'C:\Temp\etcX-Dashboard.html'
   ```

3. The dashboard opens in the browser. Hover over the bars and the doughnut: the tooltips show the exact numbers.
4. Compare with the Intune admin center: Reports → **Device compliance** and Devices → **All devices**. Do the numbers match?
5. Run the script again with an app from your own environment, for example `-App 'Chrome'` or `-App 'Acrobat'`.

### Checkpoint

- [ ] Dashboard opens with tiles, four charts and the list of non-compliant devices
- [ ] Numbers match the Intune admin center
- [ ] You can name the Graph call behind each chart

**Note:** The page loads the chart library Chart.js from `cdn.jsdelivr.net`. Without internet access the tiles and the table still show, the charts stay empty.

**Note:** Your Intune role decides which devices you see. In this tenant you see the lab devices of every participant – the dashboard of the trainer and yours may still differ.
