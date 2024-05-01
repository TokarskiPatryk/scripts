# scripts

## QuietWindows/ChangePowerPlan.exe
**Use this script when your laptop's fans are too loud when idle.**
Script changes CPU behavior to not overclock. Running script again will revert changes and set CPU to default behavior.

To run script:
- [Download the ChangePowerPlan.exe](https://github.com/TokarskiPatryk/scripts/raw/main/QuietWindows/ChangePowerPlan.exe) 
- or run `ChangePowerPlan.ps1` PowerShell script 
- or compile ps1 script to exe yourself using the `ConvertPS1toEXE.ps1` script in QuietWindows folder

To change it manually:

Open Control Panel -> Power Options -> Change plan settings -> Change advanced power settings -> Processor power management -> Maximum processor state -> set to 99% or lower