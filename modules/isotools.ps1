# ============================================================
#  NFS CLI - isotools.ps1
#  OS Tools: tweaks, cleanup, performance tuning
# ============================================================
. "$PSScriptRoot\helpers.ps1"

function Show-OSToolsMenu {
    while ($true) {
        Clear-Host
        Write-Section "OS TOOLS"
        Write-Host ""
        Write-Host "  -- Privacy & Bloat -------------------------------------" -ForegroundColor DarkYellow
        Write-Host "   1.  Disable Windows Telemetry"     -ForegroundColor Cyan
        Write-Host "   2.  Remove Bloatware Apps"         -ForegroundColor Cyan
        Write-Host "   3.  Disable Xbox Game Bar"         -ForegroundColor Cyan
        Write-Host "   4.  Disable Cortana"               -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  -- Performance -----------------------------------------" -ForegroundColor DarkYellow
        Write-Host "   5.  Set Power Plan to High Performance" -ForegroundColor Cyan
        Write-Host "   6.  Enable Ultimate Performance Mode"   -ForegroundColor Cyan
        Write-Host "   7.  Disable Startup Apps (msconfig)"   -ForegroundColor Cyan
        Write-Host "   8.  Enable Hardware-Accelerated GPU Scheduling (HAGS)" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  -- Appearance ------------------------------------------" -ForegroundColor DarkYellow
        Write-Host "   9.  Show File Extensions in Explorer"  -ForegroundColor Cyan
        Write-Host "  10.  Show Hidden Files"                 -ForegroundColor Cyan
        Write-Host "  11.  Enable Dark Mode"                  -ForegroundColor Cyan
        Write-Host "  12.  Disable Snap Assist"               -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  -- System ----------------------------------------------" -ForegroundColor DarkYellow
        Write-Host "  13.  Create System Restore Point"       -ForegroundColor Cyan
        Write-Host "  14.  Open Disk Cleanup"                 -ForegroundColor Cyan
        Write-Host "  15.  Open Task Scheduler"               -ForegroundColor Cyan
        Write-Host "  16.  Open Group Policy Editor"          -ForegroundColor Cyan
        Write-Host "  17.  Open Registry Editor"              -ForegroundColor Cyan
        Write-Host "  18.  Activate Windows (MAS - Official)" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "   B.  Back"                              -ForegroundColor DarkGray
        Write-Host ""
        $choice = (Read-Host "  Select").Trim().ToUpper()

        switch ($choice) {
            "1"  { Invoke-DisableTelemetry     ; Pause-Menu }
            "2"  { Invoke-RemoveBloatware      ; Pause-Menu }
            "3"  { Invoke-DisableXboxBar       ; Pause-Menu }
            "4"  { Invoke-DisableCortana       ; Pause-Menu }
            "5"  { Invoke-SetHighPerf          ; Pause-Menu }
            "6"  { Invoke-UltimatePerfMode     ; Pause-Menu }
            "7"  { Start-Process msconfig      ; Pause-Menu }
            "8"  { Invoke-EnableHAGS           ; Pause-Menu }
            "9"  { Invoke-ShowExtensions       ; Pause-Menu }
            "10" { Invoke-ShowHiddenFiles      ; Pause-Menu }
            "11" { Invoke-EnableDarkMode       ; Pause-Menu }
            "12" { Invoke-DisableSnapAssist    ; Pause-Menu }
            "13" { Invoke-CreateRestorePoint   ; Pause-Menu }
            "14" { Start-Process cleanmgr      ; Pause-Menu }
            "15" { Start-Process taskschd.msc  ; Pause-Menu }
            "16" { Start-Process gpedit.msc    ; Pause-Menu }
            "17" { Start-Process regedit       ; Pause-Menu }
            "18" { Invoke-OpenMAS              ; Pause-Menu }
            "B"  { return }
            default { Write-Warn "Invalid option."; Start-Sleep 1 }
        }
    }
}

function Invoke-DisableTelemetry {
    Write-Section "DISABLE TELEMETRY"
    if (-not (Assert-Admin)) { return }
    # DiagTrack service
    Stop-Service DiagTrack -Force -ErrorAction SilentlyContinue
    Set-Service  DiagTrack -StartupType Disabled -ErrorAction SilentlyContinue
    # Registry tweaks
    $path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    if (-not (Test-Path $path)) { New-Item $path -Force | Out-Null }
    Set-ItemProperty $path -Name AllowTelemetry -Value 0 -Type DWord
    Write-Success "Telemetry disabled (DiagTrack service stopped & policy set)."
}

