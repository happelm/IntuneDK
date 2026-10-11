---
title: MDDMI-Doka Lab Instructions
permalink: index.html
---

# MDDMI-Doka – Intune Operations and Troubleshooting

Lab instructions for the three-day Intune operations and troubleshooting workshop, 2nd level focus. Use the copy button on every code block.

## Labs

### Day 1 – Architecture, co-management, provisioning

From ConfigMgr to Intune: Cloud Attach, co-management workloads and what changes for the 2nd level. Microsoft Entra join vs. hybrid join. Windows Autopilot and the Enrollment Status Page (overview and demo). Registration, enrollment and the log files.

| Lab | Title | Time |
|---|---|---|
| 0.1 | [Set up your lab](Instructions/Labs/LAB_00_1_set-up-your-lab.html) | 20 min |
| 2.1 | [Collect and read Intune logs](Instructions/Labs/LAB_02_1_collect-and-read-intune-logs.html) | 30 min |
| 3.1 | [Check the enrollment state](Instructions/Labs/LAB_03_1_check-the-enrollment-state.html) | 25 min |

### Day 2 – Policy and application management

Replacing GPOs with configuration profiles, conflict resolution between Configuration Manager, Group Policy and Intune. Win32 apps: packaging, dependencies, supersedence. App troubleshooting: Intune Management Extension logs, registry and local cache.

| Lab | Title | Time |
|---|---|---|
| 4.1 | [Trace a policy to the registry](Instructions/Labs/LAB_04_1_trace-a-policy-to-the-registry.html) | 30 min |
| 5.1 | [Trace a Win32 app](Instructions/Labs/LAB_05_1_trace-a-win32-app.html) | 45 min |
| 5.2 | [Package an app with a dependency](Instructions/Labs/LAB_05_2_package-an-app-with-a-dependency.html) (draft) | 30 min |
| 5.3 | [Force the reinstall of a required app](Instructions/Labs/LAB_05_3_force-the-reinstall-of-a-required-app.html) (draft) | 25 min |

### Day 3 – Operations, troubleshooting, automation

Device actions: Wipe, Retire, Fresh Start, Autopilot Reset. Diagnostic logs, MDM events and Microsoft Graph. Remediations. Q&A and cases from your own environment.

| Lab | Title | Time |
|---|---|---|
| 6.1 | [Trace a platform script](Instructions/Labs/LAB_06_1_trace-a-platform-script.html) | 30 min |
| 6.2 | [Turn a client problem into a remediation](Instructions/Labs/LAB_06_2_turn-a-client-problem-into-a-remediation.html) (draft) | 20 min |
| 7.1 | [Trace a compliance block](Instructions/Labs/LAB_07_1_trace-a-compliance-block.html) | 30 min |
| 8.1 | [Windows Hello and cloud Kerberos](Instructions/Labs/LAB_08_1_windows-hello-and-cloud-kerberos.html) | 45 min (optional) |
| 9.1 | [Device actions](Instructions/Labs/LAB_09_1_device-actions.html) (draft) | 20 min |
| 9.2 | [MDM events and Microsoft Graph](Instructions/Labs/LAB_09_2_mdm-events-and-microsoft-graph.html) (draft) | 30 min |
| 10.1 | [Partner breaks, you fix](Instructions/Labs/LAB_10_1_partner-breaks-you-fix.html) (draft) | 30 min |

### Appendix

[Log map, collecting logs](Instructions/Appendix.html)

### Resources

[Intune troubleshooting link collection](https://github.com/happelm/Intune-Resources/blob/main/Intune3Links.md) – Learn articles, blogs and tools for this workshop.

## About this guide

This is not a break-and-fix course. You first look at how a healthy device behaves and logs – a deviation then shows you where to look. Each lab lists its goal, the steps at task level (not every click) and a checkpoint you confirm before moving on.

- **Steps** say what to do and where. Menu paths use → between levels.
- **Checkpoint** items are the definition of done. If one fails, tell the trainer before you continue – later labs build on your enrolled CL3 and CL4.
- **Notes** explain what to expect and where it typically goes wrong.

### Your lab environment

One shared training tenant – your objects carry your number, nobody touches another participant's objects. Your clients join Microsoft Entra ID natively and enroll in Intune. Your user `etcX` is a hybrid identity: it is synchronized from the domain `smart.etc` with Microsoft Entra Cloud Sync. Hybrid joined devices and Configuration Manager are shown by the trainer.

| System | Role | Note |
|---|---|---|
| Tenant | Shared training tenant of the trainer | You are user `etcX`; your groups are `studentXdevices` and `studentXusers` |
| CL3, CL4 | Windows 11 – your clients | Start at OOBE; renamed to `CL3-yourname` / `CL4-yourname`, Entra joined and enrolled by you in Lab 0.1 |
| DC1 | AD DS, DNS – domain `smart.etc` (trainer's pod) | Source of your user via Cloud Sync; on-premises resources for Microsoft Entra Kerberos (Lab 8.1) |
| SCCM | Configuration Manager site (trainer's pod) | Demonstration only: Cloud Attach, co-management workloads, client logs |
| SRV1 | Member server in `smart.etc` (trainer's pod) | On-premises resources for the SSO tests |
| Classroom LAN | DHCP (trainer's pod) | Connects your clients to `smart.etc` |

X is your participant number from `course.txt`. Passwords are handed out by the trainer.

### Naming

Every policy, profile, app and script you create starts with `etcX-` (for example `etc3-CMTrace`), so every object is unique and you find your own.

### Your permissions

All roles are assigned to your group `studentXusers`, never to you directly.

| Where | Role | You can |
|---|---|---|
| Entra ID | User Administrator, Authentication Administrator – admin unit *Lab-Student Group Administrators* | Manage the student device groups, e.g. add CL3 and CL4 to `studentXdevices` |
| Entra ID | Cloud Device Administrator – admin unit *Lab-Student Device Administrators* | Enable, disable and delete lab devices |
| Intune | Lab-Reader for Students | See everything, change nothing |
| Intune | Lab-Administrator for Students | Create, change, assign and delete objects tagged *Lab-Students*, assign to the student groups only |

Not for you: roles, scope tags, tenant settings, Conditional Access. Assignment filters are read only. Your roles reach the lab groups and lab devices of every participant – touch only your own.

### Tools

- CMTrace for all .log files – from `\\dc1\labfiles` in Lab 2.1, deployed by Intune in Lab 5.1. Intune Management Extension logs in `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs`
- Intune admin center: intune.microsoft.com · Entra admin center: entra.microsoft.com
- Lab files: [Labfiles folder in this repository](https://github.com/happelm/MDDMI-Doka/tree/main/Labfiles)
