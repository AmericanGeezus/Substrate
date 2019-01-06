#System Functions


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
$cmd = "qwinsta /server:" + $ServerName + " 2>`$null"
        $session = invoke-expression -erroraction silentlycontinue $cmd | foreach { (($_.trim() -replace "\s+",","))} | Convertfrom-csv
$session | Add-Member -MemberType NoteProperty -Name Server -Value $servername
$allSessions += $session
}
$allSessions | group -property "server"
}


function Get-TitledWindows {

Get-Process | Where {$_.MainWindowTitle} | Select-Object ProcessName, MainWindowTitle

}


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



function Get-Hotfixes {
	Get-HotFix | Select-Object -Property @{Name="Hotfix ID"; Expression={$_.hotfixID}}, @{Name="Installed By"; Expression={$_.InstalledBy}}, @{Name="Installed On"; Expression={$_.installedon.datetime}} | ConvertTo-Json
}

#example:
#Get-Hotfixes | Send-ToElma



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
	Get-HyperVNetworkTraffic "PHOENIX-HV1" 2 5 | Send-ToElma -SendEach
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
