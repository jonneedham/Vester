<#
This file exists to combine simple user input (Invoke-Vester), simple
user test authoring (*.Vester.ps1), and properly scoped inventory objects
into a single test session that loops through all necessary combinations.

It is called by Invoke-Vester via the Invoke-Pester command.

http://vester.readthedocs.io/en/latest/
#>

# Accept -WhatIf input from Invoke-Vester
[CmdletBinding(SupportsShouldProcess = $true,
               ConfirmImpact = 'Medium')]
Param(
    # The $cfg hashtable from a single config file
    [object]$Cfg,

    # Array of paths for tests to run against this config file
    [object]$TestFiles,

    # Pass through the user's preference to fix differences or not
    [switch]$Remediate
)

Begin {
    # Perform get on Config scopes
    # If datacenter scope is not null, perform get on datacenter
    # If datacenter scope is null, do not perform get on Datacenter or children objects
    if ($cfg.scope.datacenter -ne $null) {
        $Datacenter = Get-Datacenter -Name $cfg.scope.datacenter -Server $cfg.vcenter.vc

        # If dscluster scope is not null, perform get on DatastoreCluster
        if ($cfg.scope.dscluster -ne $null) {
            $DSCluster = ($Datacenter | Get-DatastoreCluster -Name $cfg.scope.dscluster)
        }
        
        # If network scope is not null, perform get on VDSwitch
        if ($cfg.scope.network -ne $null) {
            $Network = ($Datacenter | Get-VDSwitch -Name $cfg.scope.vds)
        }

        # If cluster scope is not null, perform get on Cluster
        # If cluster scope is null, do not perform get on Cluster or children objects
        if ($cfg.scope.cluster -ne $null) {
            $Cluster = ($Datacenter | Get-Cluster -Name $cfg.scope.cluster)

            # If host scope is not null, perform get on VMHost
            if ($cfg.scope.host -ne $null) {
                $VMHost = ($Cluster | Get-VMHost -Name $cfg.scope.host)
            }
            
            # If vm scope is not null, perform get on VM
            if ($cfg.scope.vm -ne $null) {
                $VM = ($Cluster | Get-VM -Name $cfg.scope.vm)
            }
        } #IfCfgScopeCluster
    } #IfCfgScopeDatacenter
} #Begin

