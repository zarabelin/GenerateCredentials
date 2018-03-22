<#
.SYNOPSIS
    Creates Credential file for later use.

.INPUTS
    Config json & customer json

.OUTPUTS
    Credential file.

.PARAMETER ConfigJson
    Path to JSON config file with installation details. Or manual entry.

.EXAMPLE
    .\Generate-Cred.ps1 -ConfigJson .\configjson.json -passwordjson .\password.json

.NOTES
    CREATE DATE:    2018-03-19
    CREATE AUTHOR:  Zackery Schwermer
    Dependencies:
        *Config Json
        *Password Json
    REV NOTES:
        Version 1.0
            Creates files based on configjson and password json.
            Creates files without jason information.
        
#>

param 
(
    # Specifies a path to one or more locations.
    [Parameter(Mandatory=$False)]
    [String]$ConfigJson,
    [Parameter(Mandatory=$False)]
    [String]$PasswordJson
)
# helper to turn PSCustomObject into a list of key/value pairs


#Pulling Json config and converting it to an object.
if ($CustomerConfigJson) {$CustomerConfigJson = Get-Content -Raw -Path $ConfigJson | ConvertFrom-Json }
#Pulling Json password config and converting it to an object.
if ($PasswordJson) {$CustomerPasswordJson = Get-Content -Raw -Path $PasswordJson | ConvertFrom-Json}

#Setting bin path.
if ($CustomerConfigJson) {
    $BinPath = $env:HOMEDRIVE + $CustomerConfigJson.BinDirectory
}
else {
    $BinPath = Read-host -Prompt "What is your BinPath E.G. C:\allegbin"
}
 

#Crating bin if it doesn't exist.
if (!(Test-Path $BinPath)) { 
    write-host "Creating $BinPath" -ForegroundColor Green -BackgroundColor Black
    New-Item -ItemType Directory -Force -Path $BinPath | Out-Null
} else {
    write-host "$BinPath already exists!!" -ForegroundColor Green -BackgroundColor Black
}

#Testing for Credentials folder and creating it.
$Folder = "$BinPath\Credentials"
if (!(Test-Path $Folder)) { 
    write-host "Creating $Folder" -ForegroundColor Green -BackgroundColor Black
    New-Item -ItemType Directory -Force -Path $Folder | Out-Null
} else {
    write-host "$Folder already exists!!" -ForegroundColor Green -BackgroundColor Black
}
Remove-Variable Folder

# Creating credential files
if ($PasswordJson) {
    foreach ($cred in $CustomerPasswordJson.Creds) {
        $OutFile = $null
        $secureStringPwd = $null
        $credential = $null
        $OutFile = "$BinPath\Credentials\$($CustomerConfigJson.CustomerShortName)_$($Cred.Name)_$($ENV:USERNAME)_$($ENV:COMPUTERNAME).cred"
        # Checking to see if file exists and creating it.
        if (!(Test-Path $OutFile)) {
            $secureStringPwd = $cred.pass | ConvertTo-SecureString -AsPlainText -Force
            $credential = New-Object -TypeName System.Management.Automation.PSCredential($cred.user, $secureStringPwd)
            $credential | Export-CliXml -Path $OutFile
            Write-Host "Credential file created: $OutFile" -ForegroundColor Green -BackgroundColor Black
        }
        else {
            write-host "$OutFile already exists!!" -ForegroundColor Red -BackgroundColor Black
        }

    }
}
else {
    $CustomerShortName = Read-Host -Prompt "What is the customershrotname E.G. abc"
    $CredName = Read-Host -Prompt "Credential Name E.G. relay"
    $OutFile = "$BinPath\Credentials\$($CustomerShortName)_$($CredName)_$($ENV:USERNAME)_$($ENV:COMPUTERNAME).cred"
    Get-Credential | export-clixml -path $OutFile
}