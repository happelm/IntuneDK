# Lab 5.3 - detection script of the remediation etcX-Reinstall-CMTrace
# Reports an issue as long as the detection file of etcX-CMTrace exists -> the remediation removes it.
$file = 'C:\Windows\CMTrace.exe'
if (Test-Path -Path $file) { Write-Output 'CMTrace.exe present'; exit 1 }
Write-Output 'CMTrace.exe already removed'; exit 0
