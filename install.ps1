# Define variables.
$scriptName = 'psaz.ps1'

# Define the install functions.
function InstallProfile {
    if (-not (Test-Path $PROFILE)) {
        New-Item -Path $PROFILE -ItemType File -Force | Out-Null
    }

    $scriptPath  = Join-Path $PSScriptRoot $scriptName
    $profileLine = ". `"$scriptPath`""

    if (Select-String -Path $PROFILE -SimpleMatch $profileLine -Quiet) {
        Write-Host "Profile already contains PSAZ."
    } else {
        Add-Content -Path $PROFILE -Value $profileLine

        # Only add a blank line above the entry if the profile already has content.
        if (-not [string]::IsNullOrWhiteSpace((Get-Content -Path $PROFILE -Raw))) {
            $entry = "`n$entry"
        }

        Write-Host "PSAZ added to profile."
    }
}

function InstallModule {
    Write-Host "Y." -ForegroundColor Green
}

function InstallShortcut {
    Write-Host "Z." -ForegroundColor Yellow
}

function Invalid {
    Write-Host "Invalid selection." -ForegroundColor Red
}

# Present options to the user.
Write-Host "========================================" -ForegroundColor DarkGray
Write-Host "How would you like PSAZ to be installed?" -ForegroundColor White
Write-Host "1) Profile"
Write-Host "2) Module (Recommended)"
Write-Host "3) Shortcut"
Write-Host "========================================" -ForegroundColor DarkGray

# Wait for user input.
Write-Host "Please enter 1, 2, or 3:" -ForegroundColor White
$choice = Read-Host

# Execute corresponding function based on input.
switch ($choice) {
    '1' { InstallProfile }
    '2' { InstallModule }
    '3' { InstallShortcut }
    default { Invalid }
}