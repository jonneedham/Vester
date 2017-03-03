﻿# Test file for the Vester module - https://github.com/WahlNetwork/Vester
# Called via Invoke-Pester VesterTemplate.Tests.ps1
# vSphere 6.0 Hardening Guide Guideline ID - VM.disable-unexposed-features-trayicon
# Unexposed features are items that apply to Workstation or Fusion but not vSphere
# Explicitly disabling the settings reduces potential vulnerabilities

# Test title, e.g. 'DNS Servers'
$Title = 'VMX Tray Icon Disable'

# Test description: How New-VesterConfig explains this value to the user
$Description = 'On/Off switch to disable unexposed VMX setting Tray Icon - Recommended setting of True'

# The config entry stating the desired values
$Desired = $cfg.vm.vmxtrayicon

# The test value's data type, to help with conversion: bool/string/int
$Type = 'string'

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
[ScriptBlock]$Actual = {
    (Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
        $_.Name -eq 'isolation.tools.ghi.trayicon.disable'}).Value
}

# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
[ScriptBlock]$Fix = {
    if ((Get-AdvancedSetting -Entity $Object -Name 'isolation.tools.ghi.trayicon.disable') -eq $null) {
        New-AdvancedSetting -Entity $Object -Name 'isolation.tools.ghi.trayicon.disable' -Value $Desired -Confirm:$false -ErrorAction Stop
    } else {
        Get-AdvancedSetting -Entity $Object | Where-Object -FilterScript {
            $_.Name -eq 'isolation.tools.ghi.trayicon.disable'
        } | Set-AdvancedSetting -value $Desired -Confirm:$false -ErrorAction Stop
    }
}
