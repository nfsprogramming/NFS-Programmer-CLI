# ============================================================
#  NFS CLI - optimizer.ps1
#  System tweaks, UI personalization, and performance
# ============================================================
. "$PSScriptRoot\helpers.ps1"

function Show-OptimizerMenu {
    while ($true) {
        Clear-Host
        Write-Section "SYSTEM OPTIMIZER"
        Write-Host ""
        Write-Host "  +-----------------------------------------------------+" -ForegroundColor DarkYellow
        Write-Host "  |  PERSONALIZATION                                    |" -ForegroundColor Yellow
        Write-Host "  |  1.  Toggle System Theme (Dark/Light)               |" -ForegroundColor Cyan
        Write-Host "  |  2.  Toggle Taskbar Alignment (Left/Center)         |" -ForegroundColor Cyan
        Write-Host "  |  3.  Toggle Taskbar Size (Small/Medium/Large)       |" -ForegroundColor Cyan
        Write-Host "  |  4.  Toggle Hidden Files Visibility                 |" -ForegroundColor Cyan
        Write-Host "  |  5.  Toggle File Extensions Visibility              |" -ForegroundColor Cyan
        Write-Host "  |  L.  Restore Legacy Context Menu (Win11 Fix)        |" -ForegroundColor Yellow
        Write-Host "  |  R.  Restart Windows Explorer                       |" -ForegroundColor Magenta
        Write-Host "  |                                                     |" -ForegroundColor DarkYellow
        Write-Host "  |  PERFORMANCE & SYSTEM                               |" -ForegroundColor Yellow
        Write-Host "  |  6.  Enable/Activate Ultimate Power Plan            |" -ForegroundColor Red
        Write-Host "  |  7.  Disable Windows Telemetry (Ultra)              |" -ForegroundColor Red
        Write-Host "  |  8.  Disable Start Menu Web Search                  |" -ForegroundColor Cyan
        Write-Host "  |  9.  Clear All Event Logs                          |" -ForegroundColor Cyan
        Write-Host "  |  H.  Toggle Hibernation (Save 2GB+ Space)           |" -ForegroundColor Cyan
        Write-Host "  |  D.  Remove OneDrive Completely (Uninstaller)       |" -ForegroundColor Red
        Write-Host "  |  C.  Deep Clean Temp Files                          |" -ForegroundColor Green
        Write-Host "  |  0.  RESTORE WINDOWS DEFAULTS                      |" -ForegroundColor Yellow
        Write-Host "  |                                                     |" -ForegroundColor DarkGray
        Write-Host "  |  B.  Back                                           |" -ForegroundColor DarkGray
        Write-Host "  +-----------------------------------------------------+" -ForegroundColor DarkYellow
        Write-Host ""
        $choice = (Read-Host "  Select").Trim().ToUpper()

        switch ($choice) {
            "1"  { Invoke-ToggleTheme }
            "2"  { Invoke-ToggleTaskbar }
            "3"  { Invoke-ToggleTaskbarSize }
            "4"  { Invoke-ToggleHiddenFiles }
            "5"  { Invoke-ToggleExtensions }
            "L"  { Invoke-LegacyContext }
            "R"  { Invoke-RestartExplorer }
            "6"  { Invoke-UltimatePower }
            "7"  { Invoke-DisableTelemetry }
            "8"  { Invoke-DisableWebSearch }
            "9"  { Invoke-ClearEventLogs }
            "H"  { Invoke-ToggleHibernation }
            "D"  { Invoke-RemoveOneDrive }
            "C"  { Invoke-CleanTempFiles }
            "0"  { Invoke-RestoreDefaults }
            "B"  { return }
            default { Write-Warn "Invalid option." ; Start-Sleep 1 }
        }
    }
}


function Invoke-RestoreDefaults {
    Write-Section "RESTORE DEFAULTS"
    $confirm = Read-Host "  Reset all personalization & performance to Windows defaults? (Y/N)"
    if ($confirm.ToUpper() -ne "Y") { return }

    try {
        # Theme: Light
        $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
        Set-ItemProperty -Path $path -Name AppsUseLightTheme -Value 1
        Set-ItemProperty -Path $path -Name SystemUsesLightTheme -Value 1
        
        # Taskbar: Center, Medium
        $advPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        Set-ItemProperty -Path $advPath -Name TaskbarAl -Value 1
        Set-ItemProperty -Path $advPath -Name TaskbarSi -Value 1
        
        # Files: Hidden=2 (Hidden), HideExt=1 (Hidden)
        Set-ItemProperty -Path $advPath -Name Hidden -Value 2
        Set-ItemProperty -Path $advPath -Name HideFileExt -Value 1
        
        # Search: Enabled
        $searchPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
        Set-ItemProperty -Path $searchPath -Name "BingSearchEnabled" -Value 1
        Set-ItemProperty -Path $searchPath -Name "CanCortanaConsent" -Value 1

        # Telemetry: Enable
        Write-Step "Re-enabling Telemetry Services..."
        Set-Service DiagTrack -StartupType Automatic -ErrorAction SilentlyContinue
        Start-Service DiagTrack -ErrorAction SilentlyContinue
        
        # Registry: Remove Blocks
        reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /f 2>$null
        reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /f 2>$null
        
        # Power: Back to Balanced
        Write-Step "Restoring Balanced Power Plan..."
        powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e

        Write-Success "System reverted to Windows Defaults."
        Refresh-Explorer
    } catch {
        Write-Err "Restore failed: $($_.Exception.Message)"
    }
    Pause-Menu
}

