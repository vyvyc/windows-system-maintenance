[CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
param(
    [Parameter(Mandatory)]
    [string[]]$ServiceName,

    [Parameter(Mandatory)]
    [ValidateSet("Automatic", "Manual", "Disabled")]
    [string]$StartMode,

    [switch]$StopNow
)

$ErrorActionPreference = "Stop"
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
if (-not $WhatIfPreference -and -not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "Run this script from an elevated PowerShell session."
}

foreach ($name in $ServiceName) {
    $service = Get-Service -Name $name -ErrorAction SilentlyContinue
    if (-not $service) {
        Write-Warning "Service not found: $name"
        continue
    }

    $before = [pscustomobject]@{
        Name = $service.Name
        Status = $service.Status
        StartType = $service.StartType
    }

    if (-not $PSCmdlet.ShouldProcess($name, "Set startup to $StartMode$(if ($StopNow) { ' and stop now' } else { '' })")) {
        continue
    }

    if ($StopNow -and $service.Status -ne "Stopped") {
        try {
            Stop-Service -Name $name -Force
        } catch {
            Write-Warning "Could not stop ${name}: $($_.Exception.Message)"
        }
    }

    Set-Service -Name $name -StartupType $StartMode
    $after = Get-Service -Name $name

    [pscustomobject]@{
        Name = $name
        BeforeStatus = $before.Status
        BeforeStartType = $before.StartType
        AfterStatus = $after.Status
        AfterStartType = $after.StartType
    }
}
