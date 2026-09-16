# ============================================================
#  NFS CLI V2 - config.ps1
#  Configuration manager & settings interface
# ============================================================

$script:NFS_CONFIG = $null
$script:NFS_VERSION_INFO = $null

function Get-NFSConfigPath {
    $candidates = @()
    if ($script:NFS_ROOT) {
        $candidates += Join-Path $script:NFS_ROOT "assets\configs\config.json"
    }
    if ($PSScriptRoot) {
        $candidates += Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) "assets\configs\config.json"
    }
    $candidates += "assets\configs\config.json"

    foreach ($p in $candidates) {
        if (Test-Path $p) { return $p }
    }
    return (Join-Path $script:NFS_ROOT "assets\configs\config.json")
}

function Get-NFSVersionPath {
    $candidates = @()
    if ($script:NFS_ROOT) {
        $candidates += Join-Path $script:NFS_ROOT "assets\configs\version.json"
    }
    if ($PSScriptRoot) {
        $candidates += Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) "assets\configs\version.json"
    }
    $candidates += "assets\configs\version.json"

    foreach ($p in $candidates) {
        if (Test-Path $p) { return $p }
    }
    return (Join-Path $script:NFS_ROOT "assets\configs\version.json")
}

function Load-NFSConfig {
    $defaultConfig = [PSCustomObject]@{
        animations      = "full"
        animation_speed = "normal"
        update_check    = $true
        update_channel  = "stable"
        logging         = $true
        theme           = "nfs-neon"
    }

    $path = Get-NFSConfigPath
    if (Test-Path $path) {
        try {
            $json = Get-Content $path -Raw -Encoding UTF8 | ConvertFrom-Json
            # Merge with defaults to ensure all keys exist
            if (-not $json.animations)      { $json | Add-Member -NotePropertyName "animations" -NotePropertyValue $defaultConfig.animations }
            if (-not $json.animation_speed) { $json | Add-Member -NotePropertyName "animation_speed" -NotePropertyValue $defaultConfig.animation_speed }
            if ($null -eq $json.update_check) { $json | Add-Member -NotePropertyName "update_check" -NotePropertyValue $defaultConfig.update_check }
            if (-not $json.update_channel)  { $json | Add-Member -NotePropertyName "update_channel" -NotePropertyValue $defaultConfig.update_channel }
            if ($null -eq $json.logging)    { $json | Add-Member -NotePropertyName "logging" -NotePropertyValue $defaultConfig.logging }
            if (-not $json.theme)           { $json | Add-Member -NotePropertyName "theme" -NotePropertyValue $defaultConfig.theme }
            $script:NFS_CONFIG = $json
            return $script:NFS_CONFIG
        } catch {
            Write-NFSLog "Failed to parse config.json: $($_.Exception.Message)" -Level "WARN"
        }
    }

    $script:NFS_CONFIG = $defaultConfig
    Save-NFSConfig
    return $script:NFS_CONFIG
}

