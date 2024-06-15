##############################################################################
#****************************************************************************#
# Author	: sohxuanwei88@gmail.com				     #
# Purpose	: This script launches PuTTY with customized UI elements     #
# 	   	  by loading a customized registry key which creates a new   #
#	   	  profile in PuTTY. 					     #
#		  Also cleans up the registry key & REG file created after   #
#		  3 seconds - to keep things neato.			     #
# Version	: 1.0							     #
# Last Modified	: 2024-06-15						     #
# Usage		: Powershell.exe -ExecutionPolicy Bypass -File 		     #
#		  ./LaunchSesh.ps1 "GreenSesh" "bob@192.168.1.1" "22"	     #
#****************************************************************************#
##############################################################################

# This script should take 3 arguments
# arg1 - Session Type: Green or Red Session
# arg2 - hostname@address of the target destination
# arg3 - destination port [optional]

param (
    [string]$seshName,
    [string]$hostName,
    [string]$destPort
)

# Function to check if a parameter is empty
function Is-Empty {
    param (
        [string]$value
    )
    return [string]::IsNullOrEmpty($value)
}

# Verify if the REG file is Red or Green
$filePath = ".\$seshName.reg"
if (Test-Path $filePath) {
	
	# Verify if the hostName parameter is empty
	if (Is-Empty $hostName) {
		Write-Output "Error: hostName parameter is not provided"
		exit 1
	}
	
	# Verify if the destPort parameter is empty - if true, set port 22 as default
	if (Is-Empty $destPort) {
		Write-Output "Warning: destPort parameter not provided - using port 22 as the default SSH port"
		$destPort = "22"
	}
	
	# Get the Current Timestamp
	$currentTimeStamp = Get-Date
	$timeStamp = $currentTimeStamp.ToString("yyyy-MM-dd_HH.mm.ss")
	Write-Output "Timestamp value		: $timeStamp"
	
	# Create new REG file based on Session Type, Hostname, and Timestamp
	$newSeshName = "$seshName---$hostName---$timeStamp"
	Write-Output "New Session Name value	: $newSeshName"
	Copy-Item -Path "./$seshName.reg" -Destination "./$newSeshName.reg"
	
	$content = Get-Content -Path "./$newSeshName.reg"
	
	# Modify REG file with the new seshName
	$newContentWithNewSeshName = $content -replace "$seshName","$newSeshName"
	
	# Modify REG file with hostname@address provided
	$newContentWithNewHostName= $newContentWithNewSeshName -replace "placeholder@192.168.10.88","$hostName"
	
	# Modify REG file with destination port provided
	
	# Set the new REG file with the new content
	Set-Content -Path "./$newSeshName.reg" -Value $newContentWithNewHostName
	
	# Load the REG file to Registry
	reg import "$newSeshName.reg"

	# Launch PuTTY connection via PuTTY saved Session
	putty.exe -load $newSeshName
	
	# Wait for 3 seconds, clean up the file created and the registry key
	Start-Sleep 3
	$delKeyPath = "HKCU:/SOFTWARE/SimonTatham/PuTTY/Sessions/$newSeshName"
	$delFilePath = "./$newSeshName.reg"
	
	# Check if the registry key exists before attempting to remove it
	if (Test-Path $delKeyPath) {
	    # Remove the registry key and all its subkeys recursively
	    Remove-Item -Path $delKeyPath -Recurse -Force
	    Write-Output "Registry key '$delKeyPath' and all its subkeys have been successfully removed."
	} else {
	    Write-Output "Warning: Registry key '$delKeyPath' does not exist."
	}
	
	# Check if the file exists before attempting to remove it
	if (Test-Path $delFilePath) {
	    # Remove the registry key and all its subkeys recursively
	    Remove-Item -Path $delFilePath -Recurse -Force
	    Write-Output "REG file '$delFilePath' has been successfully removed."
	} else {
	    Write-Output "Warning: REG file '$delFilePath' does not exist."
	}
	
} else {
	Write-Host "Error: Registry File not found for $seshName.reg"
	exit 1
}

