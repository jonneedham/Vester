#
# Module manifest for module 'Vester'
#
# Generated by: Brian Bunke
#
# Generated on: 8/28/2016
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'Vester.psm1'

# Version number of this module.
ModuleVersion = '1.0.1'

# ID used to uniquely identify this module
GUID = 'cd038486-b669-4edb-a66d-bfe94c61b011'

# Author of this module
Author = 'Chris Wahl'

# Company or vendor of this module
CompanyName = 'Community'

# Copyright statement for this module
Copyright = 'Apache License'

# Description of the functionality provided by this module
Description = 'Check your VMware vSphere environment for undesired values, and automatically fix them. Define settings, then use PowerCLI and Pester to report on and/or remediate any problems discovered.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '3.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @('Pester')

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module
FunctionsToExport = @('Invoke-Vester','New-VesterConfig')

# Cmdlets to export from this module
# CmdletsToExport = '*'

# Variables to export from this module
# VariablesToExport = '*'

# Aliases to export from this module
# AliasesToExport = '*'

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('vester','vmware','vcenter','vsphere','esxi','powercli')

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/WahlNetwork/Vester/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/WahlNetwork/Vester'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # External Module Dependencies
        ExternalModuleDependencies = @('VMware.VimAutomation.Core')

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}
