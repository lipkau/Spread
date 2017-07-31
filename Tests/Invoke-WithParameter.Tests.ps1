. $PSScriptRoot\Shared.ps1

InModuleScope Spread {

    # [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '', Scope = '*', Target = 'SuppressImportModule')]
    $SuppressImportModule = $true
    . $PSScriptRoot\Shared.ps1

    Describe 'Invoke-WithParameter' {
        Context 'Sanity Check' {
            $command = Get-Command "Invoke-WithParameter"
            defParam $command 'ScriptBlock'
            defParam $command 'Parameter'

            It 'module is loaded' {
                Get-Module Spread | Should Not BeNullOrEmpty
            }
        }

        Context 'Aliases Tests' {
            It 'exposes an alias "demux"' {
                $alias = Get-Alias "demux" -ErrorAction SilentlyContinue
                $alias | Should Not BeNullOrEmpty
                $alias.ResolvedCommandName | Should Be "Invoke-WithParameter"
            }
            It 'exposes an alias "spread"' {
                $alias = Get-Alias "spread" -ErrorAction SilentlyContinue
                $alias | Should Not BeNullOrEmpty
                $alias.ResolvedCommandName | Should Be "Invoke-WithParameter"
            }
        }

        Context 'Functionality' {

            Mock Get-Verb -ParameterFilter { $Verb -and $Verb -eq "I*"} {
                ShowMockInfo 'Get-Verb' -Params 'Verb'
                return @(
                    [PSCustomObject]@{
                        Verb  = "Import"
                        Group = "Data"
                    }
                    [PSCustomObject]@{
                        Verb  = "Initialize"
                        Group = "Data"
                    }
                    [PSCustomObject]@{
                        Verb  = "Install"
                        Group = "Lifecycle"
                    }
                    [PSCustomObject]@{
                        Verb  = "Invoke"
                        Group = "Lifecycle"
                    }
                )
            }

            Mock Format-Wide -ParameterFilter { $Column -and $Column -eq 3} {
                ShowMockInfo 'Format-Wide' -Params 'Column'
                return $true
            }

            It 'spreads parameter/value pairs from the parameters' {
                { Invoke-WithParameter { Get-Verb | Format-Wide } Column 3 Verb "I*" } | Should Not Throw

                Assert-MockCalled -CommandName Get-Verb -ParameterFilter {$Verb -eq "I*"} -Scope It
                Assert-MockCalled -CommandName Format-Wide -ParameterFilter {$Column -eq 3} -Scope It
            }

            It 'accepts splatting' {
                $parameters = @{Column = 3; "Get-Verb:Verb" = "I*"}
                { Invoke-WithParameter { Get-Verb | Format-Wide } @parameters } | Should Not Throw

                Assert-MockCalled -CommandName Get-Verb -ParameterFilter {$Verb -eq "I*"} -Scope It
                Assert-MockCalled -CommandName Format-Wide -ParameterFilter {$Column -eq 3} -Scope It
            }

            It 'accepts scriptblock from variable' {
                $scriptblock = {Get-Verb | Format-Wide}
                { Invoke-WithParameter $scriptblock Column 3 Verb "I*" } | Should Not Throw

                Assert-MockCalled -CommandName Get-Verb -ParameterFilter {$Verb -eq "I*"} -Scope It
                Assert-MockCalled -CommandName Format-Wide -ParameterFilter {$Column -eq 3} -Scope It
            }

            It 'accepts scriptblock from variable and splatting' {
                $scriptblock = { Get-Verb | Format-Wide }
                $parameters = @{ Column = 3; "Get-Verb:Verb" = "I*" }
                { Invoke-WithParameter $scriptblock @parameters } | Should Not Throw

                Assert-MockCalled -CommandName Get-Verb -ParameterFilter {$Verb -eq "I*"} -Scope It
                Assert-MockCalled -CommandName Format-Wide -ParameterFilter {$Column -eq 3} -Scope It
            }

            It 'accepts a variable from outside of the scriptblock' {
                $verbs = "I*"
                { Invoke-WithParameter { Get-Verb -verb $verbs | Format-Wide } Column 3 } | Should Not Throw

                Assert-MockCalled -CommandName Get-Verb -ParameterFilter {$Verb -eq "I*"} -Scope It
                Assert-MockCalled -CommandName Format-Wide -ParameterFilter {$Column -eq 3} -Scope It
            }

            It 'returns the result of the scriptblock' {
                $verbs = Invoke-WithParameter { Get-Verb | Format-Wide} Column 3 Verb "I*"

                $verbs | Should Not BeNullOrEmpty
                $verbs.count | Should Be 4
                Assert-MockCalled -CommandName Get-Verb -ParameterFilter {$Verb -eq "I*"} -Scope It
                Assert-MockCalled -CommandName Format-Wide -ParameterFilter {$Column -eq 3} -Scope It
            }

            It 'returns all results of the scriptblock when multiple commands are executed' {
                $verbs = Invoke-WithParameter { Get-Verb | Format-Wide ; Get-Verb | Format-Wide } Column 3 Verb "I*"

                $verbs | Should Not BeNullOrEmpty
                $verbs.count | Should Be 8
                Assert-MockCalled -CommandName Get-Verb -ParameterFilter {$Verb -eq "I*"} -Scope It
                Assert-MockCalled -CommandName Format-Wide -ParameterFilter {$Column -eq 3} -Scope It
            }

            It 'allows for parameters to affect all relevant commands' {
                $scriptblock = { Get-Verb | Format-Wide }
                { Invoke-WithParameter $scriptblock Column 3 *:Verb "I*" } | Should Not Throw

                Assert-MockCalled -CommandName Get-Verb -ParameterFilter {$Verb -eq "I*"} -Scope It
                Assert-MockCalled -CommandName Format-Wide -ParameterFilter {$Column -eq 3} -Scope It
            }

            It 'allows for parameter names to be declared with leading dash' {
                $scriptblock = { Get-Verb | Format-Wide }
                { Invoke-WithParameter $scriptblock -Column 3 -"Verb" "I*" } | Should Not Throw

                Assert-MockCalled -CommandName Get-Verb -ParameterFilter {$Verb -eq "I*"} -Scope It
                Assert-MockCalled -CommandName Format-Wide -ParameterFilter {$Column -eq 3} -Scope It
            }

            It 'does not change the global PSDefaultParameterValues' {
                $PSDefaultParameterValues.ContainsKey("*:Name") | Should Be $false
                { Invoke-WithParameter -ScriptBlock {} Name '*y*' } | Should Not Throw
                $PSDefaultParameterValues.ContainsKey("*:Name") | Should Be $false
            }

        }

    }

}
