# =====================================================================
# Get-AzResourceId
# Resolves an Azure Resource Name to its Resource ID.
# =====================================================================
function Get-AzResourceId {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$ResourceName,

        [Parameter(Mandatory = $false, Position = 1)]
        [string]$ResourceType
    )

    <#
    .SYNOPSIS
        Resolves an Azure Resource Name to its Resource ID.

    .DESCRIPTION
        Queries Azure CLI to locate resources or resource groups matching the provided name, and returns the corresponding Resource ID.
        If multiple matches are found across resource types, it lists the conflicting types.

    .PARAMETER ResourceName
        The exact name of the Azure resource or resource group to search for.

    .PARAMETER ResourceType
        Optional ARM Resource Type filter (e.g., 'Microsoft.Web/sites' or 'Microsoft.KeyVault/vaults').

    .EXAMPLE
        Get-AzResourceId -ResourceName 'my-function-app'
        Returns the full ARM resource ID for the resource of name 'my-function-app'.

    .EXAMPLE
        Get-AzResourceId -ResourceName 'my-keyvault' -ResourceType 'Microsoft.KeyVault/vaults'
        Returns the full ARM resource ID for the resource of name 'my-keyvault' and type 'Microsoft.KeyVault/vaults'.

    .EXAMPLE
        azid 'my-app' 'Microsoft.Web/sites'
        Shorthand for Get-AzResourceId.

    .INPUTS
        None.

    .OUTPUTS
        System.String. Returns the ARM resource ID, or $null if not found/ambiguous.
    #>

    # Informational logging.
    Write-Verbose "Starting Get-AzResourceId function."

    # Variable definitions.
    $ResourceGroupType = 'Microsoft.Resources/resourceGroups'

    # Trim parameters.
    $ResourceName = $ResourceName.Trim()
    if ($ResourceType) {
        $ResourceType = $ResourceType.Trim()
    }

    # The user must be logged into Azure.
    if (-not (Test-AzLoggedIn)) {
        Write-Host "Not connected to Azure. Please run 'az login' first." -ForegroundColor Red
        return $null
    } else {
        Write-Verbose "Connected to Azure."
    }

    # Get resources and resource groups from Azure based on requested resource name and type.
    if ($ResourceType) {
        if ($ResourceType -eq $ResourceGroupType) {
            Write-Verbose "Resource group type selected."
            $resources = @()
            $groups    = az group list --query "[?name=='$ResourceName'].{id:id, name:name, type:'$ResourceGroupType'}" -o json 2>$null | ConvertFrom-Json
        } else {
            Write-Verbose "Resource type selected."
            $resources = az resource list --resource-type $ResourceType --query "[?name=='$ResourceName'].{id:id, name:name, type:type}" -o json 2>$null | ConvertFrom-Json
            $groups    = @()
        }
    } else {
        Write-Verbose "Resource type not specified."
        $resources = az resource list --query "[?name=='$ResourceName'].{id:id, name:name, type:type}" -o json 2>$null | ConvertFrom-Json
        $groups    = az group list --query "[?name=='$ResourceName'].{id:id, name:name, type:'$ResourceGroupType'}" -o json 2>$null | ConvertFrom-Json
    }

    # Merge resources and resource groups into a single collection.
    $allMatches = @(@($resources) + @($groups) | Where-Object { $_ -ne $null })

    # Handle error messaging for no matches or multiple matches. Return only if a single match is found.
    if ($allMatches.Count -eq 0) {
        Write-Host "No resource found of name '$ResourceName'." -ForegroundColor Red
        return $null
    } elseif ($allMatches.Count -gt 1) {
        Write-Host "Multiple resources found for '$ResourceName'. Please specify one of these types:" -ForegroundColor Red
        $allMatches.type | Select-Object -Unique | ForEach-Object { Write-Host '-' $_ -ForegroundColor Red }
        return $null
    } else {
        Write-Verbose "Single resource match found."
        return $allMatches[0].id
    }
}

# =====================================================================
# Get-AzResourceTypes
# Retrieves Azure Resource Types based on a search term.
# =====================================================================
function Get-AzResourceTypes {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [string]$SearchTerm = "*"
    )

    <#
    .SYNOPSIS
        Retrieves Azure Resource Types based on a search term.

    .DESCRIPTION
        Queries Azure CLI to retrieve all available Azure Resource Types, filters them based on the provided search term, and returns the matching types.

    .PARAMETER SearchTerm
        An optional search term to filter Azure Resource Types. Supports wildcards (e.g., '*', 'Microsoft.Web/*').

    .EXAMPLE
        Get-AzResourceTypes -SearchTerm '*sites'
        Returns all Azure Resource Types matching the search term '*sites'.

    .EXAMPLE
        aztype 'Microsoft*'
        Shorthand for Get-AzResourceTypes.

    .INPUTS
        None.

    .OUTPUTS
        System.String. Returns the matching Azure Resource Types based on the search term.
    #>

    # Informational logging.
    Write-Verbose "Starting Get-AzResourceTypes function."

    # Search for Azure Resource Types.
    az provider list --query "[].resourceTypes[].resourceType" -o tsv |
        Select-Object -Unique |
        Where-Object { $_ -like "$SearchTerm" } |
        Sort-Object
}

# =====================================================================
# Test-AzLoggedIn
# Tests if the user is logged into Azure.
# =====================================================================
function Test-AzLoggedIn {
    [CmdletBinding()]
    param()

    <#
    .SYNOPSIS
        Tests if the user is logged into Azure.

    .DESCRIPTION
        Checks if the current user is logged into Azure by attempting to retrieve the account information using the Azure CLI.

    .EXAMPLE
        Test-AzLoggedIn
        Returns $true if the user is logged into Azure, otherwise $false.

    .EXAMPLE
        aztest
        Shorthand for Test-AzLoggedIn.

    .INPUTS
        None.

    .OUTPUTS
        System.Boolean. Returns $true if the user is logged into Azure, otherwise $false.
    #>

    # Informational logging.
    Write-Verbose "Starting Test-AzLoggedIn function."

    # Test the Azure login status.
    return [bool](az account show 2>$null)
}

# =====================================================================
# Aliases
# Set aliases for the defined functions.
# =====================================================================
Set-Alias -Name azid -Value Get-AzResourceId
Set-Alias -Name aztype -Value Get-AzResourceTypes
Set-Alias -Name aztest -Value Test-AzLoggedIn