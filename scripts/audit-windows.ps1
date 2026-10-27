[CmdletBinding()]
param(
    [string[]]$DriveLetters = @(),
    [int]$TopDirectories = 30,
    [double]$LargeFileGB = 1,
    [string]$OutputPath
)

$ErrorActionPreference = "SilentlyContinue"
$largeFileBytes = [int64]($LargeFileGB * 1GB)

function Get-TreeStats {
    param(
        [string]$Root,
        [int64]$LargeThreshold = 0
    )

    $bytes = [int64]0
    $fileCount = [int64]0
    $largeFiles = [System.Collections.Generic.List[object]]::new()
    $directories = [System.Collections.Generic.Stack[string]]::new()
    $directories.Push($Root)

    while ($directories.Count -gt 0) {
        $directory = $directories.Pop()

        try {
            foreach ($filePath in [System.IO.Directory]::EnumerateFiles($directory)) {
                try {
                    $file = [System.IO.FileInfo]::new($filePath)
                    $fileCount++
                    $bytes += $file.Length
                    if ($file.Length -ge $LargeThreshold -and $LargeThreshold -gt 0) {
                        $largeFiles.Add([pscustomobject]@{
                            Path = $file.FullName
                            Bytes = [int64]$file.Length
                            LastWriteTime = $file.LastWriteTime
                        })
                    }
                } catch {}
            }
        } catch {}

        try {
            foreach ($childPath in [System.IO.Directory]::EnumerateDirectories($directory)) {
                try {
                    $attributes = [System.IO.File]::GetAttributes($childPath)
                    if (-not ($attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
                        $directories.Push($childPath)
                    }
                } catch {}
            }
        } catch {}
    }

    [pscustomobject]@{
        Path = $Root
        Bytes = $bytes
        GB = [math]::Round($bytes / 1GB, 2)
        Files = $fileCount
        LargeFiles = $largeFiles
    }
}

function Add-Candidate {
    param(
        [System.Collections.Generic.List[object]]$List,
        [string]$Label,
        [string]$Path,
        [string]$Category
    )

    if (-not $Path -or -not (Test-Path -LiteralPath $Path)) {
        return
    }

    $stats = Get-TreeStats -Root $Path
    $List.Add([pscustomobject]@{
        Label = $Label
        Path = $Path
        Category = $Category
        Bytes = $stats.Bytes
        GB = $stats.GB
        Files = $stats.Files
    })
}

$volumes = Get-Volume |
    Where-Object {
        $_.DriveLetter -and
        $_.DriveType -eq "Fixed" -and
        $_.HealthStatus -eq "Healthy" -and
        ($DriveLetters.Count -eq 0 -or $_.DriveLetter -in $DriveLetters)
    } |
    Sort-Object DriveLetter

$volumeRows = foreach ($volume in $volumes) {
    [pscustomobject]@{
        DriveLetter = [string]$volume.DriveLetter
        Label = $volume.FileSystemLabel
        FileSystem = $volume.FileSystem
        SizeGB = [math]::Round($volume.Size / 1GB, 2)
        UsedGB = [math]::Round(($volume.Size - $volume.SizeRemaining) / 1GB, 2)
        FreeGB = [math]::Round($volume.SizeRemaining / 1GB, 2)
        FreePercent = if ($volume.Size) {
            [math]::Round(($volume.SizeRemaining / $volume.Size) * 100, 1)
        } else {
            0
        }
    }
}

$topLevel = [System.Collections.Generic.List[object]]::new()
$largeFiles = [System.Collections.Generic.List[object]]::new()

foreach ($volume in $volumes) {
    $rootPath = "$($volume.DriveLetter):\"
    Write-Host "Scanning $rootPath"
    Get-ChildItem -LiteralPath $rootPath -Force -Directory -ErrorAction SilentlyContinue |
        Where-Object { -not ($_.Attributes -band [System.IO.FileAttributes]::ReparsePoint) } |
        ForEach-Object {
            $stats = Get-TreeStats -Root $_.FullName -LargeThreshold $largeFileBytes
            $topLevel.Add([pscustomobject]@{
                DriveLetter = [string]$volume.DriveLetter
                Path = $stats.Path
                Bytes = $stats.Bytes
                GB = $stats.GB
                Files = $stats.Files
            })
            foreach ($largeFile in $stats.LargeFiles) {
                $largeFiles.Add([pscustomobject]@{
                    DriveLetter = [string]$volume.DriveLetter
                    Path = $largeFile.Path
                    Bytes = [int64]$largeFile.Bytes
                    GB = [math]::Round($largeFile.Bytes / 1GB, 2)
                    LastWriteTime = $largeFile.LastWriteTime
                })
            }
        }
}

$homePath = [Environment]::GetFolderPath("UserProfile")
$localAppData = [Environment]::GetFolderPath("LocalApplicationData")
$roamingAppData = [Environment]::GetFolderPath("ApplicationData")
$windowsPath = $env:WINDIR
$candidates = [System.Collections.Generic.List[object]]::new()

Add-Candidate $candidates "User temporary files" (Join-Path $localAppData "Temp") "Regenerable"
Add-Candidate $candidates "Windows temporary files" (Join-Path $windowsPath "Temp") "Regenerable"
Add-Candidate $candidates "Recycle Bin" "C:\`$Recycle.Bin" "Regenerable"
Add-Candidate $candidates "Windows Update download cache" (Join-Path $windowsPath "SoftwareDistribution\Download") "Regenerable"
Add-Candidate $candidates "Delivery Optimization cache" (Join-Path $windowsPath "SoftwareDistribution\DeliveryOptimization") "Regenerable"
Add-Candidate $candidates "Windows Error Reporting" "C:\ProgramData\Microsoft\Windows\WER" "Regenerable"
Add-Candidate $candidates "Crash dumps" (Join-Path $localAppData "CrashDumps") "Regenerable"
Add-Candidate $candidates "Thumbnail and icon cache" (Join-Path $localAppData "Microsoft\Windows\Explorer") "Regenerable"
Add-Candidate $candidates "npm cache" (Join-Path $localAppData "npm-cache") "Regenerable"
Add-Candidate $candidates "Hugging Face model cache" (Join-Path $homePath ".cache\huggingface") "Rebuild cost"
Add-Candidate $candidates "Gradle dependency cache" (Join-Path $homePath ".gradle\caches") "Rebuild cost"
Add-Candidate $candidates "JetBrains local caches" (Join-Path $localAppData "JetBrains") "Rebuild cost"
Add-Candidate $candidates "NVIDIA update artifacts" "C:\ProgramData\NVIDIA Corporation\NVIDIA app\UpdateFramework\ota-artifacts" "Regenerable"
Add-Candidate $candidates "LGHUB cache" "C:\ProgramData\LGHUB\cache" "Regenerable"
Add-Candidate $candidates "LGHUB depots" "C:\ProgramData\LGHUB\depots" "Regenerable"
Add-Candidate $candidates "Windows Installer cache" (Join-Path $windowsPath "Installer") "Protected"
Add-Candidate $candidates "Application package cache" "C:\ProgramData\Package Cache" "Protected"

$browserRoots = @(
    @{ Name = "Chrome"; Path = Join-Path $localAppData "Google\Chrome\User Data" },
    @{ Name = "Edge"; Path = Join-Path $localAppData "Microsoft\Edge\User Data" }
)
foreach ($browser in $browserRoots) {
    if (-not (Test-Path -LiteralPath $browser.Path)) {
        continue
    }
    Get-ChildItem -LiteralPath $browser.Path -Force -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -eq "Default" -or $_.Name -like "Profile *" } |
        ForEach-Object {
            $profile = $_
            foreach ($cacheName in @("Cache", "Code Cache", "Service Worker", "GPUCache")) {
                Add-Candidate $candidates "$($browser.Name) $($profile.Name) $cacheName" (Join-Path $profile.FullName $cacheName) "Regenerable"
            }
        }
}

