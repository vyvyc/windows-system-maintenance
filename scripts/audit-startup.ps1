[CmdletBinding()]
param(
    [switch]$IncludeMicrosoftTasks,
    [string]$OutputPath
)

$ErrorActionPreference = "SilentlyContinue"

function Resolve-ExecutablePath {
    param([string]$Command)

    if ([string]::IsNullOrWhiteSpace($Command)) {
        return $null
    }

    $expanded = [Environment]::ExpandEnvironmentVariables($Command)
    if ([System.IO.File]::Exists($expanded)) {
        return $expanded
    }

    $match = [regex]::Match($expanded, '^\s*"([^"]+)"')
    if ($match.Success) {
        return $match.Groups[1].Value
    }

    $match = [regex]::Match($expanded, '^\s*([^\s]+)')
    if ($match.Success) {
        return $match.Groups[1].Value
    }
    return $null
}

function Get-ProcessUsageForExe {
    param(
        [string]$Executable,
        [object[]]$Processes
    )

    if (-not $Executable) {
        return [pscustomobject]@{ ProcessCount = 0; MemoryMB = 0 }
    }

    $matched = foreach ($process in $Processes) {
        try {
            if ($process.Path -and $process.Path.Equals($Executable, [StringComparison]::OrdinalIgnoreCase)) {
                $process
            }
        } catch {}
    }

    [pscustomobject]@{
        ProcessCount = @($matched).Count
        MemoryMB = [math]::Round((($matched | Measure-Object WorkingSet64 -Sum).Sum) / 1MB, 1)
    }
}

function Get-StartupApprovedState {
    $paths = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run32",
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run",
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run32",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\StartupFolder",
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\StartupFolder"
    )

    $result = @{}
    foreach ($path in $paths) {
        if (-not (Test-Path $path)) {
            continue
        }
        $properties = Get-ItemProperty $path
        foreach ($property in ($properties.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' })) {
            $value = $property.Value
            if ($value -is [byte[]] -and $value.Length -gt 0) {
                $state = switch ([int]$value[0]) {
                    2 { "Enabled" }
                    3 { "Disabled" }
                    default { "Unknown" }
                }
                $result[$property.Name] = $state
            }
        }
    }
    return $result
}

$processes = @(Get-Process -ErrorAction SilentlyContinue)
$approved = Get-StartupApprovedState
$entries = [System.Collections.Generic.List[object]]::new()

