
$dbServer="dbserver"
$socialDb="SP2022_SA_UPS_Social"
$path="c:\temp\socialLinks.csv"

$csv=import-csv $path


# Define connection string (modify as needed)
$connectionString = "Server=$dbServer;Database=$socialDb;Integrated Security=True"

$upsProxy=Get-SPServiceApplicationProxy | ?{$_.typename -like "*user*"}
# Define parameters
$partitionID = [Guid]"0C37852B-34D0-418e-91C6-2AC25AF4BE5B"  # Replace with actual partitionID
$correlationId = [Guid]::NewGuid() # Replace with the actual correlation ID logic


foreach($c in $csv){
		
	$oldUrl = $c.old # Replace with actual old URL
	$newUrl = $c.newUrl # Replace with actual new URL

	# Create SQL connection
	$connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
	$connection.Open()

	# Create SQL command
	$command = $connection.CreateCommand()
	$command.CommandText = "dbo.proc_SocialData_MergeSocialNotes"
	$command.CommandType = [System.Data.CommandType]::StoredProcedure

	# Add parameters
	$command.Parameters.Add((New-Object System.Data.SqlClient.SqlParameter("@partitionID", [System.Data.SqlDbType]::UniqueIdentifier))).Value = $partitionID
	$command.Parameters.Add((New-Object System.Data.SqlClient.SqlParameter("@correlationId", [System.Data.SqlDbType]::UniqueIdentifier))).Value = $correlationId
	$command.Parameters.Add((New-Object System.Data.SqlClient.SqlParameter("@oldUrl", [System.Data.SqlDbType]::VarChar, 255))).Value = $oldUrl
	$command.Parameters.Add((New-Object System.Data.SqlClient.SqlParameter("@newUrl", [System.Data.SqlDbType]::VarChar, 255))).Value = $newUrl

	# Output parameter
	$successParam = New-Object System.Data.SqlClient.SqlParameter("@success", [System.Data.SqlDbType]::Bit)
	$successParam.Direction = [System.Data.ParameterDirection]::Output
	$command.Parameters.Add($successParam)

	# Execute command
	$ex=$command.ExecuteNonQuery()

	# Check output parameter value
	$success = [bool]$command.Parameters["@success"].Value

	# Close connection
	$close=$connection.Close()

	# Return success value
	if( $success){
		write-host "Migrate $oldUrl to $newUrl success"
	}
	else{
		write-host "Migrate $oldUrl to $newUrl error" -foregroundcolor red
	}
}
