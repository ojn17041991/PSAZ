# Define variables.
$folderName = 'psaz'
$scriptName = 'psaz.ps1'

# Define the install functions.
function InstallProfile {
    $profilePath = EnsureProfile
    $scriptPath  = EnsureScriptPathInLocalAppData
    $profileLine = ". `"$scriptPath`""

    if (Select-String -Path $PROFILE -SimpleMatch $profileLine -Quiet) {
        Write-Host "Profile already contains PSAZ."
        return
    }

    if (-not [string]::IsNullOrWhiteSpace((Get-Content -Path $profilePath -Raw))) {
        $profileLine = "`n$profileLine"
    }

    Add-Content -Path $profilePath -Value $profileLine
    Write-Host "PSAZ added to profile."    
}

function EnsureProfile {
    if (-not (Test-Path $PROFILE)) {
        New-Item -Path $PROFILE -ItemType File -Force | Out-Null
    }

    return $PROFILE
}

function EnsureScriptPathInLocalAppData {
    $folderPath =      Join-Path $env:LOCALAPPDATA $folderName
    $sourcePath =      Join-Path $PSScriptRoot $scriptName
    $destinationPath = Join-Path $folderPath $scriptName

    New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
    Copy-Item -LiteralPath $sourcePath -Destination $destinationPath -Force

    return $destinationPath
}

function InstallModule {
    Write-Host "Y." -ForegroundColor Green
}

function Invalid {
    Write-Host "Invalid selection." -ForegroundColor Red
}

# Present options to the user.
Write-Host "========================================" -ForegroundColor DarkGray
Write-Host "How would you like PSAZ to be installed?" -ForegroundColor White
Write-Host "1) Profile"
Write-Host "2) Module (Recommended)"
Write-Host "========================================" -ForegroundColor DarkGray

# Wait for user input.
Write-Host "Please enter 1 or 2:" -ForegroundColor White
$choice = Read-Host

# Execute corresponding function based on input.
switch ($choice) {
    '1' { InstallProfile }
    '2' { InstallModule }
    default { Invalid }
}