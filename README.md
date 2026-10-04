# PSAZ (PowerShell Azure)

PowerShell helper that allows Azure CLI users to get Azure resource IDs from Azure resource names.

## Requirements

- Windows PowerShell 5.1 or PowerShell 7
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) (`az`)

## Install

1. Download or clone this folder.
2. Double-click **`install.bat`**.
3. Choose how to install PSAZ:
   - **1) Module:** loads only when you use a PSAZ command.
   - **2) Profile:** loads in every PowerShell window.
4. Open a new PowerShell window.

To update, pull the latest files and run `install.bat` again.

PSAZ installs for the PowerShell version that runs the installer. `install.bat` uses Windows PowerShell 5.1, so to install for PowerShell 7 as well, run `install.ps1` from a PowerShell 7 window.

## Use

WIP

## Files

| File          | Purpose                                     |
| ------------- | ------------------------------------------- |
| `install.bat` | Launcher. Double-click this                 |
| `install.ps1` | The installer                               |
| `psaz.ps1`    | The PSAZ functions                          |
| `psaz.psm1`   | Loads `psaz.ps1` when installed as a module |