# Lab 6.1 - remediation script of the remediation etcX-Reg
# Replace etcX with your prefix (for example etc3) before you upload the script.

$Key = 'HKLM:\SOFTWARE\etcX\Lab'

try {
    New-Item -Path $Key -Force -ErrorAction Stop | Out-Null
    Write-Output "Key $Key created"
    exit 0
}
catch {
    Write-Error $_
    exit 1
}
