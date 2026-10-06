Set-Alias -Name azid -Value Get-AzResourceId
Set-Alias -Name aztype -Value Get-AzResourceTypes

function Get-AzResourceId {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$ResourceName,

        [Parameter(Mandatory = $false, Position = 1)]
        [string]$ResourceType
    )

    $ResourceGroupType = 'Microsoft.Resources/resourceGroups'

    $ResourceName = $ResourceName.Trim()
    
    if ($ResourceType) {
        $ResourceType = $ResourceType.Trim()
    }

    if (-not (Test-AzLoggedIn)) {
        Write-Host "Not connected to Azure. Please run 'az login' first." -ForegroundColor Red
        return $null
    }

    if ($ResourceType) {
        if ($ResourceType -eq $ResourceGroupType) {
            $resources = @()
            $groups    = az group list --query "[?name=='$ResourceName'].{id:id, name:name, type:'$ResourceGroupType'}" -o json 2>$null | ConvertFrom-Json
        } else {
            $resources = az resource list --resource-type $ResourceType --query "[?name=='$ResourceName'].{id:id, name:name, type:type}" -o json 2>$null | ConvertFrom-Json
            $groups    = @()
        }
    } else {
        $resources = az resource list --query "[?name=='$ResourceName'].{id:id, name:name, type:type}" -o json 2>$null | ConvertFrom-Json
        $groups    = az group list --query "[?name=='$ResourceName'].{id:id, name:name, type:'$ResourceGroupType'}" -o json 2>$null | ConvertFrom-Json
    }

    $allMatches = @(@($resources) + @($groups) | Where-Object { $_ -ne $null })

    if ($allMatches.Count -eq 0) {
        Write-Host "No resource found of name '$ResourceName'." -ForegroundColor Red
        return $null
    } elseif ($allMatches.Count -gt 1) {
        Write-Host "Multiple resources found for '$ResourceName'. Please specify one of these types:" -ForegroundColor Red
        $allMatches.type | Select-Object -Unique | ForEach-Object { Write-Host '-' $_ -ForegroundColor Red }
        return $null
    } else {
        return $allMatches[0].id
    }
}

function Get-AzResourceTypes {
    [CmdletBinding()]
    param (
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