BeforeAll {
    . (Join-Path $PSScriptRoot "..\psaz.ps1")
}

Describe "Get-AzResourceId" {

    It "Prompts user to login to Azure if not already logged in" {
        Mock Test-AzLoggedIn { return $false }
        Mock Write-Host {}

        $result = Get-AzResourceId -ResourceName 'MockResourceGroup'
        $result | Should -BeNullOrEmpty
        Should -Invoke Write-Host -Times 1 -ParameterFilter { $Object -match "Not connected to Azure. Please run 'az login' first." }
    }

    It "Returns Azure Resource Group ID when the appropriate Resource Type is provided" {
        Mock Test-AzLoggedIn { return $true }
        Mock az {
            '[{"id":"/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/MockResourceGroup","name":"MockResourceGroup","type":"Microsoft.Resources/resourceGroups"}]'
        } -ParameterFilter { $args -contains "group" -and $args -contains "list" }

        $result = Get-AzResourceId -ResourceName 'MockResourceGroup' -ResourceType 'Microsoft.Resources/resourceGroups'
        $result | Should -Contain '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/MockResourceGroup'
    }

    It "Returns Azure Resource ID when the appropriate Resource Type is provided" {
        Mock Test-AzLoggedIn { return $true }
        Mock az {
            '[{"id":"/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/MockResourceGroup/providers/Microsoft.Web/sites/MockApp","name":"MockApp","type":"Microsoft.Web/sites"}]'
        } -ParameterFilter { $args -contains "resource" -and $args -contains "list" }

        $result = Get-AzResourceId -ResourceName 'MockApp' -ResourceType 'Microsoft.Web/sites'
        $result | Should -Be '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/MockResourceGroup/providers/Microsoft.Web/sites/MockApp'
    }

    It "Returns Azure Resource Group ID when no Resource Type is provided" {
        Mock Test-AzLoggedIn { return $true }
        Mock az {
            '[{"id":"/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/MockResourceGroup","name":"MockResourceGroup","type":"Microsoft.Resources/resourceGroups"}]'
        } -ParameterFilter { $args -contains "group" -and $args -contains "list" }
        Mock az { return '[]' } -ParameterFilter { $args -contains "resource" -and $args -contains "list" }

        $result = Get-AzResourceId -ResourceName 'MockResourceGroup'
        $result | Should -Be '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/MockResourceGroup'
    }

    It "Returns Azure Resource ID when no Resource Type is provided" {
        Mock Test-AzLoggedIn { return $true }
        Mock az { return '[]' } -ParameterFilter { $args -contains "group" -and $args -contains "list" }
        Mock az {
            '[{"id":"/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/MockResourceGroup/providers/Microsoft.Web/sites/MockApp","name":"MockApp","type":"Microsoft.Web/sites"}]'
        } -ParameterFilter { $args -contains "resource" -and $args -contains "list" }

        $result = Get-AzResourceId -ResourceName 'MockApp'
        $result | Should -Be '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/MockResourceGroup/providers/Microsoft.Web/sites/MockApp'
    }

    It "Does not return any Azure Resource Group ID when the Resource Name is not found" {
        Mock Test-AzLoggedIn { return $true }
        Mock az { return '[]' } -ParameterFilter { $args -contains "group" -and $args -contains "list" }
        Mock Write-Host {}

        $result = Get-AzResourceId -ResourceName 'MockResourceGroup' -ResourceType 'Microsoft.Resources/resourceGroups'
        $result | Should -BeNullOrEmpty
        Should -Invoke Write-Host -Times 1 -ParameterFilter { $Object -match "No resource found of name 'MockResourceGroup'." }
    }

    It "Does not return any Azure Resource ID when the Resource Name is not found" {
        Mock Test-AzLoggedIn { return $true }
        Mock az { return '[]' } -ParameterFilter { $args -contains "resource" -and $args -contains "list" }
        Mock Write-Host {}

        $result = Get-AzResourceId -ResourceName 'MockApp' -ResourceType 'Microsoft.Web/sites'
        $result | Should -BeNullOrEmpty
        Should -Invoke Write-Host -Times 1 -ParameterFilter { $Object -match "No resource found of name 'MockApp'." }
    }

    It "Does not return any Azure Resource ID when the Resource Name is not found and Resource Type is not provided" {
        Mock Test-AzLoggedIn { return $true }
        Mock az { return '[]' } -ParameterFilter { $args -contains "group" -and $args -contains "list" }
        Mock az { return '[]' } -ParameterFilter { $args -contains "resource" -and $args -contains "list" }
        Mock Write-Host {}

        $result = Get-AzResourceId -ResourceName 'MockApp'
        $result | Should -BeNullOrEmpty
        Should -Invoke Write-Host -Times 1 -ParameterFilter { $Object -match "No resource found of name 'MockApp'." }
    }

    It "Does not return any Azure Resource ID when multiple resources with the same name exist" {
        Mock Test-AzLoggedIn { return $true }
        Mock az {
            '[{"id":"/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/MockResource","name":"MockResource","type":"Microsoft.Resources/resourceGroups"}]'
        } -ParameterFilter { $args -contains "group" -and $args -contains "list" }
        Mock az {
            '[{"id":"/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/MockResource/providers/Microsoft.Web/sites/MockResource","name":"MockResource","type":"Microsoft.Web/sites"}]'
        } -ParameterFilter { $args -contains "resource" -and $args -contains "list" }
        Mock Write-Host {}

        $result = Get-AzResourceId -ResourceName 'MockResource'
        $result | Should -BeNullOrEmpty
        Should -Invoke Write-Host -Times 1 -ParameterFilter { $Object -match "Multiple resources found for 'MockResource'." }
        Should -Invoke Write-Host -Times 1 -ParameterFilter { $Object -match "Microsoft.Resources/resourceGroups" }
        Should -Invoke Write-Host -Times 1 -ParameterFilter { $Object -match "Microsoft.Web/sites" }
    }

    It "Does not return any Azure Resource ID when multiple resources with the same name exist" {
        Mock Test-AzLoggedIn { return $true }
        Mock az {
            '[{"id":"/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/MockResource","name":"MockResource","type":"Microsoft.Resources/resourceGroups"}]'
        } -ParameterFilter { $args -contains "group" -and $args -contains "list" }
        Mock az {
            '[{"id":"/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/MockResource/providers/Microsoft.Web/sites/MockResource","name":"MockResource","type":"Microsoft.Web/sites"}]'
        } -ParameterFilter { $args -contains "resource" -and $args -contains "list" }
        Mock Write-Host {}

        $result = Get-AzResourceId -ResourceName ' MockResource '
        $result | Should -BeNullOrEmpty
        Should -Invoke Write-Host -Times 1 -ParameterFilter { $Object -match "Multiple resources found for 'MockResource'." }
    }
}