<#
  After the deployment of azuredeploy.json:
  1. Entra ID: Graph application permissions for the managed identity of the Automation account
       DeviceManagementManagedDevices.Read.All, Device.Read.All
  2. Exchange Online: RBAC for Applications - "Application Mail.Send" for the sender mailbox only
       (Mail.Send is deliberately NOT granted in Entra ID - an Entra grant would allow every mailbox)

  Run as Global Administrator, or Privileged Role Administrator plus Exchange Administrator.
  Changes in Exchange take 30 minutes up to 2 hours until the runbook can send.

  Example:
    .\Grant-AutomationPermissions.ps1 -ManagedIdentityObjectId <objectId from the deployment output> -Sender reports@contoso.com
#>
param(
    [Parameter(Mandatory)] [string] $ManagedIdentityObjectId,
    [Parameter(Mandatory)] [string] $Sender,
    [string[]] $GraphPermissions = @('DeviceManagementManagedDevices.Read.All', 'Device.Read.All')
)

foreach ($m in 'Microsoft.Graph.Applications', 'ExchangeOnlineManagement') {
    if (-not (Get-Module -ListAvailable -Name $m)) { Install-Module $m -Scope CurrentUser -Force }
}

# 1. Entra ID - app role assignments on the Microsoft Graph service principal
Connect-MgGraph -Scopes 'Application.Read.All', 'AppRoleAssignment.ReadWrite.All' -NoWelcome

$mi    = Get-MgServicePrincipal -ServicePrincipalId $ManagedIdentityObjectId
$graph = Get-MgServicePrincipal -Filter "appId eq '00000003-0000-0000-c000-000000000000'"
$have  = (Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $mi.Id -All).AppRoleId

foreach ($p in $GraphPermissions) {
    $role = $graph.AppRoles | Where-Object { $_.Value -eq $p -and $_.AllowedMemberTypes -contains 'Application' }
    if (-not $role)              { Write-Warning "Unknown Graph permission: $p"; continue }
    if ($have -contains $role.Id) { Write-Output "Graph: $p already granted"; continue }
    New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $mi.Id -PrincipalId $mi.Id -ResourceId $graph.Id -AppRoleId $role.Id | Out-Null
    Write-Output "Graph: $p granted"
}

# 2. Exchange Online - RBAC for Applications, scoped to the sender mailbox
Connect-ExchangeOnline -ShowBanner:$false

$scopeName = "Scope-$($mi.DisplayName)-Sender"

if (-not (Get-ServicePrincipal -Identity $mi.AppId -ErrorAction SilentlyContinue)) {
    New-ServicePrincipal -AppId $mi.AppId -ObjectId $mi.Id -DisplayName $mi.DisplayName | Out-Null
    Write-Output "Exchange: service principal $($mi.DisplayName) created"
}
if (-not (Get-ManagementScope -Identity $scopeName -ErrorAction SilentlyContinue)) {
    New-ManagementScope -Name $scopeName -RecipientRestrictionFilter "PrimarySmtpAddress -eq '$Sender'" | Out-Null
    Write-Output "Exchange: management scope $scopeName created"
}
$assigned = Get-ManagementRoleAssignment -Role 'Application Mail.Send' -ErrorAction SilentlyContinue |
    Where-Object { $_.App -eq $mi.AppId -or $_.RoleAssigneeName -eq $mi.DisplayName -or $_.RoleAssignee -eq $mi.DisplayName }
if (-not $assigned) {
    New-ManagementRoleAssignment -App $mi.AppId -Role 'Application Mail.Send' -CustomResourceScope $scopeName | Out-Null
    Write-Output "Exchange: Application Mail.Send assigned for $Sender"
}

# Check: InScope must be True for the sender (the test bypasses the permission cache)
Test-ServicePrincipalAuthorization -Identity $mi.AppId -Resource $Sender | Format-Table RoleName, InScope -AutoSize

Disconnect-ExchangeOnline -Confirm:$false
