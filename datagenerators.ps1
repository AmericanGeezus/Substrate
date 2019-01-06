
#  ███████╗██╗  ██╗ █████╗ ███╗   ███╗██████╗ ██╗     ███████╗               
#  ██╔════╝╚██╗██╔╝██╔══██╗████╗ ████║██╔══██╗██║     ██╔════╝               
#  █████╗   ╚███╔╝ ███████║██╔████╔██║██████╔╝██║     █████╗                 
#  ██╔══╝   ██╔██╗ ██╔══██║██║╚██╔╝██║██╔═══╝ ██║     ██╔══╝                 
#  ███████╗██╔╝ ██╗██║  ██║██║ ╚═╝ ██║██║     ███████╗███████╗               
#  ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝     ╚══════╝╚══════╝               
#                                                                            
#  ███████╗██╗   ██╗███╗   ██╗ ██████╗████████╗██╗ ██████╗ ███╗   ██╗███████╗
#  ██╔════╝██║   ██║████╗  ██║██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
#  █████╗  ██║   ██║██╔██╗ ██║██║        ██║   ██║██║   ██║██╔██╗ ██║███████╗
#  ██╔══╝  ██║   ██║██║╚██╗██║██║        ██║   ██║██║   ██║██║╚██╗██║╚════██║
#  ██║     ╚██████╔╝██║ ╚████║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║███████║
#  ╚═╝      ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝
                                                                            

function Send-ToElma {
    <#
    .SYNOPSIS
    Sends the output of other commands to a Substrate instance..
    .DESCRIPTION
    The cmdlet supports receiving GroupInfo Objects, JSON formatted strings,
    or single string input from the pipeline. Substrate endpoints require JSON
    formatted data. 
    #>


    [CmdletBinding()]
    param(

    [parameter(ValueFromPipeline=$true)]
    [string]$string,
    [parameter(ValueFromPipeline=$true)]
    [object]$body,
    [parameter(ValueFromPipeline=$true)]
    [Microsoft.PowerShell.Commands.GroupInfo]
    $group,
    [parameter(ValueFromPipeline=$false)]
    [Switch]$Convert,
    [parameter(ValueFromPipeline=$false)]
    [Switch]$SendEach,
    $port = 3000
    )
    begin{
    $SwitchPrompt = @"
    1 - Attempt to convert and send object.
    2 - Attempt to convert, but do not send.
    3 - Continue processing any remaining items in the pipe.
    4 - Break pipeline, send nothing.
"@
    
   
    $RequestValues = @{
    Method = "Post"
    ContentType = "application/json; charset=UTF-8"
    URI = "https://geezus.net:$($port)/push"
    }

    

    $Combined = @()

    }

    process {


    if($SendEach){
    
    $BodyJson = $Group.Group | ConvertTo-Json
    Invoke-WebRequest @RequestValues -Body $BodyJson
    }else{
    $CurrentItem = $_
    $Combined += $CurrentItem.group
    }
    }

    end{


    if($SendEach){Continue}
        else{
            if($Convert){
            Invoke-WebRequest @RequestValues -Body $($Combined | ConvertTo-Json)
            }else{
                
                try{$BodyTest = $Body | ConvertFrom-Json -ErrorAction Stop 
                    $ValidJson = $True
                } catch{ $ValidJson = $False}
                try{$BodyTest = $String | ConvertFrom-Json -ErrorAction Stop 
                    $ValidJson = $True
                } catch{ $ValidJson = $False}
            
                if ($ValidJson){
                Invoke-WebRequest @RequestValues -Body $Body
                } else { Write-Host "No handing switches were provided and `r`n a Valid JSON string was not supplied. `r`n"
                    if($Combined.count > $body.count){$Body = $Combined}
                      $Choice = Read-Host -Prompt $SwitchPrompt
                      Switch($Choice){
                        1 {Invoke-WebRequest @RequestValues -Body $($Body | ConvertTo-Json)}
                        2 {Write-Host "$($Body| ConvertTo-Json)"}
                        3 {Continue}
                        4 {Break}
                      }
                 }
            }
        }
    }
}



