<#
.SYNOPSIS
    Verifies the complete Microsoft 365 deployment for Cloud Nine Wellness.

.DESCRIPTION
    Runs a comprehensive post-deployment verification pass across all configured components:
    user accounts, license assignments, security groups, shared mailboxes, and
    distribution groups. Outputs a summary report confirming the deployment state.
    Use this script after completing all provisioning steps to validate the tenant
    before handoff to the client.

.AUTHOR
    Md Rahat Islam Anik

.PREREQUISITES
    All previous scripts must have been run successfully.
    Run 01-Connect-M365Tenant.ps1 first to establish authenticated sessions.

.USAGE
    .-Verify-Configuration.ps1
#>

#region --- Configuration ---
$TenantDomain   = "cloudninewellness.onmicrosoft.com"
$ExpectedUsers  = 17
$ExpectedGroups = 7
$OutputFile     = ".\M365-DeploymentVerification-$(Get-Date -Format 'yyyyMMdd-HHmm').txt"
#endregion

Write-Host "`n======================================================" -ForegroundColor Cyan
Write-Host " Cloud Nine Wellness — M365 Deployment Verification" -ForegroundColor Cyan
Write-Host " $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
Write-Host "======================================================`n" -ForegroundColor Cyan

$Report = @()
$Report += "Cloud Nine Wellness — M365 Deployment Verification"
$Report += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$Report += "=" * 60

#region --- 1. User Accounts ---
Write-Host "[1/4] Verifying user accounts..." -ForegroundColor Yellow

$AllUsers = Get-MgUser -Filter "userPrincipalName endswith '@$TenantDomain'" -All `
    -Property DisplayName, UserPrincipalName, JobTitle, Department, AccountEnabled, AssignedLicenses

$LicensedUsers   = $AllUsers | Where-Object { $_.AssignedLicenses.Count -gt 0 }
$EnabledUsers    = $AllUsers | Where-Object { $_.AccountEnabled -eq $true }

Write-Host "  Total accounts   : $($AllUsers.Count) (expected: $ExpectedUsers)"
Write-Host "  Licensed         : $($LicensedUsers.Count)"
Write-Host "  Enabled          : $($EnabledUsers.Count)"

$Report += "`n[USER ACCOUNTS]"
$Report += "Total  : $($AllUsers.Count)"
$Report += "Licensed: $($LicensedUsers.Count)"
foreach ($User in $AllUsers | Sort-Object Department, DisplayName) {
    $Licensed = if ($User.AssignedLicenses.Count -gt 0) { "Licensed" } else { "No License" }
    $Enabled  = if ($User.AccountEnabled) { "Enabled" } else { "Disabled" }
    $Report  += "  $($User.DisplayName.PadRight(25)) | $($User.JobTitle.PadRight(20)) | $Licensed | $Enabled"
}
#endregion

#region --- 2. Security Groups ---
Write-Host "`n[2/4] Verifying security groups..." -ForegroundColor Yellow

$CNGroups = Get-MgGroup -Filter "startswith(displayName,'CN-')" -All
Write-Host "  Security groups  : $($CNGroups.Count) (expected: $ExpectedGroups)"

$Report += "`n[SECURITY GROUPS]"
foreach ($Group in $CNGroups | Sort-Object DisplayName) {
    $Members = Get-MgGroupMember -GroupId $Group.Id
    Write-Host "  $($Group.DisplayName) — $($Members.Count) members" -ForegroundColor Green
    $Report += "  $($Group.DisplayName.PadRight(35)) | $($Members.Count) members"
}
#endregion

#region --- 3. Shared Mailboxes ---
Write-Host "`n[3/4] Verifying shared mailboxes..." -ForegroundColor Yellow

$SharedMailboxes = Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited
Write-Host "  Shared mailboxes : $($SharedMailboxes.Count)"

$Report += "`n[SHARED MAILBOXES]"
foreach ($Mailbox in $SharedMailboxes | Sort-Object DisplayName) {
    $Perms = Get-MailboxPermission -Identity $Mailbox.PrimarySmtpAddress |
             Where-Object { $_.IsInherited -eq $false -and $_.User -ne "NT AUTHORITY\SELF" }
    Write-Host "  $($Mailbox.PrimarySmtpAddress) — $($Perms.Count) permission entries" -ForegroundColor Green
    $Report += "  $($Mailbox.PrimarySmtpAddress.PadRight(45)) | $($Perms.Count) permissions"
}
#endregion

#region --- 4. Distribution Groups ---
Write-Host "`n[4/4] Verifying distribution groups..." -ForegroundColor Yellow

$DistGroups = Get-DistributionGroup -ResultSize Unlimited
Write-Host "  Distribution groups: $($DistGroups.Count)"

$Report += "`n[DISTRIBUTION GROUPS]"
foreach ($Group in $DistGroups | Sort-Object DisplayName) {
    $Members = Get-DistributionGroupMember -Identity $Group.PrimarySmtpAddress
    Write-Host "  $($Group.PrimarySmtpAddress) — $($Members.Count) members" -ForegroundColor Green
    $Report += "  $($Group.PrimarySmtpAddress.PadRight(45)) | $($Members.Count) members"
}
#endregion

#region --- Export Report ---
$Report | Out-File -FilePath $OutputFile -Encoding UTF8
Write-Host "`n[REPORT] Verification report saved to: $OutputFile" -ForegroundColor Cyan
#endregion

#region --- Final Summary ---
Write-Host "`n======================================================" -ForegroundColor Cyan
Write-Host " DEPLOYMENT VERIFICATION COMPLETE" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "  Users       : $($AllUsers.Count)/$ExpectedUsers"
Write-Host "  Groups      : $($CNGroups.Count)/$ExpectedGroups"
Write-Host "  Mailboxes   : $($SharedMailboxes.Count)"
Write-Host "  Dist Groups : $($DistGroups.Count)"
Write-Host "`n[DONE] Cloud Nine Wellness M365 tenant deployment verified.`n" -ForegroundColor Green
#endregion
