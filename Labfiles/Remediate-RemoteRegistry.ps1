# Lab 6.2 - remediation script of the remediation etcX-RemoteRegistry
Stop-Service -Name RemoteRegistry -Force -ErrorAction SilentlyContinue
Set-Service -Name RemoteRegistry -StartupType Disabled
Write-Output 'RemoteRegistry disabled'; exit 0
