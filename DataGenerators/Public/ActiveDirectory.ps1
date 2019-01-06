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
