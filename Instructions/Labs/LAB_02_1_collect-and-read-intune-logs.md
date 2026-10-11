---
title: 'Lab 2.1 – Collect and read Intune logs'
lab:
    title: 'Lab 2.1 – Collect and read Intune logs'
    module: 'Day 1 – Architecture, co-management, provisioning'
---

# Lab 2.1 – Collect and read Intune logs

**Estimated time:** 30 minutes

**Goal:** Build a known-good baseline of your own CL3 – the reference for every later module.

1. Intune admin center → Devices → All devices → `CL3-yourname` → **Collect diagnostics**. Then sync CL3. The package arrives in about 15 minutes – continue with the next steps meanwhile.
2. CL3: Settings → Accounts → Access work or school → **Export your management log files**. Open the report from `C:\Users\Public\Documents\MDMDiagnostics`.
3. CL4, elevated command prompt: create the diagnostics package from the command line and compare it with the report from step 2.

   ```cmd
   mdmdiagnosticstool.exe -area "DeviceEnrollment;DeviceProvisioning;Autopilot" -zip "C:\Users\Public\Documents\MDMDiagReport.zip"
   ```

4. CL3: connect the lab share and copy `cmtrace.exe` to the desktop. Entra-joined clients have no mapped network drives – connect the share first.

   ```cmd
   net use \\dc1\labfiles
   ```

   Then open `IntuneManagementExtension.log` from `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs` with CMTrace.
5. Intune admin center → Devices → All devices → `CL3-yourname` → Monitor → Device diagnostics: download the package from step 1 and find the same information in it.

### Checkpoint

- [ ] MDM report shows your enrollment and the managed policies
- [ ] Diagnostics package downloaded and opened
- [ ] You can name the log for each of the five layers (see the [log map](../Appendix.html#log-map))

**Note:** The zip from `mdmdiagnosticstool.exe` contains `MDMDiagHtmlReport.html`, `MDMDiagReport.xml`, a registry dump and the DeviceManagement-Enterprise-Diagnostics-Provider Admin event log. The list of available areas is in `HKLM\SOFTWARE\Microsoft\MdmDiagnostics\Area`.

**Why:** This course does not break devices on purpose. You learn what a healthy CL3 logs, so that a deviation stands out later. Keep this baseline – Module 3 compares against it.
