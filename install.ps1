# Define the install functions.
function InstallProfile {
    Write-Host "X." -ForegroundColor Cyan
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