function Invoke-RestartExplorer {
    Write-Section "RESTART EXPLORER"
    Write-Step "Restarting Windows Explorer..."
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Process explorer.exe
    Write-Success "Explorer restarted."
    Pause-Menu
}

function Invoke-ToggleTheme {
    Write-Section "TOGGLE THEME"
    try {
        $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
        $current = Get-ItemProperty -Path $path -Name AppsUseLightTheme
        $new = if ($current.AppsUseLightTheme -eq 1) { 0 } else { 1 }
        Set-ItemProperty -Path $path -Name AppsUseLightTheme -Value $new
        Set-ItemProperty -Path $path -Name SystemUsesLightTheme -Value $new
        Write-Success "Theme toggled."
        Refresh-Explorer
    } catch {
        Write-Err "Registry error: $($_.Exception.Message)"
    }
    Pause-Menu
}

function Invoke-ToggleTaskbar {
    Write-Section "TASKBAR ALIGNMENT"
    try {
        $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        $current = Get-ItemProperty -Path $path -Name TaskbarAl
        $new = if ($current.TaskbarAl -eq 1) { 0 } else { 1 }
        Set-ItemProperty -Path $path -Name TaskbarAl -Value $new
        Write-Success "Alignment toggled."
        Refresh-Explorer
    } catch {
        Write-Err "Registry error: $($_.Exception.Message)"
    }
    Pause-Menu
}

function Invoke-ToggleTaskbarSize {
    Write-Section "TASKBAR SIZE"
    try {
        $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        $current = Get-ItemProperty -Path $path -Name TaskbarSi -ErrorAction SilentlyContinue
        $val = if ($null -eq $current) { 1 } else { $current.TaskbarSi }
        $new = ($val + 1) % 3
        Set-ItemProperty -Path $path -Name TaskbarSi -Value $new
        Write-Success "Size toggled."
        Refresh-Explorer
    } catch {
        Write-Err "Registry error: $($_.Exception.Message)"
    }
    Pause-Menu
}

function Invoke-ToggleHiddenFiles {
    Write-Section "HIDDEN FILES"
    try {
        $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        $current = Get-ItemProperty -Path $path -Name Hidden
        $new = if ($current.Hidden -eq 1) { 2 } else { 1 }
        Set-ItemProperty -Path $path -Name Hidden -Value $new
        Write-Success "Visibility toggled."
        Refresh-Explorer
    } catch {
        Write-Err "Registry error: $($_.Exception.Message)"
    }
    Pause-Menu
}

function Invoke-ToggleExtensions {
    Write-Section "FILE EXTENSIONS"
    try {
        $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        $current = Get-ItemProperty -Path $path -Name HideFileExt
        $new = if ($current.HideFileExt -eq 1) { 0 } else { 1 }
        Set-ItemProperty -Path $path -Name HideFileExt -Value $new
        Write-Success "Extensions toggled."
        Refresh-Explorer
    } catch {
        Write-Err "Registry error: $($_.Exception.Message)"
    }
    Pause-Menu
}

function Invoke-UltimatePower {
    Write-Section "ULTIMATE PERFORMANCE"
    Write-Step "Checking scheme validity..."
    $guid = "e9a42b02-d5df-448d-aa00-03f14749eb61"
    
    # Validate if it exists or can be duplicated
    if (-not (powercfg -list | Select-String $guid)) {
        Write-Step "Unlocking Ultimate scheme..."
        powercfg -duplicatescheme $guid | Out-Null
    }

    if (-not (powercfg -list | Select-String "Ultimate Performance")) {
        Write-Warn "Ultimate Plan blocked. Trying High Performance fallback..."
        powercfg -duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c | Out-Null
        $guid = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
    }

    Write-Step "Activating plan..."
    powercfg -setactive $guid
    Write-Success "Highest Performance Activated."
    Pause-Menu
}