function Get-MostRecentErrorEvents ([int]$Number,[switch]$Group){
        
        $Logs = "Application","Security","System" | ForEach-Object { 
        Get-Eventlog -Newest $number -LogName $_  -EntryType Error
        } | Sort-Object -Property Time -Descending | Select-Object -First $number | Select `
        @{name="EntryType";e={$([enum]::GetName([System.Diagnostics.EventLogEntryType],$_.EntryType))}},`
        Source, @{Name="Time Generated"; Expression={$_.TimeGenerated.ToString("yyyy-MM-ddTHH:mm:ss")}},EventID,Message

      if($Group){
        $Logs | Group-Object -Property Source 
        
        }else{
        $Logs | ConvertTo-Json
        }
         

}


function Get-MostRecentEventLogs ($Number) {

"Application","Security","System" | ForEach-Object { 
Get-Eventlog -Newest $number -LogName $_ 
} | Sort-Object -Property Time -Descending | Select-Object -First $number | Select `
@{name="EntryType";e={$([enum]::GetName([System.Diagnostics.EventLogEntryType],$_.EntryType))}},`
EventID,Message,Source, @{Name="Time Generated"; Expression={$_.TimeGenerated.ToString("yyyy-MM-ddTHH:mm:ss")}} | ConvertTo-Json
}




function Get-BIOSInfo{
Get-WMIObject -class Win32_BIOS | Select SMBIOSBIOSVersion, Manufacturer, Name, SerialNumber | ConvertTo-Json
}

function Get-DriveInfo {
Get-CimInstance -ClassName Win32_LogicalDisk |` 
        Select @{n="DriveLetter";e={$_.DeviceID}},DriveType,ProviderName,VolumeName,`
        @{n="Capacity";e={"$([Math]::Round($_.Size/1GB,2)) GB"}},`
        @{n="FreeSpace";e={"$([Math]::Round($_.freespace/1GB,2)) GB"}}`
        | ConvertTo-Json


}


function Get-ProcessInfo {

Get-Process | Group-Object -Property ProcessName |

              Select @{n="Name";e={$_.Name}},
                     @{n="Instances";e={$_.Count}},
                     @{n="R";e={($_.Group|? Responding -eq $true).count}},
                     @{n="U";e={($_.Group|? Responding -eq $false).count}},
                     @{n="Description";e={($_.Group|Select Description -First 1).Description}},
                     @{n="AvgUpTime(H)";e={Measure-Round -Num ((($_.Group|Select StartTime | %{Measure-TimeSpan -Date $_.StartTime}).TotalHours | Measure-Object -Average).Average)}},
                     @{n = "WS(MB)"; e = {[MATH]::ROUND(($_.Group|Measure-Object WorkingSet -sum).sum / 1MB , 2) }}|
              Sort-Object -Property "Instances" -Descending 

}

function Get-NetworkAdapterInfo {
Get-NetAdapter | Select Status,LinkSpeed,MacAddress,@{n="ProfileName";e={$_.Name}} | ConvertTo-Json
}

function Get-ActiveTCP([switch]$GroupItems){


$connections = Get-NetTCPConnection | where {($_.AppliedSetting -eq "Internet") -and ($_.RemoteAddress -cnotlike "127.0.*")} | Select RemoteAddress, LocalPort, RemotePort,`
@{n="State";e={$([Enum]::GetName([Microsoft.PowerShell.Cmdletization.GeneratedTypes.NetTCPConnection.State],($_.PSBase.CimInstanceProperties['State'].Value)))}},`
@{n="OwningProcess";e={$(Get-Process -Id $_.OwningProcess).Name}},
@{n="PID";e={$_.OwningProcess}}


if($GroupItems){
$connections | Group-Object -Property OwningProcess | Sort-Object -Property Count -Descending 

}
else{
$connections | ConvertTo-Json
}

}

