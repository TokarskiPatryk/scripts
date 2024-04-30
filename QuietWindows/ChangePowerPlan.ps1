### Find current power plan GUID

# Get the active power scheme
$output = powercfg /getactivescheme

# Use regex to extract the GUID
function GetGUID($output) {
    if ($output -match "Power Scheme GUID: ([a-f0-9\-]+)") {
        $guid = $matches[1]
        return $guid
    } else {
        return $null
    }
}

$guid = GetGUID $output
if ($null -eq $guid) {
    Write-Output "GUID not found"
    exit -1
}
Write-Output "Extracted GUID: $guid"


### Set the new power plan 
### to 99% so the CPU won't overclock

$output = powercfg /query $guid 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec
# Extract the current AC and DC power setting indexes
$currentACIndex = $output | Select-String -Pattern "Current AC Power Setting Index: (0x[0-9A-F]+)" | ForEach-Object { $_.Matches.Groups[1].Value }
$currentDCIndex = $output | Select-String -Pattern "Current DC Power Setting Index: (0x[0-9A-F]+)" | ForEach-Object { $_.Matches.Groups[1].Value }

# Convert the indexes to decimal
$currentACIndexDecimal = [convert]::ToInt32($currentACIndex, 16)
$currentDCIndexDecimal = [convert]::ToInt32($currentDCIndex, 16)

# Check if the indexes match 0x64 (100 in decimal)
if ($currentACIndexDecimal -eq 100 -and $currentDCIndexDecimal -eq 100) {
    Write-Output "Setting maximum processor state to 99%"
    Write-Output "-------------------------------------------------"
    Write-Output "CPU will not overclock and fans will be quieter"
    Write-Output "-------------------------------------------------"
    try {
        powercfg /SETACVALUEINDEX $guid 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 99
        powercfg /SETDCVALUEINDEX $guid 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 99
        Write-Output "Power plan updated successfully"
    } catch {
        Write-Output "Failed to update power plan"
    }
}

### else set it again to 100% so the CPU can overclock
else {
    Write-Output "Setting maximum processor state to 100%"
    Write-Output "-------------------------------------------------"
    Write-Output "CPU now CAN overclock and fans will be louder"
    Write-Output "-------------------------------------------------"
    try {
        powercfg /SETACVALUEINDEX $guid 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 100
        powercfg /SETDCVALUEINDEX $guid 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 100
        Write-Output "Power plan updated successfully"
    } catch {
        Write-Output "Failed to update power plan"
    }
}

### wait for any key
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
