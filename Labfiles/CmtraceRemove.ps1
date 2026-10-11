# Script to associate .log and .lo_ files to CMtrace and make it the default app to open them and Copy CMTrace.exe to C:\Windows
# Version 1.0
# Jorgen - CCMexec.com
# Remove CmTrace and registry Keys  

Remove-Item "$($env:windir)\CMTrace.exe" -Force 
Remove-Item -LiteralPath 'HKLM:\Software\Classes\Log.File\shell\open\command' -Force -ErrorAction SilentlyContinue