function Get-NetworkTotalTraffic {
Get-NetAdapterStatistics | select @{n="Received(GB)";e={[MATH]::Round($_.ReceivedBytes /1GB,2)}},@{n="Sent(GB)";e={[MATH]::Round($_.SentBytes /1GB,2)}} | ConvertTo-Json

}


function Get-FilesLastModified ($minutes, $numberofFiles, $filepath) {
Get-ChildItem -erroraction SilentlyContinue -Path $filepath -Recurse |`
 ? {$_.LastWriteTIme -gt [datetime]::Now.AddMinutes($minutes)} |`
 Sort-Object -Descending LastWriteTime | Select -first $numberoffiles |`
 Select @{Name="Last Write Time"; Expression={$_.LastWriteTime.DateTime}}, FullName | Group-Object -Property "Last Write Time"
}



function Get-LocalUsers {
Get-LocalUser | Select Name,@{n="sid";e={($_.SID).value}} | ConvertTo-Json
}


function Get-RDPSessions($serverNames){
if(!($serverNames)){
$serverNames = "localhost"}
foreach ($servername in $servernames){
$session = qwinsta /server:$ServerName | foreach { (($_.trim() -replace "\s+",","))} | Convertfrom-csv
$session | Add-Member -MemberType NoteProperty -Name Server -Value $servername
$allSessions += $session
}
$allSessions | group -property "server"
}


function Get-TitledWindows {

Get-Process | Where {$_.MainWindowTitle} | Select-Object ProcessName, MainWindowTitle

}




function Start-HostNetMonitor {
   param(
   #IP, URL, Hostname.
   [parameter(Mandatory=$true)]
   $target,
   #Sleep time between pings, in seconds.
   [parameter(Mandatory=$true)]
   [INT]$sleepSeconds,
   #Where to send the log, uses temp directory if none supplied.
   $logPath,
   #Specific port to monitor
   $port
   )


Class PingResult 
{
    [DateTime]$DateTime
    [int]$latency
    [string]$targetIP
    [string]$targetPort
    [String]$Outcome


}


$global:ProgressPreference = 'SilentlyContinue'
if ($logPath -eq $null){
  $logPath = "$env:TEMP\HostMonitorLog$(Get-Date -Format "yyyy-MM-d-HHmm").txt"
  Write-Host "No Logpath provided, writing log to $logPath"
  
  }

While ($true){


if ($PSBoundParameters.ContainsKey('port')){
$WarningPreference 
$Ping = Test-NetConnection -Port $port -ComputerName $target -WarningAction Ignore
    if ($Ping.TcpTestSucceeded -eq $true){
    $result = New-Object PingResult
    $result.DateTime = Get-Date -Format s
    $result.latency = $((Test-NetConnection -ComputerName $target -InformationAction SilentlyContinue).PingReplyDetails.RoundtripTime)
    $result.Outcome = $ping.TcpTestSucceeded
    $result.targetIP = $ping.RemoteAddress
    $result.targetPort = $ping.RemotePort

    $result | ft -HideTableHeaders
    $str = "$($result.DateTime),$($result.targetIP),$($result.targetPort),$($result.latency),Success"
    }else{$str = "[$(Get-Date -Format s)], $($Ping.RemoteAddress):$($Ping.RemotePort), NAN Failed`r" }
    }

else { 
$ping = Test-NetConnection -ComputerName $target 

$result = New-Object PingResult
    $result.DateTime = Get-Date -Format s
    $result.latency = $ping.PingReplyDetails.RoundtripTime
    $result.Outcome = $ping.TcpTestSucceeded
    $result.targetIP = $ping.RemoteAddress
    $result.targetPort = $ping.RemotePort


    $str = "[$(Get-Date -Format s)], $($Ping.RemoteAddress), $(($ping.PingReplyDetails).RoundtripTime)ms, $(($ping.PingReplyDetails).Status)`r"

}

