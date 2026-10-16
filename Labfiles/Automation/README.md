# Daily enrollment report with Azure Automation

The runbook `Send-EnrollmentReport.ps1` builds the same page as `Get-EnrollmentDashboard.ps1` every day and mails it as an HTML attachment. It signs in with the managed identity of the Automation account – no secret, no certificate.

| File | Purpose |
|---|---|
| `azuredeploy.json` | ARM template: Automation account with system-assigned managed identity, module `Microsoft.Graph.Authentication`, runbook, daily schedule |
| `Send-EnrollmentReport.ps1` | Runbook (PowerShell 5.1), loaded by the template from this repository |
| `Grant-AutomationPermissions.ps1` | Run once after the deployment: Graph permissions in Entra ID, `Application Mail.Send` in Exchange Online scoped to the sender mailbox |

## Steps

1. Create the sender mailbox, for example a shared mailbox `reports@…` (no license needed).
2. Deploy the template:

   [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fhappelm%2FIntuneDK%2Fmain%2FLabfiles%2FAutomation%2Fazuredeploy.json)

   or with Azure PowerShell:

   ```powershell
   New-AzResourceGroupDeployment -ResourceGroupName rg-intune-reports -TemplateUri https://raw.githubusercontent.com/happelm/IntuneDK/main/Labfiles/Automation/azuredeploy.json -sender reports@contoso.com -recipients 'helpdesk@contoso.com,it@contoso.com'
   ```

3. Copy `managedIdentityObjectId` from the deployment outputs and run the permission script as Global Administrator:

   ```powershell
   .\Grant-AutomationPermissions.ps1 -ManagedIdentityObjectId <objectId> -Sender reports@contoso.com
   ```

4. Wait until the Exchange permission is active (30 minutes up to 2 hours), then test: Automation account → Runbooks → `Send-EnrollmentReport` → **Start** with the same parameters.

## Notes

- `Mail.Send` is not granted in Entra ID on purpose. An Entra grant allows every mailbox and overrides the Exchange scope – RBAC for Applications and Entra permissions add up.
- The module import takes a few minutes after the deployment. A job that starts earlier fails with `Connect-MgGraph` not found.
- The page loads Chart.js from `cdn.jsdelivr.net` when the recipient opens it.
