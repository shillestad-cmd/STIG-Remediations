<#
.SYNOPSIS
    This PowerShell script disables AutoPlay for all drives.

.NOTES
    Author          : Shad Hillestad
    LinkedIn        : linkedin.com/in/shad-hillestad/
    GitHub          : github.com/shillestad-cmd
    Date Created    : 2026-09-22
    Last Modified   : 2026-09-22
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-CC-000190
    Documentation   : https://dl.dod.cyber.mil/wp-content/uploads/stigs/zip/U_MS_Windows_11_V2R9_STIG.zip

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Run 64-bit PowerShell as Administrator on the target Windows 11 VM.
    Example syntax:
    PS C:\> .\STIG-ID-WN11-CC-000190.ps1
    Restart the VM afterward and rerun the Tenable compliance scan.
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = 'Stop'
$RegPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Explorer'

# Create the registry key if it is missing.
if (-not (Test-Path -Path $RegPath)) {
    New-Item -Path $RegPath -Force | Out-Null
}

# Apply the required STIG setting.
New-ItemProperty -Path $RegPath -Name 'NoDriveTypeAutoRun' -PropertyType DWord -Value 255 -Force | Out-Null

# Display the configured value. Expected output: 255.
Get-ItemPropertyValue -Path $RegPath -Name 'NoDriveTypeAutoRun'
