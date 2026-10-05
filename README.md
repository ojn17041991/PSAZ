# PSAZ (PowerShell Azure)

PowerShell helper that allows Azure CLI users to get Azure resource IDs from Azure resource names.

## Install

1. Download or clone this folder.
2. Double-click **`install.bat`**.
3. Choose how to install PSAZ:
   - **1) Module:** loads only when you use a PSAZ command.
   - **2) Profile:** loads in every PowerShell window.
4. Open a new PowerShell window.

To update, pull the latest files and run `install.bat` again.

## Use

Run `Get-AzResourceId` or `azid` with a resource name to get the ID of the Azure resource with that name.

## Examples

`az resource show --ids (Get-AzResourceId "<ResourceGroupName>")`

`az functionapp show --ids (azid "<FunctionAppName")`

`az keyvault show --ids (azid "<KeyVaultName>")`