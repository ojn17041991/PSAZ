BeforeAll {
    . (Join-Path $PSScriptRoot "..\psaz.ps1")
}

Describe "Test-AzLoggedIn" {

    It "Returns $true when user is logged into Azure CLI" {
        Mock az { return '{"id":"00000000-0000-0000-0000-000000000000"}' } -ParameterFilter { $args -contains "account" -and $args -contains "show" }

        $result = Test-AzLoggedIn
        $result | Should -Be $true
    }

    It "Returns $false when user is NOT logged into Azure CLI" {
        Mock az { return $null } -ParameterFilter { $args -contains "account" -and $args -contains "show" }

        $result = Test-AzLoggedIn
        $result | Should -Be $false
    }
}