$runRoots = @(
    @{ Scope = "User"; Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" },
    @{ Scope = "User"; Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce" },
    @{ Scope = "Machine"; Path = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" },
    @{ Scope = "Machine"; Path = "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run" },
    @{ Scope = "Machine"; Path = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" },
    @{ Scope = "Machine"; Path = "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\RunOnce" }
)

foreach ($root in $runRoots) {
    if (-not (Test-Path $root.Path)) {
        continue
    }
    $properties = Get-ItemProperty $root.Path
    foreach ($property in ($properties.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' })) {
        $command = [string]$property.Value
        $executable = Resolve-ExecutablePath -Command $command
        $usage = Get-ProcessUsageForExe -Executable $executable -Processes $processes
        $entries.Add([pscustomobject]@{
            Kind = "Run"
            Scope = $root.Scope
            Name = $property.Name
            State = if ($approved.ContainsKey($property.Name)) { $approved[$property.Name] } else { "No override" }
            Command = $command
            Executable = $executable
            ExecutableExists = if ($executable) { [bool](Test-Path -LiteralPath $executable) } else { $null }
            ProcessCount = $usage.ProcessCount
            MemoryMB = $usage.MemoryMB
        })
    }
}

$startupFolders = @(
    @{ Scope = "User"; Path = [Environment]::GetFolderPath("Startup") },
    @{ Scope = "Machine"; Path = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp" }
)
foreach ($folder in $startupFolders) {
    if (-not $folder.Path -or -not (Test-Path -LiteralPath $folder.Path)) {
        continue
    }
    Get-ChildItem -LiteralPath $folder.Path -Force -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -ne "desktop.ini" } |
        ForEach-Object {
            $entries.Add([pscustomobject]@{
                Kind = "StartupFolder"
                Scope = $folder.Scope
                Name = $_.Name
                State = if ($approved.ContainsKey($_.Name)) { $approved[$_.Name] } else { "No override" }
                Command = $_.FullName
                Executable = $_.FullName
                ExecutableExists = $true
                ProcessCount = 0
                MemoryMB = 0
            })
        }
}

$tasks = Get-ScheduledTask -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Triggers | Where-Object { $_.CimClass.CimClassName -match "LogonTrigger|BootTrigger" }
    }
foreach ($task in $tasks) {
    if (-not $IncludeMicrosoftTasks -and $task.TaskPath -like "\Microsoft\Windows\*") {
        continue
    }

    $actions = @($task.Actions)
    $command = ($actions | ForEach-Object { "$($_.Execute) $($_.Arguments)".Trim() }) -join "; "
    $executable = if ($actions.Count -gt 0) { $actions[0].Execute } else { $null }
    $usage = Get-ProcessUsageForExe -Executable $executable -Processes $processes
    $entries.Add([pscustomobject]@{
        Kind = "ScheduledTask"
        Scope = $task.Principal.UserId
        Name = $task.TaskName
        State = [string]$task.State
        Command = $command
        Executable = $executable
        ExecutableExists = if ($executable) { [bool](Test-Path -LiteralPath $executable) } else { $null }
        ProcessCount = $usage.ProcessCount
        MemoryMB = $usage.MemoryMB
        TaskPath = $task.TaskPath
    })
}

$services = Get-CimInstance Win32_Service |
    Where-Object {
        $_.StartMode -eq "Auto" -and
        $_.PathName -notmatch '(?i)\\Windows\\(System32|SysWOW64|servicing|WinSxS)|\\WindowsApps\\|Microsoft\\Edge|NVIDIA Corporation\\NVIDIA'
    }
foreach ($service in $services) {
    $process = $processes | Where-Object { $_.Id -eq $service.ProcessId } | Select-Object -First 1
    $executable = if ($process -and $process.Path) {
        $process.Path
    } else {
        Resolve-ExecutablePath -Command $service.PathName
    }
    $entries.Add([pscustomobject]@{
        Kind = "AutoService"
        Scope = "Machine"
        Name = $service.Name
        State = if ($service.State -eq "Running") { "Enabled" } else { "Stopped" }
        Command = $service.PathName
        Executable = $executable
        ExecutableExists = if ($executable) { [bool](Test-Path -LiteralPath $executable) } else { $null }
        ProcessCount = if ($process) { 1 } else { 0 }
        MemoryMB = if ($process) { [math]::Round($process.WorkingSet64 / 1MB, 1) } else { 0 }
        StartMode = $service.StartMode
        DelayedAutoStart = $service.DelayedAutoStart
        DisplayName = $service.DisplayName
    })
}

$index = 0
$reviewEntries = foreach ($entry in ($entries | Sort-Object Kind, Scope, Name)) {
    $index++
    $disposition = if ($entry.ExecutableExists -eq $false) {
        "Broken"
    } elseif ($entry.State -eq "Disabled") {
        "No action"
    } else {
        "Needs decision"
    }
    [pscustomobject]@{
        ReviewId = "S{0:D3}" -f $index
        Kind = $entry.Kind
        Scope = $entry.Scope
        Name = $entry.Name
        State = $entry.State
        Disposition = $disposition
        Command = $entry.Command
        Executable = $entry.Executable
        ExecutableExists = $entry.ExecutableExists
        ProcessCount = $entry.ProcessCount
        MemoryMB = $entry.MemoryMB
        TaskPath = $entry.TaskPath
        StartMode = $entry.StartMode
        DelayedAutoStart = $entry.DelayedAutoStart
        DisplayName = $entry.DisplayName
    }
}

$report = [pscustomobject]@{
    ReviewSetId = [guid]::NewGuid().ToString()
    GeneratedAt = Get-Date
    Entries = @($reviewEntries)
}

$report.Entries |
    Select-Object ReviewId, Disposition, Kind, Scope, Name, State, ExecutableExists, ProcessCount, MemoryMB, Command |
    Format-Table -Wrap -AutoSize

if ($OutputPath) {
    $parent = Split-Path -Parent $OutputPath
    if ($parent) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    $report | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
    Write-Host "JSON report: $OutputPath"
}