if($ping.PingReplyDetails.Status -eq "Success" -or $Ping.TcpTestSucceeded -eq $true) {
Write-Host $str -BackgroundColor DarkGreen -ForegroundColor White
}
else{
Write-Host $str -BackgroundColor Red -ForegroundColor White
}

$message = @{"msg" = $str} | ConvertTo-Json


 $RequestValues = @{
    Method = "Post"
    ContentType = "application/json; charset=UTF-8"
    URI = "https://geezus.net:3000/stream"
    Body = $message
 }

Invoke-WebRequest @RequestValues 
Add-Content -Value $str -Path $logPath

Start-Sleep -Seconds $sleepSeconds

}}



#  ███╗   ███╗███████╗██╗     ██╗███████╗███████╗ █████╗          
#  ████╗ ████║██╔════╝██║     ██║██╔════╝██╔════╝██╔══██╗         
#  ██╔████╔██║█████╗  ██║     ██║███████╗███████╗███████║         
#  ██║╚██╔╝██║██╔══╝  ██║     ██║╚════██║╚════██║██╔══██║         
#  ██║ ╚═╝ ██║███████╗███████╗██║███████║███████║██║  ██║         
#  ╚═╝     ╚═╝╚══════╝╚══════╝╚═╝╚══════╝╚══════╝╚═╝  ╚═╝         
#                                                                 
#   ██████╗ ██████╗ ███╗   ██╗████████╗██████╗ ██╗██████╗ ███████╗
#  ██╔════╝██╔═══██╗████╗  ██║╚══██╔══╝██╔══██╗██║██╔══██╗██╔════╝
#  ██║     ██║   ██║██╔██╗ ██║   ██║   ██████╔╝██║██████╔╝███████╗
#  ██║     ██║   ██║██║╚██╗██║   ██║   ██╔══██╗██║██╔══██╗╚════██║
#  ╚██████╗╚██████╔╝██║ ╚████║   ██║   ██║  ██║██║██████╔╝███████║
#   ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═════╝ ╚══════╝
#                                                                 
#     ____      .-'''-..---.  .---.            .-```-.             .-------.     ___    _.-./`),---.   .--. 
#   .'  __ `.  / _     |   |  |_ _|           /   _   \            |  _ _   \  .'   |  | \ .-.'|    \  |  | 
#  /   '  \  \(`' )/`--|   |  ( ' )          |  .` '\__|           | ( ' )  |  |   .'  | / `-' |  ,  \ |  | 
#  |___|  /  (_ o _).  |   '-(_{;}_)          \  `--.              |(_ o _) /  .'  '_  | |`-'`"|  |\_ \|  | 
#     _.-`   |(_,_). '.|      (_,_)          /' ..--`.----.        | (_,_).' __'   ( \.-.|.---.|  _( )_\  | 
#  .'   _    .---.  \  | _ _--.   |         :  `     ' ___|        |  |\ \  |  ' (`. _` /||   || (_ o _)  | 
#  |  _( )_  \    `-'  |( ' ) |   |         |   `..-'_( )_         |  | \ `'   | (_ (_) _)|   ||  (_,_)\  | 
#  \ (_ o _) /\       /(_{;}_)|   |          \      (_ o _)        |  |  \    / \ /  . \ /|   ||  |    |  | 
#   '.(_,_).'  `-...-' '(_,_) '---'           `-.__..(_,_)         ''-'   `'-'   ``-'`-'' '---''--'    '--' 
#                                                                                                           

