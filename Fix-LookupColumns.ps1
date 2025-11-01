Function Fix-LookupColumn ($webURL, $listName, $columnName, $lookupListName)
{
    #Get web, list and column objects
    $web = Get-SPWeb $webURL
    $list = $web.Lists[$listName]
    $column = $list.Fields[$columnName]
    $lookupList = $web.Lists[$lookupListName]
    
    #Change schema XML on the lookup column
    $column.SchemaXml = $column.SchemaXml.Replace($column.LookupWebId.ToString(), $web.ID.ToString())
    $column.SchemaXml = $column.SchemaXml.Replace($column.LookupList.ToString(), $lookupList.ID.ToString())
    $column.Update()
    
    #Write confirmation to console and dispose of web object
    write-host "Column" $column.Title "in list" $list.Title "updated to lookup list" $lookupList.Title "in site" $web.Url
    $web.Dispose()
}

Fix-LookupColumn -webURL http://SiteURL -listName "Name of list containing the lookup column" -columnName "Lookup column name" -lookupListName "List used by the lookup column"
Fix-LookupColumn -webURL http://portal -listName "News" -columnName "Countries" -lookupListName "Country List"

Fix-LookupColumn -webURL http://portal -listName "News" -columnName "Departments" -lookupListName "Department List"