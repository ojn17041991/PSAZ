# PSAZ (PowerShell Azure)

PSAZ is a PowerShell helper that allows Azure CLI users to get their Azure Resource IDs using the Azure Resource Name and, optionally, ARM Type.

This tool is designed to simplify Azure CLI usage. Instead of making multiple queries to Azure CLI to pull down Resource IDs to use in subsequent queries, an Azure CLI user can now write out a single query using the more concrete Resource Name field.

## Install

1. Download or clone this folder.
2. Run `install.bat`.
3. Choose how to install PSAZ:
   - Module - Loads only when you use a PSAZ command.
   - Profile -  Loads in every PowerShell window by default.
4. Open a new PowerShell window.
5. Run PSAZ commands.

To update PSAZ after installation, pull down the latest files and rerun the installer.

## Commands

* `Get-AzResourceId(ResourceName, [ResourceType]) | Alias: azid`

* `Get-AzResourceTypes([SearchTerm = "*"]) | Alias: aztype`

## Examples

#### Get-AzResourceId | azid

`az resource show --ids (Get-AzResourceId "<ResourceGroupName>")`

`az functionapp show --ids (azid "<FunctionAppName>" "Microsoft.Web/sites")`

`az webapp restart --ids (azid "<AppServiceName>" "Microsoft.Web/sites")`

#### Get-AzResourceTypes | aztype

`Get-AzResourceTypes "*vaults"`

`aztype "*config*"`