function Get-MostRecentServices {
    [CmdletBinding()]
    param (
        [string]$Name,
        [int]$Number
    )   
    $Params = @{}
    if ($PSBoundParameters.Name) {
        $Params.Filter = "Name = '$Name'"
    }
    if (!($PSBoundParameters.Number)){
        $Number = 25
    }
    $Services = Get-CimInstance -ClassName Win32_Service @Params
    $Output = foreach ($Service in $Services) {
        $Process = Get-Process -Id $Service.ProcessId
        [pscustomobject]@{
            
            Name = $Service.Name
            DisplayName = $Service.DisplayName
		    Status = $Service.State
            StartTime = $Process.StartTime.DateTime
       } | Where {$_.StartTime -ne $null} 
	}
	$Output | sort -property starttime | select -first $Number | convertto-json
}

#example:
#Get-MostRecentServices -Number 10 | send-toElma


function Get-MostRecentlyInstalledPrograms ($Number) {
    if(!($Number)){
        $Number = 25}
    "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" | 
    ForEach-Object {Get-ItemProperty $_} | Where-Object {$_.DisplayName -ne $null} |
    Sort-Object -Property InstallDate -Descending | Select-Object DisplayName, DisplayVersion, @{Name="InstallDate"; e={[datetime]::ParseExact($_.InstallDate,”yyyyMMdd”,$null).toshortdatestring()}} | Select-Object -First $number | ConvertTo-Json
}

#example:
#Get-MostRecentlyInstalledPrograms 20 | Send-ToElma


function Get-MostRecentRestarts ($Number) {
    if(!($Number)){
        $Number = 25}
	$xml=@'
	<QueryList>
		<Query Id="0" Path="System">
			<Select Path="System">*[System[(EventID=1074)]]</Select>
		</Query>
	</QueryList>
'@
	Get-WinEvent -FilterXml $xml -MaxEvents $Number | Select @{n="RestartTime"; e={$_.TimeCreated.DateTime}}, RecordID, @{n="UserSID"; e={$_.UserID.Value}}, @{n="UserName"; e={$(Get-localuser -sid $_.UserID.Value).name}}, Message | Group-Object -Property "UserSID"
}

#example:
#Get-MostRecentRestarts 10 | Send-ToElma -SendEach


function Get-StartupItems {
    Get-WMIObject Win32_StartupCommand | Select-Object -Property @{n="Startup Item Description"; e={$_.Description}}, Command, User, Location | ConvertTo-Json
}

#example:
#Get-StartupItems | Send-ToElma


function Get-FirewallRules {
	$Rules=(New-object -ComObject HNetCfg.FWPolicy2).rules
	$Rules |
	Where-Object {$_.enabled} |
	Sort-Object -Property direction |
	Select-Object -Property name, description, ApplicationName, ServiceName, Protocol, LocalPorts, RemotePorts, LocalAddresses, RemoteAddresses, ICMPType, Direction, Action | ConvertTo-Json
}

#example:
#Get-FirewallRules | Send-ToElma


function Get-Hotfixes {
	Get-HotFix | Select-Object -Property @{Name="Hotfix ID"; Expression={$_.hotfixID}}, @{Name="Installed By"; Expression={$_.InstalledBy}}, @{Name="Installed On"; Expression={$_.installedon.datetime}} | ConvertTo-Json
}

#example:
#Get-Hotfixes | Send-ToElma


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


function Get-DriverQuery {
    driverquery /fo csv | convertfrom-csv | group "driver type"
}

#example:
#Get-DriverQuery | Send-ToElma -SendEach


function Get-PendingWindowsUpdates{
    $updateSession = New-Object -ComObject Microsoft.Update.Session
    $updateSession.ClientApplicationID = 'MSDN Sample Script'
    $updateSearcher = $updateSession.CreateUpdateSearcher()
    $updateResults = $updateSearcher.Search('IsInstalled=0')
    $updateResults.updates | select Title,Description,IsDownloaded,IsHidden,IsInstalled,IsMandatory,@{n="Last Deployment Change Time";e={$_.LastDeploymentChangeTime.DateTime}},SupportUrl,RebootRequired | ConvertTo-Json
}

#example:
#Get-PendingWindowsUpdates | Send-ToElma


