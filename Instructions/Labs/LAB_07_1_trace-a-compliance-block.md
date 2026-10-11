---
title: 'Lab 7.1 – Trace a compliance block'
lab:
    title: 'Lab 7.1 – Trace a compliance block'
    module: 'Day 3 – Operations, troubleshooting, automation'
---

# Lab 7.1 – Trace a compliance block

**Estimated time:** 30 minutes

**Goal:** Make CL3 noncompliant on purpose and see what the user sees – then repair it. The trainer shows the same block in the sign-in log.

1. CL3: run `ver` and note the OS version.
2. Intune admin center → Devices → Manage devices → Compliance → Create policy → Windows 10 and later: compliance policy `etcX-MinOS`, Device properties → Operating system version → **Minimum OS version** `10.0.99999.0`, assigned to `studentXusers`.
3. CL3: Company Portal → **Check access**. Wait until the device is noncompliant.
4. Intune admin center → Devices → All devices → `CL3-yourname` → Device compliance: find `etcX-MinOS` and the failing setting.
5. CL3: sign in to Microsoft Edge with `etcX` and open `office.com`. The trainer's Conditional Access policy blocks the noncompliant device.
6. Trainer demo: the sign-in log of your attempt – Conditional Access tab, Device info, What If.
7. Clean up: set the minimum OS version in `etcX-MinOS` to the version from step 1 or lower, run **Check access** again – `office.com` opens.

### Checkpoint

- [ ] CL3 noncompliant with the reason minimum OS version
- [ ] `office.com` blocked on CL3 with a compliance message
- [ ] CL3 compliant again, `office.com` opens

**Note:** The minimum OS version uses the format `major.minor.build.revision`, the same value that `ver` shows.

**Why:** Intune evaluates compliance, Microsoft Entra ID enforces the block. You do not have a role for Conditional Access – the sign-in log is part of the trainer demo.
