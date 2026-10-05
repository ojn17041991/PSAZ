Set-Alias -Name azid -Value Get-AzResourceId

function Get-AzResourceId {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ResourceName
    )

    if (-not (Test-AzLoggedIn)) {
        Write-Host "Not connected to Azure. Please run 'az login' first." -ForegroundColor Red
	return $null
    }

    $resources  = az resource list --query "[?name=='$ResourceName'].{id:id, name:name}" -o json 2>$null | ConvertFrom-Json
    $groups     = az group list --query "[?name=='$ResourceName'].{id:id, name:name}" -o json 2>$null | ConvertFrom-Json
    $allMatches = @(@($resources) + @($groups) | Where-Object { $_ -ne $null })

    if ($allMatches.Count -ne 1) {
        Write-Host "No unique resource of name '$ResourceName'." -ForegroundColor Red
	return $null
    }

    return $allMatches[0].id
}

function Test-AzLoggedIn {
    return [bool](az account show 2>$null)
}