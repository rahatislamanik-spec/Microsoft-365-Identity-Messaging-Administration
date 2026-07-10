# Cloud Nine Wellness — M365 Deployment Runbook

## Project Overview

**Client:** Cloud Nine Wellness (fictional)
**Scope:** Initial Microsoft 365 tenant deployment for 3 GTA boutique fitness studios
**Staff size:** ~17 provisioned accounts (instructors, front desk, studio managers, corporate)
**Tenant:** cloudninewellness.onmicrosoft.com

---

## Prerequisites

### Required Modules

```powershell
Install-Module Microsoft.Graph -Scope CurrentUser -Force
Install-Module ExchangeOnlineManagement -Scope CurrentUser -Force
```

### Required Permissions

The admin account running these scripts requires:
- Global Administrator **or**
- User Administrator + Exchange Administrator + License Administrator

---

## Deployment Steps

### Step 1 — Establish Connections
```powershell
.\01-Connect-M365Tenant.ps1
```
Connects to Microsoft Graph (with required scopes) and Exchange Online.
Verifies tenant identity and confirms admin access before any changes are made.

**Expected output:** Tenant name, ID, default domain, active plan count.

---

### Step 2 — Provision Staff Accounts
```powershell
.\02-Provision-StaffAccounts.ps1
```
Creates 17 user accounts across 3 studio locations and corporate.
Assigns Microsoft 365 Business Standard licenses to all accounts.
Forces password change on first sign-in.

**Expected output:** 17 accounts created, 17 licensed, 0 failures.

| Location | Accounts |
|---|---|
| King West | 5 (1 manager, 2 instructors, 2 front desk) |
| Yorkville | 5 (1 manager, 2 instructors, 2 front desk) |
| Liberty Village | 5 (1 manager, 2 instructors, 2 front desk) |
| Corporate | 2 (operations director, HR coordinator) |

---

### Step 3 — Configure Security Groups
```powershell
.\03-Configure-Groups.ps1
```
Creates 7 Entra ID security groups — by role and by location.
Populates each group with appropriate staff members.

**Expected output:** 7 groups created, all members added.

| Group | Purpose |
|---|---|
| CN-Instructors-All | All 6 instructors across all studios |
| CN-FrontDesk-All | All 6 front desk staff |
| CN-Managers-All | All 4 managers including corporate |
| CN-Studio-KingWest | All 5 King West staff |
| CN-Studio-Yorkville | All 5 Yorkville staff |
| CN-Studio-LibertyVillage | All 5 Liberty Village staff |
| CN-Corporate | 2 corporate staff |

---

### Step 4 — Configure Messaging
```powershell
.\04-Configure-Messaging.ps1
```
Creates shared mailboxes for each studio front desk.
Grants FullAccess and SendAs permissions to the studio security group.
Creates distribution groups for location-wide and role-wide communication.

**Expected output:** 4 shared mailboxes, 5 distribution groups.

| Shared Mailbox | Access Group |
|---|---|
| kingwest@cloudninewellness.onmicrosoft.com | CN-Studio-KingWest |
| yorkville@cloudninewellness.onmicrosoft.com | CN-Studio-Yorkville |
| libertyvillage@cloudninewellness.onmicrosoft.com | CN-Studio-LibertyVillage |
| hello@cloudninewellness.onmicrosoft.com | CN-Managers-All |

---

### Step 5 — Verify Deployment
```powershell
.\05-Verify-Configuration.ps1
```
Runs a full verification pass across users, groups, mailboxes, and distribution groups.
Exports a timestamped text report to the current directory.

**Expected output:** All counts match expected values. Report file saved.

---

## Post-Deployment Checklist

- [ ] All 17 accounts visible in M365 Admin Center
- [ ] All accounts show license assigned (M365 Business Standard)
- [ ] All 7 security groups visible in Entra ID
- [ ] Shared mailboxes accessible by front desk staff via Outlook (auto-mapped)
- [ ] Distribution groups reachable by sending a test email
- [ ] Admin credentials rotated after deployment
- [ ] Break-glass admin account created and secured separately

---

## Rollback Notes

To remove all provisioned accounts:
```powershell
Get-MgUser -Filter "userPrincipalName endswith '@cloudninewellness.onmicrosoft.com'" |
    Where-Object { $_.UserPrincipalName -ne "admin@cloudninewellness.onmicrosoft.com" } |
    ForEach-Object { Remove-MgUser -UserId $_.Id -Confirm:$false }
```

To remove all CN- security groups:
```powershell
Get-MgGroup -Filter "startswith(displayName,'CN-')" |
    ForEach-Object { Remove-MgGroup -GroupId $_.Id -Confirm:$false }
```
