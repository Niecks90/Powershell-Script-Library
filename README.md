# PowerShell Script Library

Welcome to the **PowerShell Script Library**. This repository is a curated, production-grade toolkit of PowerShell scripts designed for system administrators and infrastructure engineers.

The focus of this toolkit is practical automation: solving real-world operational problems with scripts that are robust, explicitly parameterized, and built for long-term maintainability over novelty.

---

## 🎯 Value Proposition & Principles

- **Automation over repetition**: Tools to handle identity lifecycle, storage thresholds, and security baselining.
- **Explicit rules over implicit assumptions**: Scripts utilize explicit parameters, strict error handling (`try/catch`), and avoid hardcoded environment data.
- **Safe Execution**: All state-changing operations implement `[CmdletBinding(SupportsShouldProcess=$true)]` allowing for safe `-WhatIf` / `-Confirm` dry runs.
- **Predictable systems**: Silencing errors is discouraged; we prefer failing loudly and logging meaningfully over silent failures.

---

## 📚 Script Catalog

### Active Directory
Identity, group membership, and audit utilities.

| Script | Description | Requirements |
|---|---|---|
| `Export-ADUserReport.ps1` | Exports detailed information about AD users from specified OUs to a CSV. | RSAT-AD |
| `Get-ADGroupMemberNeo.ps1` | Recursively extracts members of specific AD groups matching a pattern to a CSV. | RSAT-AD |
| `Get-ADInactiveComputerReport.ps1` | Finds computer accounts inactive for a specified number of days. | RSAT-AD |
| `Get-ADObjectByGuid.ps1` | Retrieves an Active Directory object using its ObjectGUID. | RSAT-AD |
| `Get-ADUserByJobTitle.ps1` | Retrieves Active Directory users based on their job title. | RSAT-AD |
| `Get-ADUserDeactivationDate.ps1` | Retrieves the 'WhenChanged' date for a user account. | RSAT-AD |
| `Get-ADUserDepartment.ps1` | Retrieves a unique list of populated departments from AD users. | RSAT-AD |
| `Get-ADUserLockoutSource.ps1` | Queries the PDC Emulator to find the source machine of an account lockout. | RSAT-AD, PDC Access |
| `Set-ADUserPhoneNumberFormat.ps1` | Standardizes phone number formats across AD fields and outputs a preview. | RSAT-AD |
| `Sync-ADUserDescription.ps1` | Synchronizes the Description field of AD users with their Job Title. | RSAT-AD |
| `Test-ADReplication.ps1` | Tests Active Directory replication health for a specified domain controller. | RSAT-AD |

### Exchange
Exchange Online management utilities.

| Script | Description | Requirements |
|---|---|---|
| `Add-EXODistributionGroupSendAs.ps1` | Grants SendAs permission to a trustee for an EXO distribution group. | ExchangeOnlineManagement |
| `Set-EXOSharedMailboxSentItem.ps1` | Enables copying of sent items for SendAs operations on a shared mailbox. | ExchangeOnlineManagement |

### Security
Hardening, certificates, and baseline audits.

| Script | Description | Requirements |
|---|---|---|
| `Get-ExpiringCertificate.ps1` | Identifies local machine certificates expiring within a given threshold. | Local Admin |
| `Get-LocalAdminGroupMember.ps1` | Audits the members of the local Administrators group. | Local Admin |

### Storage
Disk analytics and maintenance.

| Script | Description | Requirements |
|---|---|---|
| `Get-VolumeThresholdWarning.ps1` | Reports logical volumes that fall below a specific free space percentage. | WMI/CIM Access |

### System
OS maintenance and services.

| Script | Description | Requirements |
|---|---|---|
| `Invoke-LogRotation.ps1` | Archives and removes old log files in a specified directory. | File System Access |
| `Test-RemoteServiceHealth.ps1` | Tests the health and status of specific services on remote computers. | WinRM enabled |

---

## ⚙️ Prerequisites & Setup

### Execution Policy
To run these scripts, ensure your PowerShell execution policy allows the execution of local scripts. You may need to run PowerShell as Administrator and set the policy:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Module Dependencies
Many scripts require specific PowerShell modules to interact with infrastructure:
- **ActiveDirectory (RSAT)**: Required for all scripts in the `ActiveDirectory` folder. Install via Windows Optional Features.
- **ExchangeOnlineManagement**: Required for `Exchange` scripts. Install via the PSGallery:
  ```powershell
  Install-Module -Name ExchangeOnlineManagement -Force
  ```

---

## 💻 Usage Examples

All scripts utilize standard Comment-Based Help (CBH). You can view detailed usage and examples for any script using the `Get-Help` cmdlet:

```powershell
Get-Help .\ActiveDirectory\Sync-ADUserDescription.ps1 -Full
```

**Safe Execution Example (Dry-Run):**
```powershell
.\System\Invoke-LogRotation.ps1 -LogPath "C:\Logs" -DaysToKeep 30 -WhatIf
```

**Reporting Example:**
```powershell
.\Security\Get-ExpiringCertificate.ps1 -DaysToExpiration 45 -StoreName "My"
```

---

## 🤝 Contribution & Coding Standards

Contributions are welcome! When adding new scripts or modifying existing ones, please adhere to the following standards:
1. **Naming Convention**: Use approved PowerShell `Verb-Noun` conventions.
2. **Documentation**: Every script MUST include a complete Comment-Based Help block.
3. **Safety First**: Any script that modifies state (changes data, deletes files) MUST include `[CmdletBinding(SupportsShouldProcess=$true)]` and implement `$PSCmdlet.ShouldProcess()`.
4. **Error Handling**: Use structured `try/catch` blocks. Avoid relying on `$ErrorActionPreference = 'SilentlyContinue'` unless absolutely necessary. Prefer explicit error handling.
5. **No Hardcoding**: Credentials, specific OU paths, or internal server names must be exposed as parameters with appropriate validation (`[ValidateNotNullOrEmpty()]`).
