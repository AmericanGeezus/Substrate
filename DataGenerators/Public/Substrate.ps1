#Substrate Specific

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

        [parameter(ValueFromPipeline = $true)]
        [string]$string,
        [parameter(ValueFromPipeline = $true)]
        [object]$body,
        [parameter(ValueFromPipeline = $true)]
        [Microsoft.PowerShell.Commands.GroupInfo]
        $group,
        [parameter(ValueFromPipeline = $false)]
        [Switch]$Convert,
        [parameter(ValueFromPipeline = $false)]
        [Switch]$SendEach,
        $port = 3000
    )
    begin {
        $SwitchPrompt = @"
    1 - Attempt to convert and send object.
    2 - Attempt to convert, but do not send.
    3 - Continue processing any remaining items in the pipe.
    4 - Break pipeline, send nothing.
"@


        $RequestValues = @{
            Method      = "Post"
            ContentType = "application/json; charset=UTF-8"
            URI         = "https://geezus.net:$($port)/push"
        }



        $Combined = @()

    }

    process {


        if ($SendEach) {

            $BodyJson = ($Group.Group | ConvertTo-Json).replace("null", '""')
            Invoke-WebRequest @RequestValues -Body $BodyJson
        }
        else {
            $CurrentItem = $_
            $Combined += $CurrentItem.group
        }
    }

    end {


        if ($SendEach) {
            Continue
        }
        else {
            if ($Convert) {
                Invoke-WebRequest @RequestValues -Body $(($Combined | ConvertTo-Json).replace("null",'""'))
            }
            else {

                try {
                    $BodyTest = $Body | ConvertFrom-Json -ErrorAction Stop
                    $ValidJson = $True
                }
                catch { $ValidJson = $False }
                try {
                    $BodyTest = $String | ConvertFrom-Json -ErrorAction Stop
                    $ValidJson = $True
                }
                catch { $ValidJson = $False }

                if ($ValidJson) {
                    Invoke-WebRequest @RequestValues -Body $($Body -replace "null",'""')
                }
                else {
                    Write-Output "No handing switches were provided and `r`n a Valid JSON string was not supplied. `r`n"
                    if ($Combined.count -gt $Body.count) { $Body = $Combined }
                    $Choice = Read-Host -Prompt $SwitchPrompt
                    Switch ($Choice) {
                        1 { Invoke-WebRequest @RequestValues -Body $(($Body | ConvertTo-Json).replace("null",'""')) }
                        2 { Write-Output "$($Body| ConvertTo-Json)" }
                        3 { Continue }
                        4 { Break }
                    }
                }
            }
        }
    }
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
    Get-RDPSessions "phoenix-hv1", "phoenix-mabs", "ashandruin", "boxensocks" | Send-ToElma -SendEach
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
    Get-RDPSessions "phoenix-hv1", "phoenix-mabs", "ashandruin", "boxensocks" | Send-ToElma -SendEach
    Get-DriverQuery | Send-ToElma -SendEach
}
