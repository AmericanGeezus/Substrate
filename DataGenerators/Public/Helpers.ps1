

function Measure-TimeSpan ([DateTime]$Date){
(Get-Date).Subtract($Date)
}

function Measure-Round([decimal]$Num){
[Math]::Round($Num,2)
}
