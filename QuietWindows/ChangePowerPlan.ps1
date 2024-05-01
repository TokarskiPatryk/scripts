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

$plan100 = powercfg /list | Select-String -Pattern "100" | Select-Object -First 1
$guid100 = GetGUID $plan100
$plan99 = powercfg /list | Select-String -Pattern "99" | Select-Object -First 1
$guid99 = GetGUID $plan99

if ($null -eq $guid100) {
    Write-Output "Creating new power plan 100"
    $guid_string100 = powercfg /duplicatescheme $guid
    $guid100 = (GetGUID $guid_string100)
    # change name
    powercfg /changename $guid100 "100"

    # changing values for power plan 100
    try {
        powercfg /SETACVALUEINDEX $guid100 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 100
        powercfg /SETDCVALUEINDEX $guid100 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 100
        Write-Output "Power plan updated successfully"
    } catch {
        Write-Output "Failed to update power plan"
    }
    Write-Output "New power plan 100 created with GUID: $guid100"

    Write-Output "Creating new power plan 99"
    $guid_string99 = powercfg /duplicatescheme $guid
    $guid99 = (GetGUID $guid_string99)
    # change name
    powercfg /changename $guid99 "99"

    # changing values for power plan 99
    try {
        powercfg /SETACVALUEINDEX $guid99 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 99
        powercfg /SETDCVALUEINDEX $guid99 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 99
        Write-Output "Power plan updated successfully"
    } catch {
        Write-Output "Failed to update power plan"
    }
    Write-Output "New power plan 100 created with GUID: $guid99"
}
else {
    Write-Output "Power plan 100 already exists with GUID: $guid100"
    Write-Output "Power plan 99 already exists with GUID: $guid99"

}

### Check which power plan is active
if ($guid -eq $guid100) {
    Write-Output "Power plan 100 is active"
    Write-Output "Setting power plan to 99"
    powercfg /setactive $guid99
    Write-Output "Power plan set to 99"
}
elseif ($guid -eq $guid99) {
    Write-Output "Power plan 99 is active"
    Write-Output "Setting power plan to 100"
    powercfg /setactive $guid100
    Write-Output "Power plan set to 100"
}
else {
    Write-Output "Neither power plan 100 nor 99 is active"
    Write-Output "Setting power plan to 99"
    powercfg /setactive $guid99
    Write-Output "Power plan set to 99"
}

### wait for any key
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
