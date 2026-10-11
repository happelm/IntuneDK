# Lab 6.2 - detection script of the remediation etcX-RemoteRegistry
# Exit 0 = compliant, exit 1 = issue found -> Intune runs the remediation script.
$svc = Get-Service -Name RemoteRegistry -ErrorAction SilentlyContinue
if (-not $svc) { Write-Output 'Service not found'; exit 0 }
if ($svc.StartType -eq 'Disabled') { Write-Output 'Compliant: Disabled'; exit 0 }
Write-Output "Not compliant: $($svc.StartType)"; exit 1
