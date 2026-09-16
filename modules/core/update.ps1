# ============================================================
#  NFS CLI V2 - update.ps1
#  Defensive update engine, GitHub Releases check & Rollback
# ============================================================

$script:NFS_LATEST_RELEASE = $null
$script:NFS_LAST_CHECK_RESULT = $null

function ConvertTo-SemVer {
    param([string]$VersionString)
    # Strip leading 'v' or 'V'
    $v = $VersionString.TrimStart('v', 'V').Trim()
    # Normalize e.g. "2" -> "2.0.0", "2.1" -> "2.1.0"
    $parts = $v.Split('.')
    $major = if ($parts.Length -gt 0 -and [int]::TryParse($parts[0], [ref]$null)) { [int]$parts[0] } else { 0 }
    $minor = if ($parts.Length -gt 1 -and [int]::TryParse($parts[1], [ref]$null)) { [int]$parts[1] } else { 0 }
    $patch = if ($parts.Length -gt 2 -and [int]::TryParse($parts[2], [ref]$null)) { [int]$parts[2] } else { 0 }
    return [System.Version]::new($major, $minor, $patch)
}

function Compare-SemVer {
    param(
        [string]$CurrentVersion,
        [string]$LatestVersion
    )
    $vCur = ConvertTo-SemVer $CurrentVersion
    $vLat = ConvertTo-SemVer $LatestVersion
    return $vLat.CompareTo($vCur) # > 0 means Latest is newer than Current
}

function Check-NFSUpdate {
    param(
        [switch]$Silent,
        [int]$TimeoutSec = 2
    )

    $verInfo = if ($script:NFS_VERSION_INFO) { $script:NFS_VERSION_INFO } else { Load-NFSVersion }
    $curVer = $verInfo.version
    $repo = if ($verInfo.repository) { $verInfo.repository } else { "nfsprogramming/nfs-cli" }

    Write-NFSLog "Checking for updates against repo $repo (Current: $curVer)..." -Target "update"

    $result = [PSCustomObject]@{
        ok              = $false
        hasUpdate       = $false
        currentVersion  = $curVer
        latestVersion   = $curVer
        releaseNotes    = ""
        downloadUrl     = ""
        message         = ""
    }

    try {
        $apiUrl = "https://api.github.com/repos/$repo/releases/latest"
        
        # Fast non-blocking request with timeout
        $req = [System.Net.HttpWebRequest]::Create($apiUrl)
        $req.Timeout = $TimeoutSec * 1000
        $req.UserAgent = "NFS-Programmer-CLI/$curVer"
        $req.Accept = "application/vnd.github.v3+json"

        $resp = $req.GetResponse()
        $reader = [System.IO.StreamReader]::new($resp.GetResponseStream())
        $content = $reader.ReadToEnd()
        $reader.Close()
        $resp.Close()

        $release = $content | ConvertFrom-Json
        $script:NFS_LATEST_RELEASE = $release

        $tag = $release.tag_name
        if (-not $tag) { $tag = $release.name }
        $latestVer = ($tag -replace '^[vV]', '').Trim()

        $cmp = Compare-SemVer $curVer $latestVer
        $result.ok = $true
        $result.latestVersion = $latestVer
        $result.releaseNotes = if ($release.body) { $release.body } else { "No release notes provided." }
        
        # Look for zipball or zip asset
        $zipAsset = $release.assets | Where-Object { $_.name -like "*.zip" } | Select-Object -First 1
        if ($zipAsset) {
            $result.downloadUrl = $zipAsset.browser_download_url
        } elseif ($release.zipball_url) {
            $result.downloadUrl = $release.zipball_url
        } else {
            $result.downloadUrl = "https://github.com/$repo/archive/refs/heads/main.zip"
        }

        if ($cmp -gt 0) {
            $result.hasUpdate = $true
            $result.message = "Update available: v$latestVer"
            Write-NFSLog "New version found: v$latestVer (Current: v$curVer)" -Target "update"
        } else {
            $result.hasUpdate = $false
            $result.message = "NFS Programmer CLI is up to date"
            Write-NFSLog "Application is up to date." -Target "update"
        }
    } catch {
        $result.ok = $false
        $result.message = "Update check unavailable (Offline)"
        Write-NFSLog "Update check failed/offline: $($_.Exception.Message)" -Target "update" -Level "WARN"
    }

    $script:NFS_LAST_CHECK_RESULT = $result
    return $result
}