function Get-PowerScheme{
    Get-WmiObject -Namespace root\cimv2\power -Class win32_PowerPlan |Select-Object -Property ElementName, IsActive | ConvertTo-Json
}

#example:
#Get-PowerScheme | Send-ToElma


###Dependency: Win8/Server2k12 or later###

function Get-ScheduledTasks {
	Get-ScheduledTask | Where {$_.State -ne "Disabled"} | Select TaskName, Description, @{n="State";e={[Enum]::GetName([Microsoft.Powershell.Cmdletization.GeneratedTypes.ScheduledTask.StateEnum],($_.psbase.CimInstanceProperties['state'].value))}}, Date | ConvertTo-Json
}

#example:
#Get-ScheduledTasks | Send-ToElma


###Dependency: Active Directory###

function Get-MostRecentADUsersGrouped ($Number) {
    if(!($Number)){
        $Number = 25}
    $date = get-date
    $User = Get-ADUser -Filter 'objectclass -eq "User"' -Properties *
    $User | Where-Object {$_.whenCreated -gt $date.adddays(-30) -and ($_.LastLogonDate -ne $null)} | Select-Object  -last $Number |
    Sort-Object -Descending -Property LastLogonDate |
    Select @{n="Created"; e={$_.whenCreated.DateTime}},@{n="Last Logon Date"; e={$_.LastLogonDate.DateTime}},Enabled,@{n="SID"; e={$_.SID.Value}},Name,Samaccountname | Group-Object -Property "Name"
}

#example:
#Get-MostRecentADUsersGrouped 10 | Send-ToElma -SendEach


function Get-AllGPOForDomain($domainName){
    Get-GPO -All -Domain $domainName | Select DisplayName, DomainName, Owner, ID, GpoStatus, @{n="Creation Time";e={$_.CreationTime.DateTime}}, @{n="Modification Time";e={$_.ModificationTime.DateTime}}, @{n="User DS Version";e={$_.User.DSVersion}}, @{n="User Sysvol Version";e={$_.User.Sysvolversion}} | ConvertTo-Json
}

#example:
#Get-AllGPOForDomain phoenix.caw | Send-ToElma


function Get-DNSRecords ($DNSServerName, $DomainName) {
    $DomainFilter = "DomainName = '" + $DomainName + "'"
    Get-WmiObject -Class MicrosoftDNS_AType -NameSpace Root\MicrosoftDNS -ComputerName $DNSServerName -filter $DomainFilter | select -property IPAddress, OwnerName, @{n="Timestamp";e={(([datetime]"1.1.1601").AddHours($_.Timestamp)).datetime}}, ttl | convertto-json
}

#example:
#Get-DNSRecords -DNSServerName "ASHANDRUIN" -DomainName 'phoenix.caw' | Send-ToElma


###Dependency: Hyper-V###

function Get-HyperVBasics {
	Get-VM * | Select VMName, State, Status, Path, ProcessorCount, MemoryStartup, Generation | ConvertTo-Json
}

#example:        
#Get-HyperVBasics | Send-ToElma


function Get-HyperVReplication {
	Get-VM * | Select VMName, State, Status, ReplicationState, ReplicationHealth  | ConvertTo-Json
}

#example:
#Get-HyperVReplication | Send-ToElma


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