function Save-NFSConfig {
    try {
        $path = Get-NFSConfigPath
        $dir = Split-Path $path -Parent
        if (-not (Test-Path $dir)) { New-Item -Path $dir -ItemType Directory -Force | Out-Null }
        $jsonStr = $script:NFS_CONFIG | ConvertTo-Json -Depth 4
        [System.IO.File]::WriteAllText($path, $jsonStr, [System.Text.Encoding]::UTF8)
        Write-NFSLog "Configuration saved successfully." -Level "INFO"
        return $true
    } catch {
        Write-NFSLog "Failed to save configuration: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

function Load-NFSVersion {
    $path = Get-NFSVersionPath
    if (Test-Path $path) {
        try {
            $script:NFS_VERSION_INFO = Get-Content $path -Raw -Encoding UTF8 | ConvertFrom-Json
            return $script:NFS_VERSION_INFO
        } catch {
            Write-NFSLog "Failed to parse version.json: $($_.Exception.Message)" -Level "WARN"
        }
    }
    $script:NFS_VERSION_INFO = [PSCustomObject]@{
        version     = "2.0.0"
        build       = 200
        releaseDate = "2026-09-15"
        productName = "NFS Programmer CLI"
        tagline     = "Windows Developer & System Engineering Toolkit"
        repository  = "nfsprogramming/nfs-cli"
        channel     = "stable"
    }
    return $script:NFS_VERSION_INFO
}

function Show-SettingsMenu {
    while ($true) {
        Clear-Host
        Write-Section "SETTINGS & PREFERENCES"
        Write-Host ""

        $cfg = $script:NFS_CONFIG
        $animStatus = switch ($cfg.animations) {
            "full"    { "Full (All effects)" }
            "minimal" { "Minimal (Fast text)" }
            "none"    { "Disabled (Instant)" }
            default   { $cfg.animations }
        }
        $speedStatus = if ($cfg.animation_speed -eq "fast") { "Fast" } else { "Normal" }
        $updateStatus = if ($cfg.update_check) { "Enabled" } else { "Disabled" }
        $logStatus = if ($cfg.logging) { "Enabled" } else { "Disabled" }

        Write-Host ""
        Write-Host "  :: SETTINGS & TERMINAL APPEARANCE" -ForegroundColor Cyan
        Write-Host ("  " + ("=" * 70)) -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "  PREFERENCES" -ForegroundColor Yellow
        Write-Host "    [1] " -ForegroundColor Cyan -NoNewline; Write-Host ("Startup Animation    : {0}" -f $animStatus) -ForegroundColor White
        Write-Host "    [2] " -ForegroundColor Cyan -NoNewline; Write-Host ("Animation Speed      : {0}" -f $speedStatus) -ForegroundColor White
        Write-Host "    [3] " -ForegroundColor Cyan -NoNewline; Write-Host ("Auto Update Check    : {0}" -f $updateStatus) -ForegroundColor White
        Write-Host "    [4] " -ForegroundColor Cyan -NoNewline; Write-Host ("Update Channel       : {0}" -f $cfg.update_channel) -ForegroundColor White
        Write-Host "    [5] " -ForegroundColor Cyan -NoNewline; Write-Host ("Operation Logging    : {0}" -f $logStatus) -ForegroundColor White
        Write-Host "    [6] " -ForegroundColor Cyan -NoNewline; Write-Host ("Interface Theme      : {0}" -f $cfg.theme) -ForegroundColor White
        Write-Host ""
        Write-Host "  UTILITIES" -ForegroundColor Yellow
        Write-Host "    [7] " -ForegroundColor Cyan -NoNewline; Write-Host "View Application Logs" -ForegroundColor White
        Write-Host "    [8] " -ForegroundColor Yellow -NoNewline; Write-Host "Reset to Defaults" -ForegroundColor White
        Write-Host ""
        Write-Host "  NAVIGATION" -ForegroundColor Yellow
        Write-Host "    [B] " -ForegroundColor DarkGray -NoNewline; Write-Host "Back" -ForegroundColor White
        Write-Host ("  " + ("=" * 70)) -ForegroundColor DarkCyan
        Write-Host ""

        Write-Host "  >> Select option: " -ForegroundColor Cyan -NoNewline
        $choice = (Read-Host).Trim().ToUpper()
        switch ($choice) {
            "1" {
                Write-Host ""
                Write-Host "  [1] Full Animation  [2] Minimal Animation  [3] No Animation (Instant)" -ForegroundColor Yellow
                $a = Read-Host "  Select"
                if ($a -eq "1") { $cfg.animations = "full" }
                elseif ($a -eq "2") { $cfg.animations = "minimal" }
                elseif ($a -eq "3") { $cfg.animations = "none" }
                Save-NFSConfig
            }
            "2" {
                $cfg.animation_speed = if ($cfg.animation_speed -eq "fast") { "normal" } else { "fast" }
                Save-NFSConfig
            }
            "3" {
                $cfg.update_check = -not $cfg.update_check
                Save-NFSConfig
            }
            "4" {
                $cfg.update_channel = if ($cfg.update_channel -eq "stable") { "beta" } else { "stable" }
                Save-NFSConfig
            }
            "5" {
                $cfg.logging = -not $cfg.logging
                Save-NFSConfig
            }
            "6" {
                Write-Host ""
                Write-Host "  [1] NFS Neon (Default)  [2] Monochrome Tech  [3] Matrix Green" -ForegroundColor Yellow
                $t = Read-Host "  Select"
                if ($t -eq "1") { $cfg.theme = "nfs-neon" }
                elseif ($t -eq "2") { $cfg.theme = "monochrome" }
                elseif ($t -eq "3") { $cfg.theme = "matrix" }
                Save-NFSConfig
            }
            "7" {
                Clear-Host
                Write-Section "RECENT APPLICATION LOGS"
                $lines = Get-NFSLogLines -Target "app" -Tail 30
                if ($lines) {
                    $lines | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }
                } else {
                    Write-Host "  No logs recorded yet." -ForegroundColor DarkGray
                }
                Pause-Menu
            }
            "8" {
                $confirm = Read-Host "  Reset configuration to default? (Y/N)"
                if ($confirm.ToUpper() -eq "Y") {
                    $cfg.animations = "full"
                    $cfg.animation_speed = "normal"
                    $cfg.update_check = $true
                    $cfg.update_channel = "stable"
                    $cfg.logging = $true
                    $cfg.theme = "nfs-neon"
                    Save-NFSConfig
                    Write-Success "Settings reset to defaults."
                    Start-Sleep 1
                }
            }
            "B" { return }
            default { Write-Warn "Invalid choice." ; Start-Sleep 1 }
        }
    }
}
