# 🔐 Windows 11 STIG Remediation — Application Event Log Size

## Overview

In this lab, I remediated a Windows 11 STIG finding that requires the Application event log maximum size to be **32,768 KB (32 MB) or greater**.

I first applied the configuration manually through Registry Editor and verified the result with Tenable Vulnerability Management. I then removed the configuration to reproduce the finding, used PowerShell to automate the remediation, and rescanned the virtual machine to confirm it passed.

## 📋 STIG Details

| Item | Details |
|---|---|
| **STIG ID** | WN11-AU-000500 |
| **Vulnerability ID** | V-253337 |
| **Severity** | Medium — CAT II |
| **Requirement** | Application event log maximum size of at least 32,768 KB |
| **Registry value** | `MaxSize` |
| **Value type** | `REG_DWORD` |
| **Required data** | Decimal `32768` or hexadecimal `0x00008000`, or greater |

An undersized event log can fill quickly, limiting the audit history available for troubleshooting and security investigations.

## 🧰 Tools Used

- Windows 11 virtual machine
- Tenable Vulnerability Management
- Windows Registry Editor
- Windows PowerShell / PowerShell ISE

## 1. Identify the Failed STIG Check

I selected **WN11-AU-000500** from the failed compliance checks in my Tenable scan. The finding identified the Application event log size policy as noncompliant.

![Tenable audit details showing WN11-AU-000500 as Failed](images/01-overview.png)

## 2. Review the Remediation Requirements

I researched the STIG and reviewed its check and fix instructions. The check requires the following registry configuration:

```text
Registry Hive:  HKEY_LOCAL_MACHINE
Registry Path:  SOFTWARE\Policies\Microsoft\Windows\EventLog\Application
Value Name:     MaxSize
Value Type:     REG_DWORD
Value Data:     32768 decimal (0x00008000 hexadecimal), or greater
```

The corresponding Group Policy setting is:

```text
Computer Configuration
└── Administrative Templates
    └── Windows Components
        └── Event Log Service
            └── Application
                └── Specify the maximum log file size (KB)
```

The policy should be **Enabled**, with a maximum log size of **32,768 KB or greater**.

![STIG check and fix instructions for the Application event log size](images/02-stig-fix-instructions.png)

## 3. Apply the Remediation Manually

The required registry path did not exist on my virtual machine. Using Registry Editor, I created the missing keys and added the required value.

1. Navigated to `HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows`.
2. Created the missing `EventLog\Application` keys.
3. Created a **DWORD (32-bit) Value** named `MaxSize`.
4. Selected **Decimal** and entered `32768`.

![Registry Editor showing the manually created MaxSize DWORD set to 32768](images/03-manual-registry-configuration.png)

## 4. Restart the Virtual Machine

After applying the manual registry change, I restarted the virtual machine before running another compliance scan.

## 5. Verify the Manual Remediation with Tenable

I rescanned the virtual machine and filtered the audit results for **WN11-AU-000500**.

Tenable reported **Passed**, confirming that the manually configured registry value satisfied this check.

![Tenable showing WN11-AU-000500 as Passed after manual remediation](images/04-manual-tenable-pass.png)

## 6. Reproduce the Finding for Automation Testing

To test the PowerShell remediation, I deliberately removed the registry key I had created in the lab, restarted the virtual machine, and ran another Tenable scan.

The check returned to **Failed**, giving me a confirmed noncompliant configuration to remediate through PowerShell.

![Tenable showing the failed check after removal of the lab configuration](images/05-reproduced-tenable-failure.png)

## 7. Automate the Remediation with PowerShell

I used ChatGPT to help develop the PowerShell commands, then executed them in an elevated PowerShell session on the virtual machine.

The remediation sets the registry policy to **32,768 KB** and applies the active log limit using `wevtutil`, which accepts the size in **bytes**. Therefore, the equivalent value is **33,554,432 bytes**.

The example below includes an administrator requirement, a check before creating the registry key, and error handling for `wevtutil`.

```powershell
#Requires -RunAsAdministrator

$ErrorActionPreference = 'Stop'

$RegPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application'

# Create the registry key if it does not already exist.
if (-not (Test-Path -LiteralPath $RegPath)) {
    New-Item -Path $RegPath -Force | Out-Null
}

# Set the required policy value to 32768 KB.
New-ItemProperty -Path $RegPath `
    -Name 'MaxSize' `
    -PropertyType DWord `
    -Value 32768 `
    -Force | Out-Null

# Apply the active log limit: 32 MB expressed in bytes.
wevtutil.exe sl Application /ms:33554432

if ($LASTEXITCODE -ne 0) {
    throw "Unable to update the Application log size. Exit code: $LASTEXITCODE"
}
```

The complete script, including verification commands, is available here:

**[STIG-ID-WN11-AU-000500.ps1](STIG-ID-WN11-AU-000500.ps1)**

Run it from **PowerShell as Administrator**:

```powershell
.\STIG-ID-WN11-AU-000500.ps1
```

![PowerShell ISE showing the remediation and verification commands used in the lab](images/06-powershell-remediation.png)

## 8. Verify the Registry Configuration

After running the commands, I checked Registry Editor and confirmed that `MaxSize` existed as a `REG_DWORD` with the value **32768**.

The following commands can verify both the registry policy and the active log limit:

```powershell
# Check the configured registry policy in KB.
Get-ItemPropertyValue `
    -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application' `
    -Name 'MaxSize'

# Check the active Application log maximum size in KB.
(Get-WinEvent -ListLog Application).MaximumSizeInBytes / 1KB
```

Expected output after setting both values to 32 MB:

```text
32768
32768
```

![Registry Editor confirming MaxSize is configured correctly after PowerShell remediation](images/07-powershell-registry-verification.png)

## 9. Confirm the PowerShell Remediation with Tenable

I restarted the virtual machine and performed a final Tenable scan.

The results showed **WN11-AU-000500: Passed**, confirming that the PowerShell remediation resolved the finding.

![Final Tenable audit result showing WN11-AU-000500 as Passed](images/08-final-tenable-pass.png)

## ✅ Results

| Validation stage | Tenable result |
|---|---|
| Initial assessment | Failed |
| After manual registry remediation | Passed |
| After removing the configuration for testing | Failed |
| After PowerShell remediation | Passed |

This lab demonstrated a repeatable process for investigating a STIG finding, applying a manual fix, automating the configuration, and validating the result through rescanning. The passing result applies specifically to **WN11-AU-000500**.

## 📚 References

- [STIG-A-View — WN11-AU-000500, Windows 11 V2R5](https://stigaview.com/products/win11/v2r5/WN11-AU-000500/)
- [Microsoft — Application Event Log Size Policy](https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-eventlogservice#specifymaximumfilesizeapplicationlog)
- [Microsoft — wevtutil Command Reference](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/wevtutil)