function Invoke-RemoveBloatware {
    Write-Section "REMOVE BLOATWARE"
    if (-not (Assert-Admin)) { return }
    $bloat = @(
        "Microsoft.BingNews",
        "Microsoft.BingWeather",
        "Microsoft.GetHelp",
        "Microsoft.Getstarted",
        "Microsoft.MicrosoftSolitaireCollection",
        "Microsoft.People",
        "Microsoft.WindowsFeedbackHub",
        "Microsoft.WindowsMaps",
        "Microsoft.Xbox.TCUI",
        "Microsoft.XboxApp",
        "Microsoft.XboxGameOverlay",
        "Microsoft.XboxIdentityProvider",
        "Microsoft.ZuneMusic",
        "Microsoft.ZuneVideo",
        "king.com.CandyCrushSaga",
        "Disney.37853D22215E2"
    )
    foreach ($pkg in $bloat) {
        Write-Step "Removing $pkg..."
        Get-AppxPackage -Name $pkg -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
    }
    Write-Success "Bloatware removed!"
}

function Invoke-DisableXboxBar {
    Write-Section "DISABLE XBOX GAME BAR"
    Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name AppCaptureEnabled -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty "HKCU:\System\GameConfigStore" -Name GameDVR_Enabled -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Success "Xbox Game Bar disabled."
}

function Invoke-DisableCortana {
    Write-Section "DISABLE CORTANA"
    $path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    if (-not (Test-Path $path)) { New-Item $path -Force | Out-Null }
    Set-ItemProperty $path -Name AllowCortana -Value 0 -Type DWord
    Write-Success "Cortana disabled via policy."
}

function Invoke-SetHighPerf {
    Write-Section "HIGH PERFORMANCE POWER PLAN"
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    Write-Success "Power plan set to: High Performance."
}

function Invoke-UltimatePerfMode {
    Write-Section "ULTIMATE PERFORMANCE"
    powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
    $guid = (powercfg /list | Select-String "Ultimate Performance").Line.Split()[3]
    if ($guid) {
        powercfg /setactive $guid
        Write-Success "Ultimate Performance power plan activated: $guid"
    } else {
        Write-Warn "Could not activate (may already be active). Check Power Options."
    }
}

function Invoke-EnableHAGS {
    Write-Section "HARDWARE-ACCELERATED GPU SCHEDULING"
    $path = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
    Set-ItemProperty $path -Name HwSchMode -Value 2 -Type DWord
    Write-Success "HAGS enabled. Restart your PC for effect."
}

function Invoke-ShowExtensions {
    Write-Section "SHOW FILE EXTENSIONS"
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name HideFileExt -Value 0
    Write-Success "File extensions are now visible."
}

function Invoke-ShowHiddenFiles {
    Write-Section "SHOW HIDDEN FILES"
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name Hidden -Value 1
    Write-Success "Hidden files are now visible."
}

function Invoke-EnableDarkMode {
    Write-Section "ENABLE DARK MODE"
    $path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    Set-ItemProperty $path -Name AppsUseLightTheme   -Value 0
    Set-ItemProperty $path -Name SystemUsesLightTheme -Value 0
    Write-Success "Dark mode enabled."
}

function Invoke-DisableSnapAssist {
    Write-Section "DISABLE SNAP ASSIST"
    $path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Set-ItemProperty $path -Name SnapAssist -Value 0
    Write-Success "Snap Assist disabled."
}

function Invoke-CreateRestorePoint {
    Write-Section "CREATE RESTORE POINT"
    if (-not (Assert-Admin)) { return }
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
    Checkpoint-Computer -Description "NFS CLI Restore Point" -RestorePointType "MODIFY_SETTINGS"
    Write-Success "System Restore Point created."
}

function Invoke-OpenMAS {
    Write-Section "MICROSOFT ACTIVATION SCRIPTS"
    Write-Warn "This opens the OFFICIAL MAS GitHub page (massgrave.dev)"
    Write-Warn "Only use this on machines you legally own."
    Write-Host ""
    $confirm = Read-Host "  Open MAS official site? (Y/N)"
    if ($confirm.ToUpper() -eq "Y") {
        Open-Url "https://massgrave.dev" "Microsoft Activation Scripts"
    }
}

