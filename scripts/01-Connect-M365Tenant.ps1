<#
.SYNOPSIS
    Connects to Microsoft 365 tenant services required for Cloud Nine Wellness deployment.

.DESCRIPTION
    Establishes authenticated sessions to Microsoft Graph PowerShell SDK and Exchange Online
    Management module. Verifies tenant identity, subscription details, and confirms admin
    access before any provisioning work begins.

.AUTHOR
    Md Rahat Islam Anik

.PREREQUISITES
    - Microsoft.Graph PowerShell module (Install-Module Microsoft.Graph)
    - ExchangeOnlineManagement module (Install-Module ExchangeOnlineManagement)
    - Global Administrator or Exchange Administrator credentials

.USAGE
    Run this script first before any other script in this series.
    .-Connect-M365Tenant.ps1
#>

#region --- Configuration ---
$TenantDomain     = "cloudninewellness.onmicrosoft.com"
$AdminUPN         = "admin@cloudninewellness.onmicrosoft.com"
#endregion

#region --- Module Check ---
Write-Host "`n[INFO] Checking required PowerShell modules..." -ForegroundColor Cyan

$RequiredModules = @("Microsoft.Graph", "ExchangeOnlineManagement")

foreach ($Module in $RequiredModules) {
    if (-not (Get-Module -ListAvailable -Name $Module)) {
        Write-Host "[WARNING] Module '$Module' not found. Installing..." -ForegroundColor Yellow
        Install-Module -Name $Module -Scope CurrentUser -Force -AllowClobber
    } else {
        Write-Host "[OK] Module '$Module' is available." -ForegroundColor Green
    }
}
#endregion

#region --- Connect to Microsoft Graph ---
Write-Host "`n[INFO] Connecting to Microsoft Graph..." -ForegroundColor Cyan

$GraphScopes = @(
    "User.ReadWrite.All",
    "Group.ReadWrite.All",
    "Directory.ReadWrite.All",
    "Organization.Read.All",
    "RoleManagement.ReadWrite.Directory"
)

try {
    Connect-MgGraph -Scopes $GraphScopes -ErrorAction Stop
    Write-Host "[OK] Connected to Microsoft Graph successfully." -ForegroundColor Green
} catch {
    Write-Error "[ERROR] Failed to connect to Microsoft Graph: $_"
    exit 1
}
#endregion

#region --- Connect to Exchange Online ---
Write-Host "`n[INFO] Connecting to Exchange Online..." -ForegroundColor Cyan

try {
    Connect-ExchangeOnline -UserPrincipalName $AdminUPN -ShowProgress $true -ErrorAction Stop
    Write-Host "[OK] Connected to Exchange Online successfully." -ForegroundColor Green
} catch {
    Write-Error "[ERROR] Failed to connect to Exchange Online: $_"
    exit 1
}
#endregion

#region --- Verify Tenant Identity ---
Write-Host "`n[INFO] Verifying tenant details..." -ForegroundColor Cyan

$OrgDetails = Get-MgOrganization
Write-Host "  Tenant Name     : $($OrgDetails.DisplayName)"
Write-Host "  Tenant ID       : $($OrgDetails.Id)"
Write-Host "  Default Domain  : $($OrgDetails.VerifiedDomains | Where-Object { $_.IsDefault } | Select-Object -ExpandProperty Name)"

$AssignedPlans = $OrgDetails.AssignedPlans | Where-Object { $_.CapabilityStatus -eq "Enabled" }
Write-Host "  Active Plans    : $($AssignedPlans.Count) enabled service plans"
#endregion

Write-Host "`n[SUCCESS] M365 tenant connection established. Ready to proceed with provisioning." -ForegroundColor Green
Write-Host "[NEXT]    Run 02-Provision-StaffAccounts.ps1 to create user accounts.`n" -ForegroundColor Cyan
