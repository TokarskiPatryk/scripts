### Find current power plan GUID

# Run the command and capture output
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
if ($guid -eq $null) {
    Write-Output "GUID not found"
    exit -1
}
Write-Output "Extracted GUID: $guid"

### Duplicate the current power plan
$output2 = powercfg /DUPLICATESCHEME $guid

$guid2 = GetGUID $output2

Write-Output "Duplicated GUID: $guid2"

### Set the new power plan to 
# processor power management -> maximum processor state -> 100%
powercfg /SETACVALUEINDEX $guid2 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 100


# set to 100% maximum processor state
powercfg /SETACVALUEINDEX f4347683-c976-4f18-9b4d-a285d6b69787 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 100
powercfg /SETDCVALUEINDEX f4347683-c976-4f18-9b4d-a285d6b69787 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 100



### temporary delete created plans

powercfg /DELETE $guid2


### wait for any key
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
