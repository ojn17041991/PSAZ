# Define variables.
$folderName       = 'psaz'
$scriptName       = 'psaz.ps1'
$moduleName       = 'psaz.psm1'
$sourceScriptPath = Join-Path $PSScriptRoot $scriptName
$sourceModulePath = Join-Path $PSScriptRoot $moduleName

# Adds PSAZ to the PS Profile.
function InstallProfile {
    if (-not (CheckSource)) {
        Write-Host "Source files unavailable."
        return
    }

    if (-not (CheckAzureCli)) {
        Write-Host "PSAZ requires Azure CLI to be installed."
        return
    }

    $profilePath = EnsureProfile
    $scriptPath  = EnsureScriptPathInLocalAppData
    $profileLine = ". `"$scriptPath`""

    if (Select-String -Path $profilePath -SimpleMatch $profileLine -Quiet) {
        Write-Host "PSAZ updated in profile."
        return
    }

    if (-not [string]::IsNullOrWhiteSpace((Get-Content -Path $profilePath -Raw))) {
        $profileLine = "`n$profileLine"
    }

    Add-Content -Path $profilePath -Value $profileLine
    Write-Host "PSAZ added to profile."    
}

# Checks whether Azure CLI is installed.
function CheckAzureCli {
    return [bool](Get-Command az -ErrorAction SilentlyContinue)
}

# Checks whether source files are available.
function CheckSource {
    return (Test-Path -LiteralPath $sourceScriptPath) -and (Test-Path -LiteralPath $sourceModulePath)
}

# Ensures PS Profile exists.
function EnsureProfile {
    if (-not (Test-Path $PROFILE)) {
        New-Item -Path $PROFILE -ItemType File -Force | Out-Null
    }

    return $PROFILE
}

# Ensures source files are available in LocalAppData.
function EnsureScriptPathInLocalAppData {
    $destinationFolderPath = Join-Path $env:LOCALAPPDATA $folderName
    $destinationScriptPath = Join-Path $destinationFolderPath $scriptName

    New-Item -ItemType Directory -Path $destinationFolderPath -Force | Out-Null
    Copy-Item -LiteralPath $sourceScriptPath -Destination $destinationScriptPath -Force

    return $destinationScriptPath
}

# Adds PSAZ as a PS Module.
function InstallModule {
    if (-not (CheckSource)) {
        Write-Host "Source files unavailable."
        return
    }

    if (-not (CheckAzureCli)) {
        Write-Host "PSAZ requires Azure CLI to be installed."
        return
    }

    $modulePath = EnsureModulePathInDocuments

    Write-Host "PSAZ module installed."
}

# Ensures source files are available in PS Modules.
function EnsureModulePathInDocuments {
    $documentFolderPath    = [Environment]::GetFolderPath('MyDocuments')
    $powershellFolderName  = if ($PSVersionTable.PSEdition -eq 'Core') { 'PowerShell' } else { 'WindowsPowerShell' }
    $powershellFolderPath  = Join-Path $documentFolderPath $powershellFolderName
    $powershellModulesPath = Join-Path $powershellFolderPath "\Modules\"
    $destinationFolderPath = Join-Path $powershellModulesPath $folderName
    $destinationScriptPath = Join-Path $destinationFolderPath $scriptName
    $destinationModulePath = Join-Path $destinationFolderPath $moduleName

    New-Item -ItemType Directory -Path $destinationFolderPath -Force | Out-Null
    Copy-Item -LiteralPath $sourceScriptPath -Destination $destinationScriptPath -Force
    Copy-Item -LiteralPath $sourceModulePath -Destination $destinationModulePath -Force

    return $destinationModulePath
}

# Messages to inform that the installation method selected was invalid.
function InstallInvalid {
    Write-Host "Invalid selection." -ForegroundColor Red
}

# Present options to the user.
Write-Host "========================================" -ForegroundColor DarkGray
Write-Host "How would you like PSAZ to be installed?" -ForegroundColor White
Write-Host "1) Module (Loads only when invoked)"
Write-Host "2) Profile (Loads in all windows by default)"
Write-Host "========================================" -ForegroundColor DarkGray

# Wait for user input.
Write-Host "Please enter 1 or 2:" -ForegroundColor White
$choice = Read-Host

# Execute corresponding function based on input.
switch ($choice) {
    '1' { InstallModule }
    '2' { InstallProfile }
    default { InstallInvalid }
}