param(
    [string]$Command = "",
    [switch]$Check,
    [switch]$Latest,
    [switch]$Rollback,
    [switch]$NoIntro,
    [switch]$Fast,
    [string]$SubCommand = ""
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Allow read-only commands to run without elevation
if ($Command -in @("version", "changelog") -or ($Command -eq "update" -and $Check)) {
    # Non-elevated info commands proceed directly
} elseif (-not $isAdmin) {
    try {
        Write-Host "`n  [!] Admin rights required. Relaunching NFS CLI as Administrator..." -ForegroundColor Yellow
        $argList = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        if ($Command) { $argList += " `"$Command`"" }
        if ($Check) { $argList += " -Check" }
        if ($Latest) { $argList += " -Latest" }
        if ($Rollback) { $argList += " -Rollback" }
        if ($NoIntro) { $argList += " -NoIntro" }
        if ($Fast) { $argList += " -Fast" }
        if ($SubCommand) { $argList += " `"$SubCommand`"" }
        Start-Process powershell.exe $argList -Verb RunAs
        exit
    } catch {
        Write-Host "  [!] Could not auto-elevate. Continuing in current session..." -ForegroundColor Yellow
    }
}

$script:NFS_ROOT = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Dot-source Core Modules
. "$NFS_ROOT\modules\core\logger.ps1"
. "$NFS_ROOT\modules\core\config.ps1"
. "$NFS_ROOT\modules\core\cinematic.ps1"
. "$NFS_ROOT\modules\core\terminal.ps1"
. "$NFS_ROOT\modules\core\update.ps1"

# Dot-source Feature Modules
. "$NFS_ROOT\modules\system\doctor.ps1"
. "$NFS_ROOT\modules\system\performance.ps1"
. "$NFS_ROOT\modules\system\eventlogs.ps1"
. "$NFS_ROOT\modules\network\doctor.ps1"
. "$NFS_ROOT\modules\developer\doctor.ps1"
. "$NFS_ROOT\modules\developer\packages.ps1"

# Dot-source Preserved V1 Modules (100% Feature Preservation)
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
. "$NFS_ROOT\modules\python_scripts.ps1"

# Initialize Core Services
Initialize-NFSLogger -RootDir $script:NFS_ROOT
$config = Load-NFSConfig
$versionInfo = Load-NFSVersion

$Host.UI.RawUI.WindowTitle = "NFS PROGRAMMER CLI v$($versionInfo.version)"
Write-NFSLog "NFS Programmer CLI v$($versionInfo.version) started." -Level "INFO"

# Handle CLI Commands if supplied via parameters
if ($Command) {
    switch ($Command.ToLower()) {
        "version" {
            Write-Host "NFS Programmer CLI v$($versionInfo.version) (Build $($versionInfo.build))" -ForegroundColor Green
            Write-Host "$($versionInfo.tagline)" -ForegroundColor DarkGray
            exit
        }
        "changelog" {
            Show-NFSChangelog -NoPause
            exit
        }
        "update" {
            if ($Check) {
                $res = Check-NFSUpdate -TimeoutSec 5
                if ($res.ok) {
                    if ($res.hasUpdate) {
                        Write-Host "Update available: v$($res.latestVersion) (Current: v$($res.currentVersion))" -ForegroundColor Green
                    } else {
                        Write-Host "NFS Programmer CLI is up to date (v$($res.currentVersion))." -ForegroundColor Green
                    }
                } else {
                    Write-Host "Update check unavailable (Offline)." -ForegroundColor Yellow
                }
            } elseif ($Rollback) {
                Invoke-NFSRollback
            } else {
                Invoke-NFSUpdate
            }
            exit
        }
        "doctor" {
            if ($SubCommand -eq "network") { Show-NetworkDoctor }
            elseif ($SubCommand -eq "dev") { Show-DeveloperDoctor }
            else { Invoke-SystemDoctor }
            exit
        }
        default {
            Write-Host "Unknown command: $Command" -ForegroundColor Yellow
            Write-Host "Available CLI commands: version, changelog, update [--check | --latest | --rollback], doctor [system | network | dev]" -ForegroundColor Gray
            exit
        }
    }
}

# Run Extreme Cinematic Startup Animation Sequence
Show-NFSStartup -Config $config -VersionInfo $versionInfo -Fast:$Fast -NoIntro:$NoIntro

# If update is available, prompt non-blockingly
if ($script:NFS_LAST_CHECK_RESULT -and $script:NFS_LAST_CHECK_RESULT.hasUpdate) {
    Show-UpdateBanner -CheckResult $script:NFS_LAST_CHECK_RESULT
}

# V2 Dashboard Function
function Show-V2Dashboard {
    $chk = [char]0x2713

    while ($true) {
        [Console]::BackgroundColor = 'Black'
        Write-Host "`e[48;2;0;0;0m" -NoNewline
        Clear-Host

        # Query Live System Metrics
        $cpuLoad = "N/A"
        try {
            $perf = Get-CimInstance Win32_PerfFormattedData_PerfOS_Processor | Where-Object { $_.Name -eq "_Total" }
            $cpuLoad = "$($perf.PercentProcessorTime)%"
        } catch {
            try { $cpuLoad = "$((Get-CimInstance Win32_Processor | Select-Object -First 1).LoadPercentage)%" } catch {}
        }

        $ramInfo = "N/A"
        try {
            $os = Get-CimInstance Win32_OperatingSystem
            $tot = [Math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
            $free = [Math]::Round($os.FreePhysicalMemory / 1MB, 1)
            $used = [Math]::Round($tot - $free, 1)
            $ramInfo = "$used / $tot GB"
        } catch {}

        $diskInfo = "N/A"
        try {
            $d = Get-PSDrive -Name ($env:SystemDrive.TrimEnd(':')) -ErrorAction SilentlyContinue
            $pct = [Math]::Round(($d.Used / ($d.Used + $d.Free)) * 100, 0)
            $diskInfo = "$pct% ($($d.Name):)"
        } catch {}

        $gpuName = "N/A"
        try {
            $gpu = Get-CimInstance Win32_VideoController | Select-Object -First 1
            if ($gpu) {
                $gpuName = if ($gpu.Name.Length -gt 24) { $gpu.Name.Substring(0, 21) + "..." } else { $gpu.Name }
            }
        } catch {}

        $uptimeStr = "N/A"
        try {
            $bootTime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
            $diff = (Get-Date) - $bootTime
            $uptimeStr = "{0}d {1}h {2}m" -f $diff.Days, $diff.Hours, $diff.Minutes
        } catch {}

        # Render Dashboard Card
        Write-Host ""
        Write-Host "  +==============================================================+" -ForegroundColor DarkRed
        Write-Host "  |                    NFS PROGRAMMER CLI                        |" -ForegroundColor Red
        Write-Host "  |                         v$($versionInfo.version.PadRight(10))                          |" -ForegroundColor DarkRed
        Write-Host "  +--------------------------------------------------------------+" -ForegroundColor DarkRed
        Write-Host "  |  Welcome back, $env:USERNAME @ $env:COMPUTERNAME" -ForegroundColor White
        Write-Host "  |                                                              |" -ForegroundColor DarkRed
        Write-Host "  |  SYSTEM METRICS                                              |" -ForegroundColor Yellow
        Write-Host ("  |  CPU    : {0,-12} RAM    : {1,-14} DISK  : {2,-11}|" -f $cpuLoad, $ramInfo, $diskInfo) -ForegroundColor White
        Write-Host ("  |  GPU    : {0,-12} UPTIME : {1,-14} STATUS: [$chk] Healthy  |" -f $gpuName, $uptimeStr) -ForegroundColor White
        Write-Host "  |                                                              |" -ForegroundColor DarkRed
        Write-Host "  |  V2 QUICK ACTIONS                                            |" -ForegroundColor Yellow
        Write-Host "  |  [1] System Health (Doctor)     [2] Network Doctor           |" -ForegroundColor Cyan
        Write-Host "  |  [3] Developer Doctor           [4] Cleanup & Maintenance    |" -ForegroundColor Cyan
        Write-Host "  |  [5] App & Package Manager      [6] Event Logs & Diagnostics |" -ForegroundColor Cyan
        Write-Host "  |  [7] Performance Center         [L] Classic V1 Menus         |" -ForegroundColor Cyan
        Write-Host "  |                                                              |" -ForegroundColor DarkRed
        Write-Host "  |  UTILITIES & CONFIGURATION                                   |" -ForegroundColor Yellow
        Write-Host "  |  [U] Update & Rollback Center   [S] Settings & Theme         |" -ForegroundColor White
        Write-Host "  |  [A] About NFS CLI              [Q] Quit                     |" -ForegroundColor DarkGray
        Write-Host "  +==============================================================+" -ForegroundColor DarkRed
        Write-Host ""

        $choice = (Read-Host "  Select option").Trim().ToUpper()
        switch ($choice) {
            "1" { Invoke-SystemDoctor }
            "2" { Show-NetworkDoctor }
            "3" { Show-DeveloperDoctor }
            "4" { Show-MaintenanceMenu }
            "5" { Show-PackageManagerMenu }
            "6" { Show-EventLogAnalyzer }
            "7" { Show-PerformanceCenter }
            "L" { Show-LegacyV1Menu }
            "U" { Show-UpdateMenu }
            "S" { Show-SettingsMenu }
            "A" { Show-About }
            "Q" {
                Clear-Host
                Write-Host "`n  Goodbye $env:USERNAME. Stay productive. [Rocket]" -ForegroundColor Red
                Start-Sleep 1
                exit
            }
            default {
                Write-Warn "Invalid option."
                Start-Sleep 1
            }
        }
    }
}

# Dedicated V1 Classic Menu Bridge (100% Exact V1 Menu Workflows)
function Show-LegacyV1Menu {
    while ($true) {
        [Console]::BackgroundColor = 'Black'
        Write-Host "`e[48;2;0;0;0m" -NoNewline
        Clear-Host

        $logoPath = "$script:NFS_ROOT\assets\logo.txt"
        if (Test-Path $logoPath) {
            Write-Host ""
            Get-Content $logoPath -Encoding utf8 | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
        }

        Write-Host ""
        Write-Host "  +-----------------------------------------------------+" -ForegroundColor DarkRed
        Write-Host "  |         NFS PROGRAMMER CLI - CLASSIC V1 MENU        |" -ForegroundColor DarkRed
        Write-Host "  +-----------------------------------------------------+" -ForegroundColor DarkRed
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
        Write-Host "  |  P.  Python Scripts   - Automation & Tools          |" -ForegroundColor Magenta
        Write-Host "  |  0.  SYSTEM OPTIMIZER - Tweaks & Personalization    |" -ForegroundColor Green
        Write-Host "  |  M.  MAINTENANCE      - Health & Network tools      |" -ForegroundColor Green
        Write-Host "  |  9.  About            - Contact & info              |" -ForegroundColor DarkGray
        Write-Host "  |  B.  Back to V2 Dashboard                           |" -ForegroundColor Cyan
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
            "P" { Show-PythonScriptsMenu }
            "0" { Show-OptimizerMenu }
            "M" { Show-MaintenanceMenu }
            "9" { Show-About }
            "B" { return }
            "Q" {
                Clear-Host
                Write-Host "`n  Goodbye $env:USERNAME. Stay productive." -ForegroundColor Red
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

# Compatibility alias for Show-MainMenu
function Show-MainMenu {
    Show-V2Dashboard
}

# Launch Dashboard
Show-V2Dashboard
