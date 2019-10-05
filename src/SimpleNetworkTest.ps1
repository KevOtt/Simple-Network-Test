# Copyright (c) 2019 Kevin Ott
# Licensed under the MIT License
# See the LICENSE file in the project root for more information.

<# 
.SYNOPSIS
	Tests TCP communication and DNS resolution for servers noted in a config file.
.DESCRIPTION
    Tests DNS resolution and tcp communication ability for specific ports and ips
    as listed in an associated txt configuration file.  The config file specifies device name,
    IP, expected communication ports, and a description field.  The script then
    runs a name lookup and compares it with the specified IP and attempts to open a tcp 
    connection for each specified port to the specified IP.  Results are recorded and output 
    via a write-output to make output pipe-able.
.EXAMPLE
	& .\'SimpleNetworkTest.ps1' -ConfigFile "C:\example\config.txt"
.PARAMETER ConfigFile
    Provide an alternate location and/or name for the configuration file.
    By default the script looks in its executing directory for a file called
    TestTCPCommunication_Config.txt
.NOTES
    Filename: SimpleNetworkTest
    Version: 1.1.0
    Date: 10/4/2019
    Author: Kevin Ott
.LINK
#> 

param(
    [string]$ConfigFile = ''
    )


#region Setup

# Load assembly for .NET tcp client class
TRY{
    [System.Reflection.Assembly]::LoadWithPartialName("System.Net.Sockets") | Out-Null
    }
CATCH{
    throw 'Failed to load files for System.Net.Sockets.'
    }

#endregion


#region LoadConfigFile

# If no config file specified, use the working directory or ISE path if in ISE.
if($ConfigFile -eq ''){
    if($psISE -eq $null){
        $ConfigFile = ((Split-Path -Parent $MyInvocation.MyCommand.Path) + "\SimpleNetworkTest_Config.txt")
    }
    else{
        $ConfigFile = ((Split-Path -Parent $psISE.CurrentFile.FullPath) + "\SimpleNetworkTest_Config.txt")
    }
}

# Test for config file path
if((Test-Path $ConfigFile) -ne $true){
    throw 'Config file not found, supply in script directory or specify valid altnernate path'
}

# Get content from config file
$Servers = @()
Get-Content $ConfigFile | ForEach-Object{
    if($_[0] -ne "#" -and $_ -ne ''){
        $c = $_ -replace ' ',''
        $entry = $c.split(";")
        $Servers+= (New-Object -TypeName PSObject -Property ([ordered]@{'ServerName'=$entry[1];'ServerIP'=$entry[2];`
        'Server Description'=$entry[0];'ServerPorts'=$entry[3];'DNSResolution'="";'FailedConnection'="";'SuccessfulConnection'=""}))
    }
}

#endregion



# Loop through servers in config file
Write-Host "Checking Ports...`n`n"
$Servers | ForEach-Object{
    $serverIP = ($_.ServerIP).trim()
    $failed = ''
    $success = ''

    # Test DNS resolution 
    $resIP = $null
    TRY{$resIP = ([System.Net.Dns]::gethostaddresses(($_.ServerName).trim()).IPAddressToString)}
    CATCH [System.Management.Automation.MethodInvocationException]{<# Could write to error log here, just supressing for now#>}

    # Compare resolved IPs to provided and output results back to object
    if($null -eq $resIP){
        $_.DNSResolution = 'Failed to resolve'
        }
    elseif($resIP -ne $_.ServerIP){
        $_.DNSResolution = 'Resolved to Incorrect IPs'
        }
    else {
        $_.DNSResolution = 'Success'
        }

    # Loop through each port for each server and tests communication
    $failed = $success = @()
    $_.ServerPorts.split(',') | ForEach-Object{
        $port = $_.trim()
        # Construct .NET class object
        $tcpconnection = New-Object System.Net.Sockets.TcpClient
        # Attempt to create tcp connection and ignore failures
        TRY{
            $tcpconnection.Connect($serverIP,$port)
            }
        CATCH [ArgumentOutOfRangeException]{Write-Warning "$port is outside of the range of acceptable port values"}
        CATCH{}

        # Format and output results

        if($tcpconnection.Connected -ne $true){
            $failed += $port
        }
        else{
            $success += $port
            }
        # Close any open tcp connection
        $tcpconnection.Close()
        }
    # Record output back to object
    $_.FailedConnection = $failed -join ','
    $_.SuccessfulConnection = $success -join ','
    }


# Output object array
Write-Output $Servers | Format-Table
