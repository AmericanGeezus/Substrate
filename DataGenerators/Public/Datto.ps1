###Dependency: Datto Windows Agent

function Get-DattoWindowsAgentLogs($logDate){
    if(!($logDate)){
        $logDate = (Get-Date -format "yyyy-MM-dd")}
    else{
        $logDate = [datetime]::ParseExact($logDate,'yyyy-MM-dd',$null)
        $logDate = $logDate.ToString("yyyy-MM-dd")}
	foreach ($line in (Get-Content ("C:\Windows\System32\config\systemprofile\AppData\Local\Datto\Datto Windows Agent\logs\dba_" + $logDate + ".log"))){
			[pscustomobject]@{
			    DateTime = ($line.substring(0,23))
                MessageType = ($line.substring(($line.indexof("[")+1),$line.indexof("]") - ($line.indexof("[")+2)))
                Message = ($line.substring(36,($line.length - 36)))
       			} 
	}
}

#example:
#Get-DattoWindowsAgentLogs 2019-01-21 | Select -Last 10 | ConvertTo-Json | Send-ToElma
