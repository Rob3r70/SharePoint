$aud = Get-SPUsageDefinition | where {$_.Name -like "Analytics*"}  
$aud | fl  

$prud = Get-SPUsageDefinition | where {$_.Name -like "Page Requests"}  
$prud | fl 

$prud = Get - SPUsageDefinition | where {  
    $_.Name - like "Page Requests"  
}  
$prud.EnableReceivers = $true  
$prud.Enabled = $true  
$prud.Update()  
$aud = Get - SPUsageDefinition | where {  
    $_.Name - like "Page Requests*"  
}  
$aud | fl

$aud = Get - SPUsageDefinition | where {  
    $_.Name - like "Analytics*"  
}  
$aud.EnableReceivers = $true  
$aud.Enabled = $true  
$aud.Update()  
$prud = Get - SPUsageDefinition | where {  
    $_.Name - like "Analytics"  
}  
$prud | fl 


$prud = Get-SPUsageDefinition | where {$_.Name -like "Page Requests"}  
  
$prud.Receivers.Add("Microsoft.Office.Server.Search.Applications, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c","Microsoft.Office.Server.Search.Analytics.Internal.ViewRequestUsageReceiver")  
  
$prud.EnableReceivers=$true  

$aud = Get-SPUsageDefinition | where {$_.Name -like "Analytics*"}  
  
$aud.Receivers.Add("Microsoft.Office.Server.Search.Applications, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c", "Microsoft.Office.Server.Search.Analytics.Internal.AnalyticsCustomRequestUsageReceiver")  
  
$aud.EnableReceivers = $true  