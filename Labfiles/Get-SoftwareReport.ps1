<#
  Lab 9.3 - software report from Intune discovered apps (Microsoft Graph)
  Lists every version of an app that Intune has discovered, how many devices have it,
  and which devices - and writes everything to a CSV file for Excel.

  Example:
    .\Get-SoftwareReport.ps1 -Name 'Greenshot' -OutFile 'C:\Temp\etcX-Greenshot.csv'
#>
param(
    [Parameter(Mandatory)] [string] $Name,
    [string] $OutFile = "C:\Temp\SoftwareReport-$($Name -replace '[^\w-]', '_').csv"
)

if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.DeviceManagement)) {
    Install-Module Microsoft.Graph.DeviceManagement -Scope CurrentUser -Force
}
Connect-MgGraph -Scopes 'DeviceManagementManagedDevices.Read.All' -NoWelcome

# 1. All discovered apps whose name contains $Name - one entry per name and version
#    Graph filters on the server, -All follows the paging (nextLink)
$filter = "contains(displayName,'$($Name -replace "'", "''")')"
$apps = Get-MgDeviceManagementDetectedApp -Filter $filter -All
if (-not $apps) { Write-Warning "No discovered app matches '$Name'."; return }

# 2. Summary: versions and device count
$apps | Sort-Object DisplayName, Version |
    Format-Table DisplayName, Version, Publisher, DeviceCount -AutoSize

# 3. Detail: one row per device and version
$rows = foreach ($app in $apps) {
    Get-MgDeviceManagementDetectedAppManagedDevice -DetectedAppId $app.Id -All | ForEach-Object {
        [pscustomobject]@{
            App          = $app.DisplayName
            Version      = $app.Version
            Device       = $_.DeviceName
        }
    }
}

New-Item -Path (Split-Path $OutFile) -ItemType Directory -Force | Out-Null
$rows | Sort-Object App, Version, Device |
    Export-Csv -Path $OutFile -NoTypeInformation -Encoding UTF8 -Delimiter ';'
Write-Output "$($rows.Count) rows written to $OutFile"
