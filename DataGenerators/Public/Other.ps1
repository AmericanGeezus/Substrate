#Other
function Get-GPSCoords($sampleSeconds){
    if(!($sampleSeconds)){
    $sampleSeconds = 3
    }
	Add-Type -AssemblyName System.Device
	$geowatcher = New-Object System.Device.Location.GeoCoordinateWatcher 
	$geowatcher.start()
	start-sleep -s 1
	for ($i=1; $i -le $sampleSeconds; $i++)
	{
		start-sleep -s 1
		$geowatcher | select @{n="Timestamp";e={$_.Position.Timestamp.DateTime.DateTime}}, @{n="Latitude";e={$_.Position.Location.Latitude}},@{n="Longitude";e={$_.Position.Location.Longitude}}, @{n="Altitude";e={$_.Position.Location.Altitude}}, @{n="Horizontal Accuracy";e={$_.Position.Location.HorizontalAccuracy}}, @{n="Speed";e={$_.Position.Location.Speed}}, @{n="Course";e={$_.Position.Location.Course}}, @{n="Is Unknown";e={$_.Position.Location.IsUnknown}}
	}
	$geowatcher.stop()
}

#example:
#GetGPSCoords 5 | ConvertTo-Json | Send-ToElma