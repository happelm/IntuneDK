# Lab 6.1 - detection script of the remediation etcX-Reg
# Replace etcX with your prefix (for example etc3) before you upload the script.
# Exit 1 = issue found (key missing) -> Intune runs the remediation script.

$Key = 'HKLM:\SOFTWARE\etcX\Lab'

if (Test-Path -Path $Key) {
    Write-Output "Key $Key exists"
    exit 0
}

Write-Output "Key $Key missing"
exit 1
