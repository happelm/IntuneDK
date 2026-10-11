---
title: 'Lab 9.1 – Device actions'
lab:
    title: 'Lab 9.1 – Device actions'
    module: 'Day 3 – Operations, troubleshooting, automation'
---

# Lab 9.1 – Device actions

**Estimated time:** 20 minutes, plus the reset of CL4 in the background

> **New:** This lab has not been run in this environment yet. If a step behaves differently, tell the trainer.

> **Careful:** Your role reaches the lab devices of every participant. Check the device name twice before you click – a wipe cannot be undone.

**Goal:** Know which device action does what, and wipe and re-provision CL4 yourself.

1. Intune admin center → Devices → Windows → `CL4-yourname`: list every action the device page offers (top bar and the … menu). For each one, write down in one line what it does and whether the device stays enrolled. Use the slides and the Learn page [Device actions](https://learn.microsoft.com/en-us/intune/device-management/actions/).
2. Compare your list with your neighbor. Which action is missing because CL4 is not registered in Windows Autopilot?
3. Wait for the trainer's signal, then: `CL4-yourname` → **Wipe**. Leave both options cleared (do not keep enrollment state and user account), confirm.
4. Sync CL4 once so that it picks up the wipe. The reset takes a while – continue with the next lab and come back.
5. When CL4 shows OOBE: set it up again as in [Lab 0.1](LAB_00_1_set-up-your-lab.html) with the name `CL4-yourname` and your user `etcX`.
6. Entra admin center → Devices → All devices: search `CL4-yourname`. How many objects are there now, and which one is the new one (registered date)? Delete the old one.
7. Add the new CL4 to `studentXdevices` again and check that the apps from Day 2 arrive.

### Checkpoint

- [ ] One line per device action, including whether the device stays enrolled
- [ ] CL4 wiped, set up again and enrolled
- [ ] Exactly one `CL4-yourname` in Entra ID, member of `studentXdevices`
- [ ] Day 2 apps arrive on the new CL4

**Note:** The trainer shows **Autopilot Reset** on a device that is registered in Windows Autopilot. Autopilot Reset keeps the Entra and Intune registration – Wipe does not.

**Why:** After a wipe the old device object often stays behind. Stale objects break group membership, filters and reports – removing them is part of the action, not an afterthought.
