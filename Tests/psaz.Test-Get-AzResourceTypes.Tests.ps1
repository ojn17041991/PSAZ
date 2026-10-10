BeforeAll {
    . (Join-Path $PSScriptRoot "..\psaz.ps1")
}

Describe "Get-AzResourceTypes" {

    It "Returns matching Azure Resource Types containing the search term" {
        Mock az { return @('Microsoft.Web/apps') } -ParameterFilter { $args -contains "provider" -and $args -contains "list" }

        $result = Get-AzResourceTypes -SearchTerm '*Web/a*'
        $result | Should -Contain 'Microsoft.Web/apps'
    }

    It "Returns matching Azure Resource Types starting with the search term" {
        Mock az { return @('Microsoft.Web/apps') } -ParameterFilter { $args -contains "provider" -and $args -contains "list" }

        $result = Get-AzResourceTypes -SearchTerm 'Microsoft.Web/a*'
        $result | Should -Contain 'Microsoft.Web/apps'
    }

    It "Returns matching Azure Resource Types ending with the search term" {
        Mock az { return @('Microsoft.Web/apps') } -ParameterFilter { $args -contains "provider" -and $args -contains "list" }

        $result = Get-AzResourceTypes -SearchTerm '*b/apps'
        $result | Should -Contain 'Microsoft.Web/apps'
    }

    It "Returns matching Azure Resource Types matching the search term exactly" {
        Mock az { return @('Microsoft.Web/apps') } -ParameterFilter { $args -contains "provider" -and $args -contains "list" }

        $result = Get-AzResourceTypes -SearchTerm 'Microsoft.Web/apps'
        $result | Should -Contain 'Microsoft.Web/apps'
    }

    It "Returns only Azure Resource Types matching the search term" {
        Mock az { return @('Microsoft.Web/sites', 'Microsoft.Web/apps') } -ParameterFilter { $args -contains "provider" -and $args -contains "list" }

        $result = Get-AzResourceTypes -SearchTerm '*sites*'
        $result | Should -Contain 'Microsoft.Web/sites'
    }

    It "Returns an empty array when no Azure Resource Types match the search term" {
        Mock az { return @('Microsoft.Web/sites') } -ParameterFilter { $args -contains "provider" -and $args -contains "list" }

        $result = Get-AzResourceTypes -SearchTerm '*apps*'
        $result | Should -BeNullOrEmpty
    }
}