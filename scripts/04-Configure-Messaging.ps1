<#
.SYNOPSIS
    Configures Exchange Online shared mailboxes and distribution groups for Cloud Nine Wellness.

.DESCRIPTION
    Creates shared mailboxes for front-desk operations at each studio location,
    allowing multiple front-desk staff to manage client correspondence from
    a single address without individual credentials.
    Creates distribution groups per location for scheduling and shift communication.
    Grants appropriate SendAs and FullAccess permissions to front-desk security groups.

.AUTHOR
    Md Rahat Islam Anik

.PREREQUISITES
    Run 01-Connect-M365Tenant.ps1, 02-Provision-StaffAccounts.ps1,
    and 03-Configure-Groups.ps1 first.

.USAGE
    .-Configure-Messaging.ps1
#>

#region --- Configuration ---
$TenantDomain = "cloudninewellness.onmicrosoft.com"
#endregion

#region --- Shared Mailbox Definitions ---
$SharedMailboxes = @(
    @{
        Name         = "King West Front Desk"
        Alias        = "kingwest"
        EmailAddress = "kingwest@$TenantDomain"
        AccessGroup  = "CN-Studio-KingWest"
        Description  = "Shared front desk mailbox for King West studio — client inquiries and bookings"
    },
    @{
        Name         = "Yorkville Front Desk"
        Alias        = "yorkville"
        EmailAddress = "yorkville@$TenantDomain"
        AccessGroup  = "CN-Studio-Yorkville"
        Description  = "Shared front desk mailbox for Yorkville studio — client inquiries and bookings"
    },
    @{
        Name         = "Liberty Village Front Desk"
        Alias        = "libertyvillage"
        EmailAddress = "libertyvillage@$TenantDomain"
        AccessGroup  = "CN-Studio-LibertyVillage"
        Description  = "Shared front desk mailbox for Liberty Village studio — client inquiries and bookings"
    },
    @{
        Name         = "Cloud Nine Wellness — General Inquiries"
        Alias        = "hello"
        EmailAddress = "hello@$TenantDomain"
        AccessGroup  = "CN-Managers-All"
        Description  = "General inquiries mailbox managed by studio managers and corporate team"
    }
)
#endregion

#region --- Distribution Group Definitions ---
$DistributionGroups = @(
    @{
        Name         = "King West — All Staff"
        Alias        = "kingwest-all"
        EmailAddress = "kingwest-team@$TenantDomain"
        Members      = @("sarah.mitchell","james.okafor","priya.sharma","lucas.ferreira","emma.thornton")
    },
    @{
        Name         = "Yorkville — All Staff"
        Alias        = "yorkville-all"
        EmailAddress = "yorkville-team@$TenantDomain"
        Members      = @("daniel.park","aisha.nwosu","marco.deluca","fatima.alhassan","tyler.brooks")
    },
    @{
        Name         = "Liberty Village — All Staff"
        Alias        = "libertyvillage-all"
        EmailAddress = "libertyvillage-team@$TenantDomain"
        Members      = @("natasha.kowalski","omar.diallo","chloe.nguyen","ravi.patel","sofia.mendez")
    },
    @{
        Name         = "All Instructors"
        Alias        = "instructors"
        EmailAddress = "instructors@$TenantDomain"
        Members      = @("james.okafor","priya.sharma","aisha.nwosu","marco.deluca","omar.diallo","chloe.nguyen")
    },
    @{
        Name         = "All Studio Managers"
        Alias        = "managers"
        EmailAddress = "managers@$TenantDomain"
        Members      = @("sarah.mitchell","daniel.park","natasha.kowalski","marcus.reid")
    }
)
#endregion

#region --- Create Shared Mailboxes ---
Write-Host "`n[INFO] Creating $($SharedMailboxes.Count) shared mailboxes..." -ForegroundColor Cyan

foreach ($Mailbox in $SharedMailboxes) {
    try {
        New-Mailbox `
            -Shared `
            -Name         $Mailbox.Name `
            -Alias        $Mailbox.Alias `
            -PrimarySmtpAddress $Mailbox.EmailAddress `
            -ErrorAction Stop | Out-Null

        Write-Host "  [OK] Created shared mailbox: $($Mailbox.EmailAddress)" -ForegroundColor Green

        # Grant FullAccess to the associated studio security group
        Add-MailboxPermission `
            -Identity    $Mailbox.EmailAddress `
            -User        $Mailbox.AccessGroup `
            -AccessRights FullAccess `
            -InheritanceType All `
            -AutoMapping $true `
            -ErrorAction Stop | Out-Null

        # Grant SendAs permission
        Add-RecipientPermission `
            -Identity    $Mailbox.EmailAddress `
            -Trustee     $Mailbox.AccessGroup `
            -AccessRights SendAs `
            -Confirm:$false `
            -ErrorAction Stop | Out-Null

        Write-Host "    [+] FullAccess + SendAs granted to: $($Mailbox.AccessGroup)" -ForegroundColor Gray

    } catch {
        Write-Host "  [FAIL] $($Mailbox.Name): $_" -ForegroundColor Red
    }
}
#endregion

#region --- Create Distribution Groups ---
Write-Host "`n[INFO] Creating $($DistributionGroups.Count) distribution groups..." -ForegroundColor Cyan

foreach ($Group in $DistributionGroups) {
    try {
        New-DistributionGroup `
            -Name             $Group.Name `
            -Alias            $Group.Alias `
            -PrimarySmtpAddress $Group.EmailAddress `
            -MemberJoinRestriction Closed `
            -ErrorAction Stop | Out-Null

        Write-Host "  [OK] Created distribution group: $($Group.EmailAddress)" -ForegroundColor Green

        # Add members
        foreach ($MemberAlias in $Group.Members) {
            $MemberEmail = "$MemberAlias@$TenantDomain"
            Add-DistributionGroupMember `
                -Identity $Group.EmailAddress `
                -Member   $MemberEmail `
                -ErrorAction Stop | Out-Null
            Write-Host "    [+] Added: $MemberEmail" -ForegroundColor Gray
        }
    } catch {
        Write-Host "  [FAIL] $($Group.Name): $_" -ForegroundColor Red
    }
}
#endregion

Write-Host "`n[NEXT] Run 05-Verify-Configuration.ps1 to confirm all components are correctly configured.`n" -ForegroundColor Cyan
