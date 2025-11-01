$ctx=[Microsoft.Office.Server.ServerContext]::GetContext((Get-SPWebApplication|Select -First 1))	
$upm=new-object Microsoft.Office.Server.UserProfiles.UserProfileManager -ArgumentList @($ctx)
$lang="sl-SI,en-US"
$enum=$upm.GetEnumerator()
while($enum.MoveNext()) {
	    $up=$enum.Current
	    write-host "$($up.DisplayName) ($($up.AccountName))"
	    $up["SPS-MUILanguages"].Value =$lang
	    $up["SPS-ContentLanguages"].Value=$lang
	    $up["SPS-RegionalSettings-Initialized"].Value =$true
	    $up.Commit()
}


Get-SPTimerJob|?{ $_.Name -like "*user*profile*languageandregion*"} |%{ $_.RunNow() }


$up=$upm.GetUserProfile("sp_farm_admin")
$up