function Do-TooManyOfTheThings {
        Get-RAIDPhysicalInfoFromOMSA | Send-ToElma
        Get-RAIDVirtualInfoFromOMSA | Send-ToElma
        Get-ActiveTCP | Send-ToElma
        Get-DriveInfo | Send-ToElma
        Get-LocalUsers | Send-ToElma
        Get-NetworkAdapterInfo | Send-ToElma
        Get-NetworkTotalTraffic | Send-ToElma
        Get-ProcessInfo | Send-ToElma
        Get-BIOSInfo | Send-ToElma
        Get-FanSpeed | Send-ToElma
        Get-HyperVReplication | Send-ToElma
        Get-HyperVBasics | Send-ToElma
        Get-FirewallRules | Send-ToElma
        Get-Hotfixes | Send-ToElma
        Get-ScheduledTasks | Send-ToElma
        Get-MostRecentEventLogs 10 | Send-ToElma
        Get-StartupItems | Send-ToElma
        Get-MostRecentADUsersGrouped 30 | Send-ToElma -SendEach
        Get-MostRecentRestarts 30 | Send-ToElma -SendEach
        Get-MostRecentServices -number 10 | Send-ToElma
        Get-FilesLastModified -minutes "-3600" -numberOfFiles 0 -filePath "C:\\*.*" | Send-ToElma -SendEach
        Get-RDPSessions "phoenix-hv1","phoenix-mabs","ashandruin","boxensocks" | Send-ToElma -SendEach
        Get-DriverQuery | Send-ToElma -SendEach
    }

function Do-TooManyOfTheThingsInWin7 {
        Get-DriveInfo | Send-ToElma
        Get-LocalUsers | Send-ToElma
        Get-ProcessInfo | Send-ToElma
        Get-BIOSInfo | Send-ToElma
        Get-FirewallRules | Send-ToElma
        Get-Hotfixes | Send-ToElma
        Get-MostRecentEventLogs 10 | Send-ToElma
        Get-StartupItems | Send-ToElma
        Get-MostRecentADUsersGrouped 30 | Send-ToElma -SendEach
        Get-MostRecentRestarts 30 | Send-ToElma -SendEach
        Get-MostRecentServices -number 10 | Send-ToElma
        Get-FilesLastModified -minutes "-3600" -numberOfFiles 0 -filePath "C:\\*.*" | Send-ToElma -SendEach
        Get-RDPSessions "phoenix-hv1","phoenix-mabs","ashandruin","boxensocks" | Send-ToElma -SendEach
        Get-DriverQuery | Send-ToElma -SendEach
    }


#  ██╗  ██╗███████╗██╗     ██████╗ ███████╗██████╗                           
#  ██║  ██║██╔════╝██║     ██╔══██╗██╔════╝██╔══██╗                          
#  ███████║█████╗  ██║     ██████╔╝█████╗  ██████╔╝                          
#  ██╔══██║██╔══╝  ██║     ██╔═══╝ ██╔══╝  ██╔══██╗                          
#  ██║  ██║███████╗███████╗██║     ███████╗██║  ██║                          
#  ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚══════╝╚═╝  ╚═╝                          
#  ███████╗██╗   ██╗███╗   ██╗ ██████╗████████╗██╗ ██████╗ ███╗   ██╗███████╗
#  ██╔════╝██║   ██║████╗  ██║██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
#  █████╗  ██║   ██║██╔██╗ ██║██║        ██║   ██║██║   ██║██╔██╗ ██║███████╗
#  ██╔══╝  ██║   ██║██║╚██╗██║██║        ██║   ██║██║   ██║██║╚██╗██║╚════██║
#  ██║     ╚██████╔╝██║ ╚████║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║███████║
#  ╚═╝      ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝
                                                                          

function Measure-TimeSpan ([DateTime]$Date){
(Get-Date).Subtract($Date)
}

function Measure-Round([decimal]$Num){
[Math]::Round($Num,2)
}


function Do-allTheThings {

Param($port = 3000)


Get-ActiveTCP | Send-ToElma -port $port
Get-DriveInfo | Send-ToElma -port $port
Get-LocalUsers | Send-ToElma -port $port
Get-NetworkAdapterInfo | Send-ToElma -port $port
Get-NetworkTotalTraffic | Send-ToElma -port $port
Get-ProcessInfo | ConvertTo-Json | Send-ToElma -port $port
Get-RDPSessions | Send-ToElma -SendEach -port $port
Get-TitledWindows | ConvertTo-Json | Send-ToElma -port $port
}
