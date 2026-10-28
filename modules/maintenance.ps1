# ============================================================
#  NFS CLI - maintenance.ps1
#  System health, cleanup, and diagnostics
# ============================================================
. "$PSScriptRoot\helpers.ps1"

function Show-MaintenanceMenu {
    while ($true) {
        Clear-Host
        Write-Section "MAINTENANCE & HEALTH"
        Write-Host ""
        Write-Host "  +-----------------------------------------------------+" -ForegroundColor DarkGreen
        Write-Host "  |  CLEANUP TOOLS                                      |" -ForegroundColor Yellow
        Write-Host "  |  1.  Disk Cleanup (Cleanmgr)                        |" -ForegroundColor Cyan
        Write-Host "  |  2.  Analyze Component Store (WinSXS)               |" -ForegroundColor Cyan
        Write-Host "  |  3.  Start Component Store Cleanup                  |" -ForegroundColor Red
        Write-Host "  |  4.  Clear Prefetch Files                           |" -ForegroundColor Cyan
        Write-Host "  |                                                     |" -ForegroundColor DarkGreen
        Write-Host "  |  DIAGNOSTICS                                        |" -ForegroundColor Yellow
        Write-Host "  |  5.  Run Chkdsk (Read-only)                         |" -ForegroundColor Cyan
        Write-Host "  |  6.  Check Battery Health Report                    |" -ForegroundColor Cyan
        Write-Host "  |  7.  Check Disk Health (SMART)                      |" -ForegroundColor Cyan
        Write-Host "  |  8.  View All Network Profiles                      |" -ForegroundColor Cyan
        Write-Host "  |                                                     |" -ForegroundColor DarkGray
        Write-Host "  |  B.  Back                                           |" -ForegroundColor DarkGray
        Write-Host "  +-----------------------------------------------------+" -ForegroundColor DarkGreen
        Write-Host ""
        $choice = (Read-Host "  Select").Trim().ToUpper()

        switch ($choice) {
            "1"  { Invoke-DiskCleanup }
            "2"  { Invoke-AnalyzeStore }
            "3"  { Invoke-CleanupStore }
            "4"  { Invoke-ClearPrefetch }
            "5"  { Invoke-Chkdsk }
            "6"  { Invoke-BatteryReport }
            "7"  { Invoke-SmartCheck }
            "8"  { Invoke-NetworkProfiles }
            "B"  { return }
            default { Write-Warn "Invalid option." ; Start-Sleep 1 }
        }
    }
}

function Invoke-DiskCleanup {
    Write-Section "DISK CLEANUP"
    Write-Info "Launching Windows Disk Cleanup..."
    cleanmgr /d $env:SystemDrive /sageset:1
    cleanmgr /d $env:SystemDrive /sagerun:1
    Write-Success "Cleanup process started."
    Pause-Menu
}

function Invoke-AnalyzeStore {
    Write-Section "ANALYZE WINSXS"
    if (-not (Assert-Admin)) { return }
    Write-Step "Analyzing component store health..."
    Dism /Online /Cleanup-Image /AnalyzeComponentStore
    Pause-Menu
}

function Invoke-CleanupStore {
    Write-Section "CLEANUP WINSXS"
    if (-not (Assert-Admin)) { return }
    Write-Step "This may take 10-20 minutes. Proceed? (Y/N)"
    $ans = Read-Host ">"
    if ($ans.ToUpper() -ne "Y") { return }
    
    Write-Step "Starting Component Store Cleanup..."
    Dism /Online /Cleanup-Image /StartComponentCleanup /ResetBase
    Write-Success "Cleanup complete."
    Pause-Menu
}

function Invoke-ClearPrefetch {
    Write-Section "CLEAR PREFETCH"
    if (-not (Assert-Admin)) { return }
    $path = "$env:SystemRoot\Prefetch"
    Write-Step "Clearing $path..."
    Get-ChildItem $path -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    Write-Success "Prefetch cleared."
    Pause-Menu
}

function Invoke-Chkdsk {
    Write-Section "CHKDSK (READ-ONLY)"
    Write-Step "Checking $env:SystemDrive for errors..."
    chkdsk $env:SystemDrive
    Pause-Menu
}

function Invoke-BatteryReport {
    Write-Section "BATTERY REPORT"
    $out = "$env:TEMP\battery-report.html"
    powercfg /batteryreport /output $out
    if (Test-Path $out) {
        Write-Success "Report generated: $out"
        Start-Process $out
    } else {
        Write-Err "Failed to generate report (Desktop PC?)."
    }
    Pause-Menu
}

function Invoke-SmartCheck {
    Write-Section "DISK SMART STATUS"
    Get-CimInstance -Namespace root\wmi -ClassName MSStorageDriver_FailurePredictStatus | Select-Object InstanceName, PredictFailure, Reason | Format-Table -AutoSize
    Write-Info "PredictFailure: False = Healthy, True = Failing soon."
    Pause-Menu
}

function Invoke-NetworkProfiles {
    Write-Section "NETWORK PROFILES"
    Get-NetConnectionProfile | Select-Object Name, InterfaceAlias, IPv4Address, IPv6Address, NetworkCategory | Format-Table -AutoSize
    Pause-Menu
}
