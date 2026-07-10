# Scripts — Cloud Nine Wellness M365 Deployment

PowerShell automation scripts for the complete Microsoft 365 tenant deployment.
All scripts use the Microsoft Graph PowerShell SDK and Exchange Online Management module.

## Run Order

| # | Script | Purpose |
|---|---|---|
| 1 | `01-Connect-M365Tenant.ps1` | Authenticate to Microsoft Graph and Exchange Online, verify tenant |
| 2 | `02-Provision-StaffAccounts.ps1` | Create 17 staff accounts across 3 studio locations, assign licenses |
| 3 | `03-Configure-Groups.ps1` | Create 7 security groups by role and location, populate members |
| 4 | `04-Configure-Messaging.ps1` | Create shared mailboxes and distribution groups in Exchange Online |
| 5 | `05-Verify-Configuration.ps1` | Post-deployment verification pass, exports summary report |

## Prerequisites

```powershell
Install-Module Microsoft.Graph -Scope CurrentUser
Install-Module ExchangeOnlineManagement -Scope CurrentUser
```

## Tenant Details (Sanitized)

- **Tenant domain:** `cloudninewellness.onmicrosoft.com`
- **Admin UPN:** `admin@cloudninewellness.onmicrosoft.com`
- **License SKU:** Microsoft 365 Business Standard
- **Usage location:** CA (Canada)

## Notes

- All scripts include inline error handling and output progress to the console
- Script 5 exports a timestamped verification report to the current directory
- Run scripts in numbered order — each script depends on the previous completing successfully
- Temporary password (`TempPass2026!`) forces change on first sign-in
