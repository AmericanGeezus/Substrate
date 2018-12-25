
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
    [Switch]$SendEach
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
    URI = "https://geezus.net:3000/foo"
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

function Do-allTheThings {
Get-ActiveTCP | Send-ToElma
Get-DriveInfo | Send-ToElma
Get-LocalUsers | Send-ToElma
Get-NetworkAdapterInfo | Send-ToElma
Get-NetworkTotalTraffic | Send-ToElma
Get-ProcessInfo | ConvertTo-Json | Send-ToElma
Get-RDPSessions | Send-ToElma -SendEach
Get-TitledWindows | ConvertTo-Json | Send-ToElma
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

