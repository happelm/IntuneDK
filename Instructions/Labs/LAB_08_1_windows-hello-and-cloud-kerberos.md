---
title: 'Lab 8.1 – Windows Hello and cloud Kerberos'
lab:
    title: 'Lab 8.1 – Windows Hello and cloud Kerberos'
    module: 'Day 3 – Operations, troubleshooting, automation'
---

# Lab 8.1 – Windows Hello and cloud Kerberos

**Estimated time:** 45 minutes

**Goal:** Sign in with Windows Hello and reach on-premises resources – and optionally Azure Files – without a password prompt.

1. CL4: sign out and sign in again with the Windows Hello PIN you set up in Lab 0.1.
2. CL4: check the SSO state.

   ```cmd
   dsregcmd /status
   ```

3. CL4: open the Labfiles share on DC1 in `smart.etc`: `\\dc1.smart.etc\labfiles`.
4. CL4: list your Kerberos tickets.

   ```cmd
   klist
   ```

5. **Optional:** if the trainer provides an Azure file share, connect to it from CL4.

### Checkpoint

- [ ] `dsregcmd /status`, section SSO State: `AzureAdPrt`, `CloudTgt` and `OnPremTgt` are `YES`
- [ ] DC1 share opens without a password prompt, `klist` shows a ticket for DC1
- [ ] Optional: Azure file share opens without a password prompt

**Note:** Microsoft Entra Kerberos and Windows Hello for Business are already enabled in the training tenant. `CloudTgt` is the cloud Kerberos ticket for cloud resources, `OnPremTgt` the one for on-premises resources.

**Why:** No PRT, no SSO. Always start with `dsregcmd /status` before you look at the network or the file server.
