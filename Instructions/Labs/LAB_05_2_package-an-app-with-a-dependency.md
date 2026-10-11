---
title: 'Lab 5.2 – Package an app with a dependency'
lab:
    title: 'Lab 5.2 – Package an app with a dependency'
    module: 'Day 2 – Policy and application management'
---

# Lab 5.2 – Package an app with a dependency

**Estimated time:** 30 minutes

> **Draft:** This lab is new and has not been run in this environment yet. If a step behaves differently, tell the trainer.

**Goal:** Package Greenshot and its runtime yourself, deploy both as Win32 apps with a dependency and follow the order in the log.

1. Download `IntuneWinAppUtil.exe` (GitHub: microsoft/Microsoft-Win32-Content-Prep-Tool) to CL3.
2. Copy the folders `Greenshot` and `VCRedist` from `\\dc1\labfiles` to `C:\Software` on CL3.
3. Package both folders. Run the two commands in a command prompt in the folder of `IntuneWinAppUtil.exe`:

   ```cmd
   IntuneWinAppUtil.exe -c C:\Software\Greenshot -s greenshot-installer.exe -o C:\Software\Intune\Greenshot -q
   IntuneWinAppUtil.exe -c C:\Software\VCRedist -s vc_redist.x64.exe -o C:\Software\Intune\VCRedist -q
   ```

4. Intune admin center → Apps → Windows → Add → Windows app (Win32): create `etcX-Greenshot` first. Do not assign it yet.

   | Setting | Value |
   |---|---|
   | Install command | `greenshot-installer.exe /VERYSILENT /NORESTART /SUPPRESSMSGBOXES /ALLUSERS` |
   | Uninstall command | `"%ProgramFiles%\Greenshot\unins000.exe" /VERYSILENT /NORESTART` |
   | Install behavior | System |
   | Detection rule | File: `%ProgramFiles%\Greenshot`, file `Greenshot.exe`, file or folder exists, associated with a 32-bit app on 64-bit clients = No |

5. Create `etcX-VCRedist` as the second Win32 app. Do not assign it.

   | Setting | Value |
   |---|---|
   | Install command | `vc_redist.x64.exe /install /quiet /norestart` |
   | Uninstall command | `vc_redist.x64.exe /uninstall /quiet /norestart` |
   | Install behavior | System |
   | Detection rule | Registry: key path `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64`, value name `Installed`, integer comparison, equals `1`, associated with a 32-bit app on 64-bit clients = No |

6. Connect the two: `etcX-Greenshot` → Properties → Dependencies → add `etcX-VCRedist` with **Automatically install** = Yes.
7. Only now assign `etcX-Greenshot` as **Required** to `studentXdevices`. `etcX-VCRedist` gets no assignment of its own – it arrives through the dependency.
8. Sync CL4 and follow `AppWorkload.log` in `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs`: the dependency is detected and installed first, then Greenshot.

### Checkpoint

- [ ] Both `.intunewin` files created in `C:\Software\Intune`
- [ ] `AppWorkload.log` on CL4 shows `etcX-VCRedist` before `etcX-Greenshot`
- [ ] Both apps report **Installed** for CL4 in the Intune admin center

**Note:** Intune wants the registry key path in one piece. Configuration Manager stores the hive and the key separately (Local Machine + `SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64`) – when you rebuild a ConfigMgr app, join them.

**Why:** A dependency is installed even if it is not assigned – but only together with the app that needs it. Assign the dependency directly and it becomes an app of its own, with its own reporting.

**Optional – supersedence:** Package a newer version of an app you already deployed, then in the new app → Properties → Supersedence add the old app. Decide whether the old version is uninstalled first, and check what `AppWorkload.log` does on a device that has the old version.
