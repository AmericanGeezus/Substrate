

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