function Show-UpdateBanner {
    param([object]$CheckResult)
    if (-not $CheckResult -or -not $CheckResult.hasUpdate) { return }

    Write-Host ""
    Write-Host "  :: UPDATE AVAILABLE" -ForegroundColor Yellow
    Write-Host ("  " + ("=" * 70)) -ForegroundColor DarkYellow
    Write-Host "  Installed : v$($CheckResult.currentVersion)   Latest : v$($CheckResult.latestVersion)" -ForegroundColor White
    
    # Show first 3 bullets of notes
    $lines = $CheckResult.releaseNotes -split "`r?`n" | Where-Object { $_ -match "^\s*[-*•]" } | Select-Object -First 3
    if ($lines) {
        Write-Host ""
        Write-Host "  Highlights:" -ForegroundColor Cyan
        foreach ($l in $lines) {
            $trimmed = $l.Trim()
            if ($trimmed.Length -gt 60) { $trimmed = $trimmed.Substring(0, 57) + "..." }
            Write-Host "    $trimmed" -ForegroundColor Gray
        }
    }

    Write-Host ""
    Write-Host "  [U] Update Now    [V] View Changes    [S] Skip" -ForegroundColor Yellow
    Write-Host ("  " + ("=" * 70)) -ForegroundColor DarkYellow
    Write-Host ""

    Write-Host "  >> Select update option: " -ForegroundColor Yellow -NoNewline
    $choice = (Read-Host).Trim().ToUpper()
    if ($choice -eq "U") {
        Invoke-NFSUpdate
    } elseif ($choice -eq "V") {
        Show-NFSChangelog
    }
}