function Invoke-DisableTelemetry {
    Write-Section "DISABLE TELEMETRY"
    if (-not (Assert-Admin)) { return }
    $confirm = Read-Host "  Apply Ultra Telemetry block? (Y/N)"
    if ($confirm.ToUpper() -ne "Y") { return }

    Write-Step "Stopping services..."
    Stop-Service DiagTrack, dmwappushservice -Force -ErrorAction SilentlyContinue
    Set-Service DiagTrack -StartupType Disabled
    Set-Service dmwappushservice -StartupType Disabled
    
    Write-Step "Applying HKLM Policy blocks..."
    try {
        # Path 1: DataCollection
        $p1 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
        if (-not (Test-Path $p1)) { New-Item $p1 -Force }
        Set-ItemProperty -Path $p1 -Name "AllowTelemetry" -Value 0
        
        # Path 2: Windows\CurrentVersion\Policies\DataCollection
        $p2 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
        if (-not (Test-Path $p2)) { New-Item $p2 -Force }
        Set-ItemProperty -Path $p2 -Name "AllowTelemetry" -Value 0
        
        Write-Success "Ultra Telemetry Block applied."
    } catch {
        Write-Err "Registry error: $($_.Exception.Message)"
    }
    Pause-Menu
}

function Invoke-DisableWebSearch {
    Write-Section "DISABLE WEB SEARCH"
    try {
        $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
        Set-ItemProperty -Path $path -Name "BingSearchEnabled" -Value 0
        Set-ItemProperty -Path $path -Name "CanCortanaConsent" -Value 0
        Write-Success "Web search disabled."
    } catch {
        Write-Err "Registry error: $($_.Exception.Message)"
    }
    Pause-Menu
}

function Invoke-ClearEventLogs {
    Write-Section "CLEAR EVENT LOGS"
    if (-not (Assert-Admin)) { return }
    $confirm = Read-Host "  Clear all logs? (Y/N)"
    if ($confirm.ToUpper() -ne "Y") { return }

    Write-Step "Scanning and clearing logs..."
    # Using ThrottleLimit for better performance on large log sets
    $logs = Get-WinEvent -ListLog * -ErrorAction SilentlyContinue
    foreach ($log in $logs) {
        Write-Indeterminate-Bar "Clearing: $($log.LogName)"
        wevtutil cl $log.LogName
    }
    Write-Success "Logs cleared."
    Pause-Menu
}

function Invoke-LegacyContext {
    Write-Section "LEGACY CONTEXT MENU"
    try {
        $path = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
        if (Test-Path $path) {
            Remove-Item (Split-Path $path -Parent) -Recurse -Force
            Write-Success "Windows 11 Modern menu restored."
        } else {
            New-Item $path -Force | Out-Null
            Set-ItemProperty -Path $path -Name "(Default)" -Value ""
            Write-Success "Legacy Context Menu enabled. Restart Explorer to see changes."
        }
    } catch {
        Write-Err "Registry error: $($_.Exception.Message)"
    }
    Pause-Menu
}

function Invoke-ToggleHibernation {
    Write-Section "TOGGLE HIBERNATION"
    if (-not (Assert-Admin)) { return }
    $status = powercfg /a
    if ($status -like "*Hibernation is not enabled*") {
        Write-Step "Enabling Hibernation..."
        powercfg /hibernate on
        Write-Success "Hibernation enabled."
    } else {
        Write-Step "Disabling Hibernation..."
        powercfg /hibernate off
        Write-Success "Hibernation disabled (Disk space reclaimed)."
    }
    Pause-Menu
}

function Invoke-RemoveOneDrive {
    Write-Section "REMOVE ONEDRIVE"
    if (-not (Assert-Admin)) { return }
    $confirm = Read-Host "  Completely uninstall OneDrive? (Y/N)"
    if ($confirm.ToUpper() -ne "Y") { return }

    Write-Step "Closing OneDrive..."
    taskkill /f /im OneDrive.exe 2>$null
    
    Write-Step "Running Uninstaller..."
    $system64 = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
    $system32 = "$env:SystemRoot\System32\OneDriveSetup.exe"
    
    if (Test-Path $system64) {
        Start-Process $system64 -ArgumentList "/uninstall" -Wait
    } elseif (Test-Path $system32) {
        Start-Process $system32 -ArgumentList "/uninstall" -Wait
    }
    
    Write-Step "Cleaning remnants..."
    Remove-Item "$env:USERPROFILE\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:LOCALAPPDATA\Microsoft\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
    
    Write-Success "OneDrive has been removed."
    Pause-Menu
}

function Invoke-CleanTempFiles {
    Write-Section "DEEP TEMP CLEAN"
    if (-not (Assert-Admin)) { return }
    
    $paths = @(
        "$env:TEMP\*",
        "$env:SystemRoot\Temp\*",
        "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db",
        "$env:LOCALAPPDATA\Microsoft\Windows\WebCache\*",
        "$env:SystemRoot\Prefetch\*"
    )
    
    foreach ($path in $paths) {
        Write-Indeterminate-Bar "Cleaning: $path"
        Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    Write-Success "Temp files and cache cleared."
    Pause-Menu
}
