
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


function Get-HyperVNetworkTraffic([string]$hv,[int]$SampleInterval,[int]$MaxSamples) {
    if(!($hv)){
        $hv = "localhost"}
	get-counter "Hyper-V Virtual Network Adapter(*)\packets/sec" -computername $hv -SampleInterval $SampleInterval -MaxSamples $MaxSamples | Select -expandproperty CounterSamples | Select @{Name="Timestamp";e={$_.Timestamp.DateTime}},InstanceName,CookedValue, @{Name="Counter";Expression={$_.Path.Split("\")[-1]}} | Group-Object -Property Timestamp
}

#example:
#Get-HyperVNetworkTraffic "PHOENIX-HV1" 2 5 | Send-ToElma -SendEach