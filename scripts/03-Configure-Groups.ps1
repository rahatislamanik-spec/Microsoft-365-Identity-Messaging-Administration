<#
.SYNOPSIS
    Creates and populates Microsoft 365 security groups for Cloud Nine Wellness.

.DESCRIPTION
    Creates role-based and location-based security groups in Entra ID.
    Populates each group with the appropriate staff members.
    Groups are used to scope license assignments, access control, and
    distribution group membership.

.AUTHOR
    Md Rahat Islam Anik

.PREREQUISITES
    Run 01-Connect-M365Tenant.ps1 and 02-Provision-StaffAccounts.ps1 first.

.USAGE
    .-Configure-Groups.ps1
#>

#region --- Configuration ---
$TenantDomain = "cloudninewellness.onmicrosoft.com"
#endregion

#region --- Group Definitions ---
$Groups = @(
    @{
        Name        = "CN-Instructors-All"
        Description = "All fitness instructors across all three Cloud Nine Wellness studio locations"
        Members     = @("james.okafor","priya.sharma","aisha.nwosu","marco.deluca","omar.diallo","chloe.nguyen")
    },
    @{
        Name        = "CN-FrontDesk-All"
        Description = "All front desk staff across all three studio locations"
        Members     = @("lucas.ferreira","emma.thornton","fatima.alhassan","tyler.brooks","ravi.patel","sofia.mendez")
    },
    @{
        Name        = "CN-Managers-All"
        Description = "Studio managers and corporate management — billing and admin access excluded for non-corporate"
        Members     = @("sarah.mitchell","daniel.park","natasha.kowalski","marcus.reid")
    },
    @{
        Name        = "CN-Studio-KingWest"
        Description = "All staff at the King West studio location"
        Members     = @("sarah.mitchell","james.okafor","priya.sharma","lucas.ferreira","emma.thornton")
    },
    @{
        Name        = "CN-Studio-Yorkville"
        Description = "All staff at the Yorkville studio location"
        Members     = @("daniel.park","aisha.nwosu","marco.deluca","fatima.alhassan","tyler.brooks")
    },
    @{
        Name        = "CN-Studio-LibertyVillage"
        Description = "All staff at the Liberty Village studio location"
        Members     = @("natasha.kowalski","omar.diallo","chloe.nguyen","ravi.patel","sofia.mendez")
    },
    @{
        Name        = "CN-Corporate"
        Description = "Corporate and HR staff — elevated access to admin portal and HR documentation"
        Members     = @("marcus.reid","jennifer.wu")
    }
)
#endregion

#region --- Create Groups and Add Members ---
Write-Host "`n[INFO] Creating $($Groups.Count) security groups..." -ForegroundColor Cyan

foreach ($Group in $Groups) {
    try {
        # Create the security group
        $NewGroup = New-MgGroup `
            -DisplayName     $Group.Name `
            -Description     $Group.Description `
            -MailEnabled     $false `
            -SecurityEnabled $true `
            -MailNickname    ($Group.Name.Replace("-","").ToLower()) `
            -ErrorAction Stop

        Write-Host "  [OK] Created group: $($Group.Name)" -ForegroundColor Green

        # Add members to the group
        foreach ($MemberAlias in $Group.Members) {
            $MemberUPN  = "$MemberAlias@$TenantDomain"
            $MemberUser = Get-MgUser -Filter "userPrincipalName eq '$MemberUPN'" -ErrorAction SilentlyContinue

            if ($MemberUser) {
                New-MgGroupMember -GroupId $NewGroup.Id -DirectoryObjectId $MemberUser.Id -ErrorAction Stop | Out-Null
                Write-Host "    [+] Added: $MemberUPN" -ForegroundColor Gray
            } else {
                Write-Host "    [WARN] User not found: $MemberUPN" -ForegroundColor Yellow
            }
        }
    } catch {
        Write-Host "  [FAIL] Group '$($Group.Name)': $_" -ForegroundColor Red
    }
}
#endregion

#region --- Verify Groups ---
Write-Host "`n[INFO] Verifying created groups..." -ForegroundColor Cyan
foreach ($Group in $Groups) {
    $Verified = Get-MgGroup -Filter "displayName eq '$($Group.Name)'" -ErrorAction SilentlyContinue
    if ($Verified) {
        $MemberCount = (Get-MgGroupMember -GroupId $Verified.Id).Count
        Write-Host "  [OK] $($Group.Name) — $MemberCount members" -ForegroundColor Green
    } else {
        Write-Host "  [MISSING] $($Group.Name)" -ForegroundColor Red
    }
}
#endregion

Write-Host "`n[NEXT] Run 04-Configure-Messaging.ps1 to set up shared mailboxes and distribution groups.`n" -ForegroundColor Cyan
