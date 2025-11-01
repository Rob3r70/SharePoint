<##
	this is not my authoring work, but I cannot remember where I got it and cannot credit the right persons

##>

#Decode permission mask
# Define SPBasePermissions as enum with values
Add-Type -TypeDefinition @"
[System.Flags]
public enum SPBasePermissions : ulong {
    EmptyMask = 0x0000000000000000,
    ViewListItems = 0x0000000000000001,
    AddListItems = 0x0000000000000002,
    EditListItems = 0x0000000000000004,
    DeleteListItems = 0x0000000000000008,
    ApproveItems = 0x0000000000000010,
    OpenItems = 0x0000000000000020,
    ViewVersions = 0x0000000000000040,
    DeleteVersions = 0x0000000000000080,
    CancelCheckout = 0x0000000000000100,
    ManagePersonalViews = 0x0000000000000200,
    ManageLists = 0x0000000000000400,
    ViewFormPages = 0x0000000000000800,
    AnonymousSearchAccessList = 0x0000000000001000,
    Open = 0x0000000000002000,
    ViewPages = 0x0000000000004000,
    AddAndCustomizePages = 0x0000000000008000,
    ApplyThemeAndBorder = 0x0000000000010000,
    ApplyStyleSheets = 0x0000000000020000,
    ViewUsageData = 0x0000000000040000,
    CreateSSCSite = 0x0000000000080000,
    ManageSubwebs = 0x0000000000100000,
    CreateGroups = 0x0000000000200000,
    ManagePermissions = 0x0000000000400000,
    BrowseDirectories = 0x0000000000800000,
    BrowseUserInfo = 0x0000000001000000,
    AddDelPrivateWebParts = 0x0000000002000000,
    UpdatePersonalWebParts = 0x0000000004000000,
    ManageWeb = 0x0000000008000000,
    UseClientIntegration = 0x0000000010000000,
    UseRemoteAPIs = 0x0000000020000000,
    ManageAlerts = 0x0000000040000000,
    CreateAlerts = 0x0000000080000000,
    EditMyUserInfo = 0x0000000100000000,
    AllPermissions = 0x7FFFFFFFFFFFFFFF
}
"@ -ErrorAction SilentlyContinue

# Function to decode the permission mask
function Decode-SPPermissionMask {
    param (
        [Parameter(Mandatory = $true)]
        [string]$MaskInput
    )

    try {
        $mask = if ($MaskInput.StartsWith("0x")) {
            [Convert]::ToUInt64($MaskInput, 16)
        } else {
            [Convert]::ToUInt64($MaskInput)
        }

        Write-Host "Permission Mask: $MaskInput (`0x$("{0:X}" -f $mask)`)" -ForegroundColor Cyan
        Write-Host "Enabled Permissions:" -ForegroundColor Yellow

        foreach ($perm in [Enum]::GetValues([SPBasePermissions])) {
            if ($perm -ne [SPBasePermissions]::EmptyMask -and ($mask -band [uint64]$perm) -eq [uint64]$perm) {
                Write-Host " - $perm"
            }
        }
    } catch {
        Write-Host "Invalid mask format. Use hex (0x...) or decimal." -ForegroundColor Red
    }
}

# Example usage:
# Decode-SPPermissionMask -MaskInput "0xB008431061"
# Or in decimal: Decode-SPPermissionMask -MaskInput "755769089185"

