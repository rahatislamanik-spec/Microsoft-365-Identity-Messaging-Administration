# Microsoft 365 Tenant Deployment — Cloud Nine Wellness

### Entra ID · Exchange Online · SharePoint · PowerShell Automation · Security & Compliance

**Md Rahat Islam Anik**

[![GitHub Repo](https://img.shields.io/badge/GitHub-Repository-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/rahatislamanik-spec/microsoft-365-identity-messaging-administration)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-rahatislamanik-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/rahatislamanik)

---

## Background

Cloud Nine Wellness operates three boutique fitness studios across the GTA with a combined staff of approximately 25 — front-desk, instructors, studio managers, and operations. The business had been operating without a managed email or identity system, relying on personal accounts and shared spreadsheets for day-to-day coordination.

This project covers initial Microsoft 365 tenant deployment: identity and access setup, mailbox and distribution configuration, file-sharing governance, and baseline security policy. Provisioning tasks were scripted via PowerShell to support repeatable onboarding as the organization adds staff.

---

## Scope of Work

### Identity & Access (Entra ID)

Staff accounts were provisioned and organized into security groups by role and location. Access was scoped by group — front-desk and instructor accounts are excluded from billing and tenant administration. Licenses were assigned and verified through both the Admin Center and PowerShell.

### Messaging (Exchange Online)

Shared mailboxes were configured for front-desk operations, enabling multiple staff to manage client correspondence without individual credentials. Distribution groups were set up per location for scheduling and shift communication.

### Collaboration & File Governance (SharePoint / OneDrive)

Tenant-level sharing policies were configured, with external sharing restricted by default — applicable given the handling of client intake forms and basic personal information.

### Security & Compliance

Baseline tenant security and compliance policies were applied through the Microsoft 365 Security & Compliance Center, establishing a consistent governance starting point.

### Automation (PowerShell — Microsoft Graph & Exchange Online)

Provisioning and verification were scripted to reduce repetitive portal work:

- **User provisioning** — accounts created via script with correct attributes and license assignments
- **Group management** — groups created and populated via command line
- **Verification** — configuration confirmed through PowerShell output

---

## Tech Stack

| Category | Tools & Services |
|---|---|
| Identity & Access | Microsoft Entra ID (Azure AD) · RBAC |
| Messaging | Exchange Online · Shared Mailboxes · Distribution Groups |
| Collaboration | SharePoint Online · OneDrive for Business |
| Administration | Microsoft 365 Admin Center · Security & Compliance Center |
| Automation | PowerShell · Microsoft Graph Module · Exchange Online Module |

---

## Skills Demonstrated

`Microsoft 365 Administration` · `Entra ID` · `Identity & Access Management` · `Exchange Online` · `Shared Mailboxes` · `Distribution Groups` · `SharePoint Online` · `OneDrive Governance` · `PowerShell Automation` · `Microsoft Graph SDK` · `RBAC` · `License Management` · `Security & Compliance Governance`

---

## Screenshots

### Microsoft 365 Admin Center — User & License Management
![Microsoft 365 Admin Users](screenshots/01_m365_admin_users.jpg)

### PowerShell — Staff Account Provisioning
![PowerShell Create Users](screenshots/02_powershell_create_users.jpg)

### Microsoft 365 — Group Configuration
![M365 Help Desk Group Created](screenshots/03_m365_helpdesk_group_created.jpg)

### PowerShell — Configuration Verification
![PowerShell Verify Users](screenshots/04_powershell_verify_users.jpg)

### Project Overview
![Project Logo](screenshots/05_project_logo.jpg)

---

## Author

**Md Rahat Islam Anik**

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=flat&logo=linkedin)](https://linkedin.com/in/rahatislamanik)
[![GitHub](https://img.shields.io/badge/GitHub-Portfolio-181717?style=flat&logo=github)](https://github.com/rahatislamanik-spec)
