Set-Alias -Name azid -Value Get-AzResourceId

function Get-AzResourceId {
    param (
        [CmdletBinding()]
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$ResourceName,

        [Parameter(Mandatory = $false, Position = 1)]
        [string]$ResourceType
    )

    $ResourceName = $ResourceName.Trim()
    
    if ($ResourceType) {
        $ResourceType = $ResourceType.Trim()
    }

    if (-not (Test-AzLoggedIn)) {
        Write-Host "Not connected to Azure. Please run 'az login' first." -ForegroundColor Red
	    return $null
    }

    if ($ResourceType) {
        $resources = az resource list --resource-type $ResourceType --query "[?name=='$ResourceName'].{id:id, name:name}" -o json 2>$null | ConvertFrom-Json

        # Resource Groups can't be queried by --resource-type, so an explicit check is required.
        if ($ResourceType -eq 'Microsoft.Resources/resourceGroups') {
            $groups = @()
        } else {
            $groups = az group list --query "[?name=='$ResourceName'].{id:id, name:name}" -o json 2>$null | ConvertFrom-Json
        }
    } else {
        $resources = az resource list --query "[?name=='$ResourceName'].{id:id, name:name}" -o json 2>$null | ConvertFrom-Json
        $groups    = az group list --query "[?name=='$ResourceName'].{id:id, name:name}" -o json 2>$null | ConvertFrom-Json
    }

    $allMatches = @(@($resources) + @($groups) | Where-Object { $_ -ne $null })

    if ($allMatches.Count -eq 0) {
        Write-Host "No resource found of name '$ResourceName'." -ForegroundColor Red
	    return $null
    } elseif ($allMatches.Count -ne 1) {
        Write-Host "Multiple resources found of name '$ResourceName'. Please disambiguate by providing ResourceType." -ForegroundColor Red
	    return $null
    } else {
        return $allMatches[0].id
    }
}

Set-Alias -Name aztype -Value Get-AzResourceTypes

function Get-AzResourceTypes {
    param (
        [CmdletBinding()]
        [Parameter(Mandatory = $false, Position = 0)]
        [string]$SearchTerm = "*"
    )

    az provider list --query "[].resourceTypes[].resourceType" -o tsv |
        Select-Object -Unique |
        Where-Object { $_ -like "$SearchTerm" } |
        Sort-Object
}

function Test-AzLoggedIn {
    return [bool](az account show 2>$null)
}