###Dependency: MS Azure Backup Server Data Protection Manager + Management Shell

function Get-AllDPMJobs($GroupBy,$DPMServer){
    if (!($GroupBy)){$GroupBy = "JobType"}
    if (!($DPMServer)){$DPMServer = $env:computername + "." + (Get-WmiObject Win32_ComputerSystem).Domain}
	Get-DPMJob -DPMServerName $DPMServer -From (Get-Date).AddDays(-30) -To (Get-Date) -AllJobsInInterval -NoLimitOnJobCount | 
	Select @{n="Duration";e={(New-Timespan -Start $_.StartTime -End $_.EndTime).ToString()}}, 
	@{n="Status";e={($_.Status).ToString()}},
	@{n="JobType";e={($_.JobType).ToString()}},
	@{n="StartTime";e={($_.StartTime).ToString()}},
	DataSources | Group $GroupBy
}

#example:
#Get-AllDPMJobs -GroupBy Status -DPMServer PHOENIX-MABS.phoenix.caw | Send-ToElma -SendEach

function Get-DPMVolumeDatasource($GroupBy,$DPMServer){
    if (!($GroupBy)){$GroupBy = "Name"}
    if (!($DPMServer)){$DPMServer = $env:computername + "." + (Get-WmiObject Win32_ComputerSystem).Domain}
    Get-DPMVolume -AlreadyInUseByDPM -DPMServerName $DPMServer | 
    Select @{n="Computer";e={$_.ContainedDataSources.Computer}},
    @{n="Name";e={$_.ContainedDataSources.Name}},
    @{n="Type";e={$_.ContainedDataSources.ObjectType}},
    VolumeLabel,VolumeSetID,
    @{n="VolumeType";e={($_.VolumeType).ToString()}},
    @{n="Capacity";e={"$([Math]::Round($_.TotalSpace/1GB,2)) GB"}}, 
    @{n="FreeSpace";e={"$([Math]::Round($_.unusedspace/1GB,2)) GB"}} | 
    Group $GroupBy
}

#example:
#Get-DPMVolumeDatasource -GroupBy ContainedDataSourceComputer -DPMServer PHOENIX-MABS.phoenix.caw | Send-ToElma -SendEach
