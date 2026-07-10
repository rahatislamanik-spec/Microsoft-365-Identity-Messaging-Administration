<#
.SYNOPSIS
    Provisions Microsoft 365 user accounts for Cloud Nine Wellness staff.

.DESCRIPTION
    Creates user accounts for all three studio locations (King West, Yorkville, Liberty Village).
    Assigns Microsoft 365 Business Standard licenses, sets usage location to Canada,
    and organizes accounts by role (Instructor, Front Desk, Studio Manager).
    All accounts follow the UPN format: firstname.lastname@cloudninewellness.onmicrosoft.com

.AUTHOR
    Md Rahat Islam Anik

.PREREQUISITES
    Run 01-Connect-M365Tenant.ps1 first to establish authenticated sessions.

.USAGE
    .-Provision-StaffAccounts.ps1
#>

#region --- Configuration ---
$TenantDomain   = "cloudninewellness.onmicrosoft.com"
$UsageLocation  = "CA"   # Canada
$LicenseSKU     = "cloudninewellness:O365_BUSINESS_PREMIUM"  # M365 Business Standard
$TempPassword   = "TempPass2026!" # Users prompted to change on first login
#endregion

#region --- Staff Account Definitions ---
# Organized by studio location and role
$StaffAccounts = @(
    # King West Studio
    @{ FirstName="Sarah";   LastName="Mitchell";   Role="Studio Manager"; Location="King West";     Dept="Management" },
    @{ FirstName="James";   LastName="Okafor";     Role="Instructor";     Location="King West";     Dept="Fitness" },
    @{ FirstName="Priya";   LastName="Sharma";     Role="Instructor";     Location="King West";     Dept="Fitness" },
    @{ FirstName="Lucas";   LastName="Ferreira";   Role="Front Desk";     Location="King West";     Dept="Operations" },
    @{ FirstName="Emma";    LastName="Thornton";   Role="Front Desk";     Location="King West";     Dept="Operations" },

    # Yorkville Studio
    @{ FirstName="Daniel";  LastName="Park";       Role="Studio Manager"; Location="Yorkville";     Dept="Management" },
    @{ FirstName="Aisha";   LastName="Nwosu";      Role="Instructor";     Location="Yorkville";     Dept="Fitness" },
    @{ FirstName="Marco";   LastName="Deluca";     Role="Instructor";     Location="Yorkville";     Dept="Fitness" },
    @{ FirstName="Fatima";  LastName="Al-Hassan";  Role="Front Desk";     Location="Yorkville";     Dept="Operations" },
    @{ FirstName="Tyler";   LastName="Brooks";     Role="Front Desk";     Location="Yorkville";     Dept="Operations" },

    # Liberty Village Studio
    @{ FirstName="Natasha"; LastName="Kowalski";   Role="Studio Manager"; Location="Liberty Village"; Dept="Management" },
    @{ FirstName="Omar";    LastName="Diallo";     Role="Instructor";     Location="Liberty Village"; Dept="Fitness" },
    @{ FirstName="Chloe";   LastName="Nguyen";     Role="Instructor";     Location="Liberty Village"; Dept="Fitness" },
    @{ FirstName="Ravi";    LastName="Patel";      Role="Front Desk";     Location="Liberty Village"; Dept="Operations" },
    @{ FirstName="Sofia";   LastName="Mendez";     Role="Front Desk";     Location="Liberty Village"; Dept="Operations" },

    # Corporate/Operations
    @{ FirstName="Marcus";  LastName="Reid";       Role="Operations Director"; Location="Corporate"; Dept="Management" },
    @{ FirstName="Jennifer";LastName="Wu";         Role="HR Coordinator"; Location="Corporate";     Dept="HR" }
)
#endregion

#region --- Create User Accounts ---
Write-Host "`n[INFO] Provisioning $($StaffAccounts.Count) staff accounts..." -ForegroundColor Cyan

$SuccessCount = 0
$FailCount    = 0

foreach ($Staff in $StaffAccounts) {
    $UPN         = "$($Staff.FirstName.ToLower()).$($Staff.LastName.ToLower().Replace('-',''))@$TenantDomain"
    $DisplayName = "$($Staff.FirstName) $($Staff.LastName)"
    $MailNick    = "$($Staff.FirstName.ToLower())$($Staff.LastName.ToLower().Replace('-','').Replace(' ',''))"

    $PasswordProfile = @{
        Password                      = $TempPassword
        ForceChangePasswordNextSignIn = $true
    }

    try {
        $NewUser = New-MgUser `
            -DisplayName      $DisplayName `
            -UserPrincipalName $UPN `
            -MailNickname     $MailNick `
            -GivenName        $Staff.FirstName `
            -Surname          $Staff.LastName `
            -JobTitle         $Staff.Role `
            -Department       $Staff.Dept `
            -UsageLocation    $UsageLocation `
            -PasswordProfile  $PasswordProfile `
            -AccountEnabled   $true `
            -ErrorAction Stop

        # Assign M365 Business Standard license
        $LicenseObj = @{
            AddLicenses    = @(@{ SkuId = (Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "O365_BUSINESS_PREMIUM" }).SkuId })
            RemoveLicenses = @()
        }
        Set-MgUserLicense -UserId $NewUser.Id -AddLicenses $LicenseObj.AddLicenses -RemoveLicenses $LicenseObj.RemoveLicenses | Out-Null

        Write-Host "  [OK] Created: $DisplayName ($UPN) — $($Staff.Role) @ $($Staff.Location)" -ForegroundColor Green
        $SuccessCount++
    } catch {
        Write-Host "  [FAIL] $DisplayName ($UPN): $_" -ForegroundColor Red
        $FailCount++
    }
}
#endregion

#region --- Summary ---
Write-Host "`n[SUMMARY] Provisioning complete." -ForegroundColor Cyan
Write-Host "  Accounts created : $SuccessCount"
Write-Host "  Failures         : $FailCount"
Write-Host "[NEXT] Run 03-Configure-Groups.ps1 to create and populate security groups.`n" -ForegroundColor Cyan
#endregion