$candidateIndex = 0
$protectedIndex = 0
$reviewCandidates = foreach ($candidate in ($candidates | Sort-Object Bytes -Descending)) {
    if ($candidate.Category -eq "Protected") {
        $protectedIndex++
        $reviewId = "P{0:D3}" -f $protectedIndex
        $disposition = "Protected"
    } else {
        $candidateIndex++
        $reviewId = "C{0:D3}" -f $candidateIndex
        $disposition = "Ready"
    }

    [pscustomobject]@{
        ReviewId = $reviewId
        Label = $candidate.Label
        Path = $candidate.Path
        Category = $candidate.Category
        Disposition = $disposition
        Bytes = $candidate.Bytes
        GB = $candidate.GB
        Files = $candidate.Files
    }
}

$report = [pscustomobject]@{
    ReviewSetId = [guid]::NewGuid().ToString()
    GeneratedAt = Get-Date
    Volumes = @($volumeRows)
    TopLevelDirectories = @($topLevel | Sort-Object Bytes -Descending | Select-Object -First $TopDirectories)
    KnownCleanupCandidates = @($reviewCandidates)
    LargeFiles = @($largeFiles | Sort-Object Bytes -Descending | Select-Object -First 100)
}

$report.Volumes | Format-Table -AutoSize
$report.TopLevelDirectories | Select-Object DriveLetter, Path, GB, Files | Format-Table -AutoSize
$report.KnownCleanupCandidates | Select-Object ReviewId, Disposition, Label, Category, Path, GB, Files | Format-Table -Wrap -AutoSize
$report.LargeFiles | Select-Object DriveLetter, Path, GB, LastWriteTime | Format-Table -Wrap -AutoSize

if ($OutputPath) {
    $parent = Split-Path -Parent $OutputPath
    if ($parent) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    $report | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
    Write-Host "JSON report: $OutputPath"
}
