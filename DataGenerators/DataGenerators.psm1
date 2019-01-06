$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)

Foreach ($import in @($Public)){

    try{
     . $import.fullname
    }
    Catch{
    Write-Error -Message "Failed to import function file $($import.fullname):$_"
    }


}