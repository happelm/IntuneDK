---
title: 'Lab 3.1 – Check the enrollment state'
lab:
    title: 'Lab 3.1 – Check the enrollment state'
    module: 'Day 1 – Architecture, co-management, provisioning'
---

# Lab 3.1 – Check the enrollment state

**Estimated time:** 25 minutes

**Goal:** Prove from the device side that CL3 is joined and enrolled – and know where each fact is stored.

1. CL3: run `dsregcmd /status` and check `AzureAdJoined` and `AzureAdPrt`.
2. CL3: Settings → Accounts → Access work or school → your account → **Info**. Note the management server and the last sync.
3. CL3, elevated: open `regedit` and go to `HKLM\SOFTWARE\Microsoft\Enrollments`. Find the GUID key of the Intune enrollment – its `ProviderID` is `MS DM Server`.
4. CL3, elevated: Task Scheduler → Microsoft → Windows → EnterpriseMgmt – find the same GUID.

### Checkpoint

- [ ] `AzureAdJoined : YES` and `AzureAdPrt : YES`
- [ ] Same GUID in the registry and in Task Scheduler

**Note:** Task Scheduler shows the EnterpriseMgmt tasks only to administrators. The GUID is different on every client. `HKLM\SOFTWARE\Microsoft\Enrollments` can hold more than one GUID – only one of them is the Intune enrollment.

**Why:** The enrollment GUID is the key for everything that follows: Intune policies are stored per provider GUID (Lab 4.1).

**Reference:** [Diagnose MDM enrollment](https://learn.microsoft.com/en-us/windows/client-management/mdm-diagnose-enrollment) on Microsoft Learn – the Group Policy part does not apply to your Entra-joined clients.
