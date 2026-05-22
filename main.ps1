[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Auto-elevate to Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "`n  [!] Admin rights required. Relaunching..." -ForegroundColor Yellow
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$script:NFS_ROOT = Split-Path -Parent $MyInvocation.MyCommand.Definition

. "$NFS_ROOT\modules\helpers.ps1"
. "$NFS_ROOT\modules\scripts.ps1"
. "$NFS_ROOT\modules\tools.ps1"
. "$NFS_ROOT\modules\devkit.ps1"
. "$NFS_ROOT\modules\drivers.ps1"
. "$NFS_ROOT\modules\customapps.ps1"
. "$NFS_ROOT\modules\gamesetup.ps1"
. "$NFS_ROOT\modules\isotools.ps1"
. "$NFS_ROOT\modules\isos.ps1"
. "$NFS_ROOT\modules\mywebs.ps1"
. "$NFS_ROOT\modules\optimizer.ps1"
. "$NFS_ROOT\modules\maintenance.ps1"
. "$NFS_ROOT\modules\about.ps1"

$Host.UI.RawUI.WindowTitle = "NFS PROGRAMMER CLI"

function Show-MainMenu {
    # Force Black Background at the engine level
    [Console]::BackgroundColor = 'Black'
    [Console]::Clear()
    
    Show-Intro
    Show-Login
    
    while ($true) {
        # Keep forcing background in loop
        [Console]::BackgroundColor = 'Black'
        Write-Host "`e[48;2;0;0;0m" -NoNewline # ANSI Backup
        Clear-Host
        
        $logoPath = "$NFS_ROOT\assets\logo.txt"
        if (Test-Path $logoPath) {
            Write-Host ""
            Get-Content $logoPath -Encoding utf8 | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
        }

        Write-Host ""
        Write-Host "  +-----------------------------------------------------+" -ForegroundColor DarkRed
        Write-Host "  |         NFS PROGRAMMER CLI - BY NIFRAS              |" -ForegroundColor DarkRed
        Write-Host "  +-----------------------------------------------------+" -ForegroundColor DarkRed
        Write-Host ""

        try {
            $user = $env:USERNAME
            $pc = $env:COMPUTERNAME
            Write-Host "  $user @ $pc" -ForegroundColor White
        } catch {}
        
        Write-Host ""
        Write-Host "  +-----------------------------------------------------+" -ForegroundColor Red
        Write-Host "  |  1.  Scripts          - Activators & Fixes          |" -ForegroundColor White
        Write-Host "  |  2.  Tools            - Essentials (Chrome, Office) |" -ForegroundColor White
        Write-Host "  |  3.  Dev Kit          - Developer environment setup |" -ForegroundColor White
        Write-Host "  |  4.  Driver Update    - Auto-detect & install       |" -ForegroundColor White
        Write-Host "  |  5.  Custom Apps      - Pro user selections         |" -ForegroundColor White
        Write-Host "  |  6.  Game Setup       - Runtimes & launchers        |" -ForegroundColor White
        Write-Host "  |  7.  ISOs             - OS downloads & tools        |" -ForegroundColor White
        Write-Host "  |  8.  My Webs          - Quick-launch links          |" -ForegroundColor White
        Write-Host "  |  0.  SYSTEM OPTIMIZER - Tweaks & Personalization    |" -ForegroundColor Green
        Write-Host "  |  M.  MAINTENANCE      - Health & Network tools      |" -ForegroundColor Green
        Write-Host "  |  9.  About            - Contact & info              |" -ForegroundColor DarkGray
        Write-Host "  |  Q.  Quit                                           |" -ForegroundColor DarkGray
        Write-Host "  +-----------------------------------------------------+" -ForegroundColor Red
        Write-Host ""

        $choice = (Read-Host "  Select option").Trim().ToUpper()

        switch ($choice) {
            "1" { Show-ScriptsMenu }
            "2" { Show-ToolsMenu }
            "3" { Show-DevKitMenu }
            "4" { Show-DriversMenu }
            "5" { Show-CustomAppsMenu }
            "6" { Show-GameSetupMenu }
            "7" { Show-ISOsMenu }
            "8" { Show-MyWebsMenu }
            "0" { Show-OptimizerMenu }
            "M" { Show-MaintenanceMenu }
            "9" { Show-About }
            "Q" {
                Clear-Host
                Write-Host "`n  Goodbye NIFRAS. Stay productive. 🚀" -ForegroundColor Red
                Start-Sleep 1
                exit
            }
            default {
                Write-Host "  Invalid option." -ForegroundColor Yellow
                Start-Sleep 1
            }
        }
    }
}

# Entry Point
Show-MainMenu
