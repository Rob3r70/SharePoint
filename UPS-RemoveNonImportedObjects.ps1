asnp *SharePoint*

$UPS= Get-SPServiceApplication |?{$_.typename -like "*user*"}

#Full sync
$UPS.StartImport($true)

$UPS= Get-SPServiceApplication |?{$_.typename -like "*user*"}

while($ups.IsSynchronizationRunning){
    Start-Sleep 10
    write-host "Sinhronization is running..."
    $UPS= Get-SPServiceApplication |?{$_.typename -like "*user*"}

}


$UPS= Get-SPServiceApplication |?{$_.typename -like "*user*"}
Set-SPProfileServiceApplication $UPS -GetNonImportedObjects $true

Set-SPProfileServiceApplication $UPS -PurgeNonImportedObjects $true


Get-SPTimerJob -Identity mysitecleanup |Start-SPTimerJob