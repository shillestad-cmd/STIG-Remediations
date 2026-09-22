<#
.SYNOPSIS
    This PowerShell script ensures that the maximum size of the Windows Application event log is at least 32768 KB (32 MB).

.NOTES
    Author          : Shad Hillestad
    LinkedIn        : linkedin.com/in/shad-hillestad/
    GitHub          : github.com/shillestad-cmd
    Date Created    : 2026-09-22
    Last Modified   : 2026-09-22
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-AU-000500
    Documentation   : https://stigaview.com/products/win11/v2r5/WN11-AU-000500/

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\STIG-ID-WN10-AU-000500.ps1 
#>

# YOUR CODE GOES HERE

$RegPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application'

# Set the STIG-required registry policy in KB
New-Item -Path $RegPath -Force -ErrorAction Stop | Out-Null
New-ItemProperty -Path $RegPath -Name 'MaxSize' -PropertyType DWord -Value 32768 -Force -ErrorAction Stop | Out-Null

# Apply the log size immediately (wevtutil uses bytes)
wevtutil.exe sl Application /ms:33554432

# Verify: both results should be 32768 KB
Get-ItemPropertyValue -Path $RegPath -Name 'MaxSize'
(Get-WinEvent -ListLog Application).MaximumSizeInBytes / 1KB