function Invoke-NFSUpdate {
    Write-Section "NFS SAFE UPDATE ENGINE"
    Write-NFSLog "Starting safe update procedure..." -Target "update"

    $check = if ($script:NFS_LAST_CHECK_RESULT -and $script:NFS_LAST_CHECK_RESULT.ok) {
        $script:NFS_LAST_CHECK_RESULT
    } else {
        Check-NFSUpdate -TimeoutSec 5
    }

    if (-not $check.ok) {
        Write-Err "Cannot reach update server. Check your network connection."
        Pause-Menu
        return
    }

    if (-not $check.hasUpdate) {
        Write-Success "You are already running the latest version (v$($check.currentVersion))."
        Write-Host "  Do you want to re-install / force update anyway? (Y/N)" -ForegroundColor Yellow
        $force = Read-Host "  >"
        if ($force.Trim().ToUpper() -ne "Y") {
            Pause-Menu
            return
        }
    }

    $appRoot = $script:NFS_ROOT
    $backupDir = Join-Path $appRoot "backup\v$($check.currentVersion)"
    $tempDir = Join-Path $env:TEMP "nfs_update_$([Guid]::NewGuid().ToString().Substring(0,8))"

    try {
        Write-Step "1. Preparing directories..."
        if (-not (Test-Path $tempDir)) { New-Item -Path $tempDir -ItemType Directory -Force | Out-Null }

        Write-Step "2. Downloading update package..."
        $zipFile = Join-Path $tempDir "update.zip"
        $downloadUrl = $check.downloadUrl
        Write-Info "Source: $downloadUrl"
        
        Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile -UseBasicParsing -ErrorAction Stop
        Write-Success "Update downloaded successfully."

        Write-Step "3. Verifying payload integrity..."
        if (-not (Test-Path $zipFile) -or (Get-Item $zipFile).Length -lt 1000) {
            throw "Downloaded package is invalid or corrupted."
        }
        $extractedDir = Join-Path $tempDir "extracted"
        Expand-Archive -Path $zipFile -DestinationPath $extractedDir -Force
        Write-Success "Package verified and extracted."

        # Find repository root inside the extracted directory (GitHub archive wraps in folder)
        $payloadRoot = $extractedDir
        $subDirs = Get-ChildItem -Path $extractedDir -Directory
        if ($subDirs.Count -eq 1 -and (Test-Path (Join-Path $subDirs[0].FullName "main.ps1"))) {
            $payloadRoot = $subDirs[0].FullName
        }

        if (-not (Test-Path (Join-Path $payloadRoot "main.ps1"))) {
            throw "Update package missing entry point main.ps1."
        }

        Write-Step "4. Creating backup of current version..."
        if (Test-Path $backupDir) { Remove-Item $backupDir -Recurse -Force }
        New-Item -Path $backupDir -ItemType Directory -Force | Out-Null

        # Backup modules, assets, scripts
        $itemsToBackup = @("main.ps1", "modules", "assets", "python_scripts")
        foreach ($item in $itemsToBackup) {
            $src = Join-Path $appRoot $item
            if (Test-Path $src) {
                Copy-Item -Path $src -Destination $backupDir -Recurse -Force
            }
        }
        Write-Success "Backup created at: $backupDir"

        Write-Step "5. Applying update files..."
        Copy-Item -Path "$payloadRoot\*" -Destination $appRoot -Recurse -Force
        Write-Success "Files updated."

        Write-Step "6. Verifying updated installation..."
        if (-not (Test-Path (Join-Path $appRoot "main.ps1"))) {
            throw "Verification failed: main.ps1 not found."
        }
        Write-Success "Installation verified."

        Write-NFSLog "Update to v$($check.latestVersion) completed successfully." -Target "update"
        Write-Host ""
        Write-Host "  ======================================================" -ForegroundColor Green
        Write-Host "  UPDATE COMPLETE: NFS Programmer CLI is now v$($check.latestVersion)" -ForegroundColor Green
        Write-Host "  ======================================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "  Press any key to reload the CLI..." -ForegroundColor Yellow
        $null = Read-Host
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$appRoot\main.ps1`""
        exit
    } catch {
        Write-Err "Update failed: $($_.Exception.Message)"
        Write-NFSLog "Update failed: $($_.Exception.Message). Initiating recovery..." -Level "ERROR" -Target "update"

        if (Test-Path $backupDir) {
            Write-Warn "Restoring previous version from backup..."
            try {
                Copy-Item -Path "$backupDir\*" -Destination $appRoot -Recurse -Force
                Write-Success "Rollback successful. Previous version restored."
            } catch {
                Write-Err "Automatic rollback failed: $($_.Exception.Message)"
            }
        }
        Pause-Menu
    } finally {
        if (Test-Path $tempDir) {
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

function Invoke-NFSRollback {
    Write-Section "ROLLBACK TO PREVIOUS VERSION"
    $appRoot = $script:NFS_ROOT
    $backupRoot = Join-Path $appRoot "backup"

    if (-not (Test-Path $backupRoot)) {
        Write-Warn "No backup directory found at: $backupRoot"
        Pause-Menu
        return
    }

    $backups = Get-ChildItem -Path $backupRoot -Directory
    if (-not $backups) {
        Write-Warn "No backups available for restoration."
        Pause-Menu
        return
    }

    Write-Host "  Available Backups:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $backups.Count; $i++) {
        Write-Host "  [$($i+1)] $($backups[$i].Name)" -ForegroundColor White
    }
    Write-Host "  [B] Cancel" -ForegroundColor DarkGray
    Write-Host ""

    $choice = (Read-Host "  Select backup to restore").Trim().ToUpper()
    if ($choice -eq "B") { return }

    if ([int]::TryParse($choice, [ref]$idx) -and $idx -ge 1 -and $idx -le $backups.Count) {
        $selectedBackup = $backups[$idx - 1]
        Write-Warn "This will restore files from $($selectedBackup.Name) over your current installation."
        $confirm = (Read-Host "  Continue rollback? (Y/N)").Trim().ToUpper()
        if ($confirm -eq "Y") {
            try {
                Copy-Item -Path "$($selectedBackup.FullName)\*" -Destination $appRoot -Recurse -Force
                Write-Success "Rollback complete! Reloading CLI..."
                Start-Sleep 1
                Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$appRoot\main.ps1`""
                exit
            } catch {
                Write-Err "Rollback failed: $($_.Exception.Message)"
                Pause-Menu
            }
        }
    } else {
        Write-Warn "Invalid selection."
        Pause-Menu
    }
}