Process {
    # Set first time through flags for all scopes
    # This helps ensure a warning that tests aren't being run if scope is null only displays once
    $ClusterFlag = "False"
    $DSClusterFlag = "False"
    $HostFlag = "False"
    $VMFlag = "False"
    $NetworkFlag = "False"

    # Process .Vester.ps1 files one at a time
    ForEach ($Test in $TestFiles) {
        Write-Verbose "Processing test file $Test"
        $TestName = Split-Path $Test -Leaf
        $Scope = Split-Path (Split-Path $Test -Parent) -Leaf

        # The parent folder must be one of these names, to help with $Object scoping below
        # If adding here, also needs to be added to the switch below
        If ($Scope -notmatch 'vCenter|Datacenter|Cluster|DSCluster|Host|VM|Network') {
            Write-Warning "Skipping test $TestName. Use -Verbose for more details"
            Write-Verbose 'Test files should be in a folder with one of the following names:'
            Write-Verbose 'vCenter / Datacenter / Cluster / DSCluster / Host / VM / Network'
            Write-Verbose 'This helps Vester determine which inventory object(s) to use during the test.'
            # Use continue to skip this test and go to the next loop iteration
            continue
        }

        # Else, if the scope does match one of the above names, test if the scope has objects to test against
        Else {
            # If the scope matches Cluster, but the Cluster object is null, warn end user and skip tests
            # This should only warn the first time through         
            if ($Scope -match 'Cluster') {
                if ($Cluster -eq $null) {
                    if ($ClusterFlag -eq "False") {
                        # Write warning to show that all tests for Cluster scope were skipped
                        Write-Warning "Cluster has null value, skipping tests that rely on Cluster."
                        $ClusterFlag = "True"
                    }
                    # Use continue to skip this test and go to the next loop iteration
                    continue
                }
            }

            # If the scope matches DSCluster, but the DSCluster object is null, warn end user and skip tests
            # This should only warn the first time through
            if ($Scope -match 'DSCluster') {
                if ($DSCluster -eq $null) {
                    if ($DSClusterFlag -eq "False") {
                        # Write warning to show that all tests for DSCluster scope were skipped
                        Write-Warning "DSCluster has null value, skipping tests that rely on DSCluster."
                        $DSClusterFlag = "True"
                    }
                    # Use continue to skip this test and go to the next loop iteration
                    continue
                }
            }

            # If the scope matches Host, but the VMHost object is null, warn end user and skip tests
            # This should only warn the first time through
            if ($Scope -match 'Host') {
                if ($VMHost -eq $null) {
                    if ($HostFlag -eq "False") {
                        # Write warning to show that all tests for Host scope were skipped
                        Write-Warning "Host has null value, skipping tests that rely on Host."
                        $HostFlag = "True"
                    }
                    # Use continue to skip this test and go to the next loop iteration
                    continue
                }
            }

            # If the scope matches VM, but the VM object is null, warn end user and skip tests
            # This should only warn the first time through
            if ($Scope -match 'VM') {
                if ($VM -eq $null) {
                    if ($VMFlag -eq "False") {
                        # Write warning to show that all tests for VM scope were skipped
                        Write-Warning "VM has null value, skipping tests that rely on VM."
                        $VMFlag = "True"
                    }
                    # Use continue to skip this test and go to the next loop iteration
                    continue
                }
            }

            # If the scope matches Network, but the Network object is null, warn end user and skip tests
            # This should only warn the first time through
            if ($Scope -match 'Network') {
                if ($Network -eq $null) {
                    if ($NetworkFlag -eq "False") {
                        # Write warning to show that all tests for Network scope were skipped
                        Write-Warning "Network has null value, skipping tests that rely on Network."
                        $NetworkFlag = "True"
                    }
                    # Use continue to skip this test and go to the next loop iteration
                    continue
                }
            }
        } #IfScopeNotMatch

        # Check for non-core modules only as tests require them
        # Will need to be revisited as more tests added & more modules required...
        # ...maybe don't care about this at all and let it fail naturally?
        If ($Scope -eq 'Network' -and (Get-Module VMware.VimAutomation.Vds) -eq $null) {
            Try {
                Import-Module VMware.VimAutomation.Vds -ErrorAction Stop
            } Catch {
                Write-Warning 'Failed to import PowerCLI module "VMware.VimAutomation.Vds"'
                Write-Warning "Skipping network test $TestName"
                # Use continue to skip this test and go to the next loop iteration
                continue
            }
        }

        Describe -Name "$Scope Configuration: $TestName" -Fixture {
            # Pull in $Title/$Description/$Desired/$Type/$Actual/$Fix from the test file
            . $Test

            # Pump the brakes if the config value is $null
            If ($Desired -eq $null) {
                Write-Verbose "Due to null config value, skipping test $TestName"
                # Use continue to skip this test and go to the next loop iteration
                continue
            } Else {
                # Use $Scope (parent folder) to get the correct objects to test against
                # If changing values here, update the "$Scope -notmatch" test above as well
                $InventoryList = switch ($Scope) {
                    'vCenter'    {$cfg.vcenter.vc}
                    'Datacenter' {$Datacenter}
                    'Cluster'    {$Cluster}
                    'DSCluster'  {$DSCluster}
                    'Host'       {$VMHost}
                    'VM'         {$VM}
                    'Network'    {$Network}
                }
            } #If Desired

            If ($InventoryList -eq $null) {
                Write-Verbose "No objects found in scope $Scope, skipping test $TestName"
                # Use continue to skip this test and go to the next loop iteration
                continue
            }

            ForEach ($Object in $InventoryList) {
                Write-Verbose "Processing $($Object.Name) within test $TestName"

                It -Name "$Scope $($Object.Name) - $Title" -Test {
                    Try {
                        # "& $Actual" is running the first script block to compare to $Desired
                        # The comparison should be empty
                        # (meaning everything is the same, as expected)
                        Compare-Object -ReferenceObject $Desired -DifferenceObject (& $Actual -as $Type) |
                            Should BeNullOrEmpty
                    } Catch {
                        # If the comparison found something different,
                        # Then check if we're going to fix it
                        If ($Remediate) {
                            Write-Warning -Message $_
                            # -WhatIf support wraps the command that would change values
                            If ($PSCmdlet.ShouldProcess("vCenter '$($cfg.vcenter.vc)' - $Scope '$Object'", "Set '$Title' value to '$Desired'")) {
                                Write-Warning -Message "Remediating $Object"
                                # Execute the $Fix script block
                                & $Fix
                            }
                        } Else {
                            # -Remediate is not active, so just report the error
                            throw $_
                        }
                    } #Try/Catch
                } #It
            } #ForEach Object
        } #Describe
    } #ForEach Test
}
