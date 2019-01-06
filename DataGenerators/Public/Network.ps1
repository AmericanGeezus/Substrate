
function Get-FirewallRules {
	$Rules=(New-object -ComObject HNetCfg.FWPolicy2).rules
	$Rules |
	Where-Object {$_.enabled} |
	Sort-Object -Property direction |
	Select-Object -Property name, description, ApplicationName, ServiceName, Protocol, LocalPorts, RemotePorts, LocalAddresses, RemoteAddresses, ICMPType, Direction, Action | ConvertTo-Json
}

#example:
#Get-FirewallRules | Send-ToElma

function Get-NetworkTotalTraffic {
Get-NetAdapterStatistics | select @{n="Received(GB)";e={[MATH]::Round($_.ReceivedBytes /1GB,2)}},@{n="Sent(GB)";e={[MATH]::Round($_.SentBytes /1GB,2)}} | ConvertTo-Json

}

#example:
#Get-NetworkTotalTraffic | Send-ToElma

function Get-NetworkAdapterInfo {
Get-NetAdapter | Select Status,LinkSpeed,MacAddress,@{n="ProfileName";e={$_.Name}} | ConvertTo-Json
}

#example:
#Get-NetworkAdapterInfo | Send-ToElma

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

#example:
#Get-ActiveTCP | Send-ToElma
#Get-ActiveTCP -group | Send-ToElma -sendeach
