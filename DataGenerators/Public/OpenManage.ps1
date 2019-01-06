###Dependency: OpenManage Server Administrator###

function Get-FanSpeed($computername) {
        if(!($computername)){
        	$computername = "localhost"
	}
        Get-WmiObject cim_tachometer -Namespace root\cimv2\dell -Computer $computername | Select-Object Name, CurrentReading | ConvertTo-Json
}

#example:
#Get-FanSpeed "localhost" | Send-ToElma


function Get-RAIDPhysicalInfoFromOMSA{
    $disks = @()
    $storage = & "C:\Program Files\Dell\SysMgt\oma\bin\omreport.exe" storage pdisk controller=0
    foreach ($line in $storage)
    {
        # ID
        if(($line) -like "ID*")
        {
            $disk = New-Object System.Object
            $line = $line.split(":")[1..3].Replace(" ","")
            $line = $line[0],$line[1],$line[2] -join ":"
            $disk | Add-Member -MemberType NoteProperty -Name ID -Value $line
        }
        	# Product ID
        if(($line) -like "Product ID*")
        {
            $line = $line.Split(":")[1].Trim()
            $disk | Add-Member -MemberType NoteProperty -Name "Product ID" -Value $line
        }
        # Status
        if(($line) -like "Status*")
        {
            $line = $line.Split(":")[1].Replace(" ","")
            $disk | Add-Member -MemberType NoteProperty -Name Status -Value $line
        }
	    # Media
	    if(($line) -like "Media*")
	    {
	        $line = $line.Split(":")[1].Replace(" ","")
            $disk | Add-Member -MemberType NoteProperty -Name Media -Value $line
    	}
        # Serial No.
	    if(($line) -like "Serial No.*")
	    {
	        $line = $line.Split(":")[1].Replace(" ","")
            $disk | Add-Member -MemberType NoteProperty -Name "SerialNumber" -Value $line
	    }
	    # Failure Predicted
	    if(($line) -like "Failure Predicted*")
	    {
	        $line = $line.Split(":")[1].Replace(" ","")
            $disk | Add-Member -MemberType NoteProperty -Name "Failure Predicted" -Value $line
	    }
        # State
        if(($line) -like "State*")
        {
            $line = $line.Split(":")[1].Replace(" ","")
            $disk | Add-Member -MemberType NoteProperty -Name State -Value $line
            $disks += $disk
        }
           
    }
    $disks | ConvertTo-Json
    }

#example:
#Get-RAIDPhysicalInfoFromOMSA | Send-ToElma


function Get-RAIDVirtualInfoFromOMSA {
    $disks = @()
    $storage = & "C:\Program Files\Dell\SysMgt\oma\bin\omreport.exe" storage vdisk
    foreach ($line in $storage)
    {
	# ID
    if(($line) -like "ID*")
        {
	        $disk = New-Object System.Object
            $line = $line.Split(":")[1].Trim()
            $disk | Add-Member -MemberType NoteProperty -Name "ID" -Value $line
        }
    # Status
    if(($line) -like "Status*")
        {
            $line = $line.Split(":")[1].Replace(" ","")
            $disk | Add-Member -MemberType NoteProperty -Name Status -Value $line
        }
	# Name
	if(($line) -like "Name*")
	{
		    $line = $line.Split(":")[1].Replace(" ","")
       		$disk | Add-Member -MemberType NoteProperty -Name Name -Value $line
	}
	# Layout
	if(($line) -like "Layout*")
	{
		    $line = $line.Split(":")[1].Replace(" ","")
       		$disk | Add-Member -MemberType NoteProperty -Name "Layout" -Value $line
	}
	# Size
	if(($line) -like "Size*")
	{
		    $line = $line.Split(":")[1].Trim()
        	$disk | Add-Member -MemberType NoteProperty -Name "Size" -Value $line
	}
	# Read Policy
    if(($line) -like "Read Policy*")
        {
            $line = $line.Split(":")[1].Trim()
            $disk | Add-Member -MemberType NoteProperty -Name "Read Policy" -Value $line
        }
	# Write Policy
    if(($line) -like "Write Policy*")
        {
            $line = $line.Split(":")[1].Trim()
            $disk | Add-Member -MemberType NoteProperty -Name "Write Policy" -Value $line
        }
    # State
    if(($line) -like "State*")
        {
            $line = $line.Split(":")[1].Replace(" ","")
            $disk | Add-Member -MemberType NoteProperty -Name State -Value $line
            $disks += $disk
        }
           
    }
    $disks | ConvertTo-Json
    }

#example:
#Get-RAIDVirtualInfoFromOMSA | Send-ToElma