---
title: 'Lab 4.1 – Trace a policy to the registry'
lab:
    title: 'Lab 4.1 – Trace a policy to the registry'
    module: 'Day 2 – Policy and application management'
---

# Lab 4.1 – Trace a policy to the registry

**Estimated time:** 30 minutes

**Goal:** Follow one user setting and one device setting from the portal through the SyncML stream into the registry.

1. CL3: install SyncML Viewer, start it and leave it running.

   ```cmd
   winget install syncmlviewer
   ```

2. Intune admin center → Devices → Manage devices → Configuration → Create → New policy → Windows 10 and later → Settings catalog. Create two policies:

   | Policy | Setting | Value | Assign to |
   |---|---|---|---|
   | `etcX-User` | Administrative Templates → Control Panel → Personalization → **Prevent changing theme (User)** | Enabled | `studentXusers` |
   | `etcX-Device` | Start → **Hide Recently Added Apps (Device)** | Hide | `studentXdevices` |
   | `etcX-Device` | Config Refresh | Enabled, cadence 30 minutes | (same policy) |

3. CL3: sync (Settings → Accounts → Access work or school → your account → Info → Sync).
4. SyncML Viewer: press `F3` to search the stream – the search is not in the menu. Search for `DisableThemeChange` and `HideRecentlyAddedApps` and look at the `LocURI` of each: `./User/…` or `./Device/…`.
5. CL3, elevated: `regedit` → `HKLM\SOFTWARE\Microsoft\PolicyManager\current` – find both values.
6. Intune admin center: open both policies and check the per-setting status for CL3.

### Checkpoint

- [ ] Both settings found in SyncML Viewer
- [ ] `HideRecentlyAddedApps` = `1` under `HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start`
- [ ] Both policies **Succeeded** on CL3

**Note:** Config Refresh is a setting of the MDM client itself (DMClient CSP), not a Policy CSP setting – you will not find it under `PolicyManager`. `Hide Recently Added Apps` only changes the Start menu after a restart; the registry value is there right after the sync.

**Why:** The sync status in the portal is a service view. The registry shows what the device actually applied. `PolicyManager\providers\<GUID>\default\Device\<area>` holds the values Intune sent – the GUID is one of your two enrollment GUIDs from Lab 3.1. `PolicyManager\current\device` holds the merged result that Windows applies.