function Show-NFSChangelog {
    param([switch]$NoPause)
    Clear-Host
    Write-Section "CHANGELOG"
    $appRoot = $script:NFS_ROOT
    $clPath = Join-Path $appRoot "CHANGELOG.md"
    if (Test-Path $clPath) {
        Get-Content $clPath -Encoding UTF8 | ForEach-Object {
            if ($_ -match "^#\s") { Write-Host "  $_" -ForegroundColor Red }
            elseif ($_ -match "^##\s") { Write-Host "  $_" -ForegroundColor Yellow }
            elseif ($_ -match "^###\s") { Write-Host "  $_" -ForegroundColor Cyan }
            elseif ($_ -match "^\s*[-*•]") { Write-Host "  $_" -ForegroundColor White }
            else { Write-Host "  $_" -ForegroundColor Gray }
        }
    } else {
        Write-Warn "CHANGELOG.md not found."
    }
    if (-not $NoPause) { Pause-Menu }
}

function Show-UpdateMenu {
    while ($true) {
        Clear-Host
        Write-Section "UPDATE & ROLLBACK CENTER"
        Write-Host ""
        $cur = if ($script:NFS_VERSION_INFO) { $script:NFS_VERSION_INFO.version } else { "2.0.0" }
        Write-Host ""
        Write-Host "  :: UPDATE & ROLLBACK ENGINE" -ForegroundColor Yellow
        Write-Host ("  " + ("=" * 70)) -ForegroundColor DarkYellow
        Write-Host "  Installed Version : v$cur" -ForegroundColor White
        Write-Host ""
        Write-Host "  UPDATE ACTIONS" -ForegroundColor Yellow
        Write-Host "    [1] " -ForegroundColor Cyan -NoNewline; Write-Host "Check for Updates (GitHub Releases)" -ForegroundColor White
        Write-Host "    [2] " -ForegroundColor Green -NoNewline; Write-Host "Install Latest Version Now" -ForegroundColor White
        Write-Host "    [3] " -ForegroundColor Yellow -NoNewline; Write-Host "Rollback to Previous Version" -ForegroundColor White
        Write-Host "    [4] " -ForegroundColor Cyan -NoNewline; Write-Host "View Full Changelog" -ForegroundColor White
        Write-Host "    [5] " -ForegroundColor DarkGray -NoNewline; Write-Host "View Update Logs" -ForegroundColor White
        Write-Host ""
        Write-Host "  NAVIGATION" -ForegroundColor Yellow
        Write-Host "    [B] " -ForegroundColor DarkGray -NoNewline; Write-Host "Back" -ForegroundColor White
        Write-Host ("  " + ("=" * 70)) -ForegroundColor DarkYellow
        Write-Host ""

        Write-Host "  >> Select option: " -ForegroundColor Yellow -NoNewline
        $choice = (Read-Host).Trim().ToUpper()
        switch ($choice) {
            "1" {
                Write-Step "Checking GitHub Releases..."
                $res = Check-NFSUpdate -TimeoutSec 4
                if ($res.ok) {
                    if ($res.hasUpdate) {
                        Write-Host "  [!] A newer version is available: v$($res.latestVersion)" -ForegroundColor Green
                    } else {
                        Write-Success "You are running the latest version."
                    }
                } else {
                    Write-Warn "Unable to reach GitHub update server."
                }
                Pause-Menu
            }
            "2" { Invoke-NFSUpdate }
            "3" { Invoke-NFSRollback }
            "4" { Show-NFSChangelog }
            "5" {
                Clear-Host
                Write-Section "RECENT UPDATE LOGS"
                $lines = Get-NFSLogLines -Target "update" -Tail 30
                if ($lines) {
                    $lines | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }
                } else {
                    Write-Host "  No update logs recorded." -ForegroundColor DarkGray
                }
                Pause-Menu
            }
            "B" { return }
            default { Write-Warn "Invalid option." ; Start-Sleep 1 }
        }
    }
}
