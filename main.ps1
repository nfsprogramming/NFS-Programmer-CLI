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

# Unified Main Menu (ASCII Logo + Full V1 Workflows + V2 Engineering Tools)
function Show-MainMenu {
    while ($true) {
        [Console]::BackgroundColor = 'Black'
        Write-Host "`e[48;2;0;0;0m" -NoNewline
        Clear-Host

        # Display Iconic NFS Logo
        $logoPath = "$script:NFS_ROOT\assets\logo.txt"
        if (Test-Path $logoPath) {
            Write-Host ""
            Get-Content $logoPath -Encoding utf8 | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
        }

        # Query Live System Metrics for telemetry ribbon
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

        $uptimeStr = "N/A"
        try {
            $bootTime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
            $diff = (Get-Date) - $bootTime
            $uptimeStr = "{0}d {1}h {2}m" -f $diff.Days, $diff.Hours, $diff.Minutes
        } catch {}

        Write-Host ""
        Write-Host "  :: NFS PROGRAMMER CLI " -ForegroundColor Red -NoNewline
        Write-Host "v$($versionInfo.version) " -ForegroundColor DarkGray -NoNewline
        Write-Host "-- Windows Developer & System Engineering" -ForegroundColor Gray
        Write-Host ("  " + ("=" * 72)) -ForegroundColor DarkRed

        # System Telemetry Ribbon
        Write-Host "  * Host: " -ForegroundColor DarkGray -NoNewline
        Write-Host "$env:USERNAME@$env:COMPUTERNAME" -ForegroundColor White -NoNewline
        Write-Host "   * CPU: " -ForegroundColor DarkGray -NoNewline
        Write-Host "$cpuLoad" -ForegroundColor Cyan -NoNewline
        Write-Host "   * RAM: " -ForegroundColor DarkGray -NoNewline
        Write-Host "$ramInfo" -ForegroundColor Cyan -NoNewline
        Write-Host "   * Disk: " -ForegroundColor DarkGray -NoNewline
        Write-Host "$diskInfo" -ForegroundColor Cyan -NoNewline
        Write-Host "   * Uptime: " -ForegroundColor DarkGray -NoNewline
        Write-Host "$uptimeStr" -ForegroundColor DarkGray

        Write-Host ""
        Write-Host "  V2 TOOLS & DOCTORS" -ForegroundColor Yellow
        Write-Host "    [D] " -ForegroundColor Cyan -NoNewline; Write-Host "System Doctor      " -ForegroundColor White -NoNewline; Write-Host "Deep hardware, services & driver diagnostic" -ForegroundColor DarkGray
        Write-Host "    [N] " -ForegroundColor Cyan -NoNewline; Write-Host "Network Doctor     " -ForegroundColor White -NoNewline; Write-Host "Ping, DNS latency, resets & adapter tools" -ForegroundColor DarkGray
        Write-Host "    [V] " -ForegroundColor Cyan -NoNewline; Write-Host "Developer Doctor   " -ForegroundColor White -NoNewline; Write-Host "Git, Python, Node.js, compilers & SDKs" -ForegroundColor DarkGray
        Write-Host "    [W] " -ForegroundColor Cyan -NoNewline; Write-Host "Winget Studio      " -ForegroundColor White -NoNewline; Write-Host "App & package manager: search, upgrade all" -ForegroundColor DarkGray
        Write-Host "    [E] " -ForegroundColor Cyan -NoNewline; Write-Host "Event Logs         " -ForegroundColor White -NoNewline; Write-Host "Critical errors & system log inspector" -ForegroundColor DarkGray
        Write-Host "    [F] " -ForegroundColor Cyan -NoNewline; Write-Host "Performance        " -ForegroundColor White -NoNewline; Write-Host "Real-time CPU/RAM monitor & process manager" -ForegroundColor DarkGray

        Write-Host ""
        Write-Host "  CORE WORKFLOWS" -ForegroundColor Yellow
        Write-Host "    [1] " -ForegroundColor Cyan -NoNewline; Write-Host "Scripts            " -ForegroundColor White -NoNewline; Write-Host "Activators, Windows fixes & debloater" -ForegroundColor DarkGray
        Write-Host "    [2] " -ForegroundColor Cyan -NoNewline; Write-Host "Tools              " -ForegroundColor White -NoNewline; Write-Host "Essentials (Chrome, Office, 7-Zip, VLC)" -ForegroundColor DarkGray
        Write-Host "    [3] " -ForegroundColor Cyan -NoNewline; Write-Host "Dev Kit            " -ForegroundColor White -NoNewline; Write-Host "Developer environments & compilers" -ForegroundColor DarkGray
        Write-Host "    [4] " -ForegroundColor Cyan -NoNewline; Write-Host "Driver Update      " -ForegroundColor White -NoNewline; Write-Host "Auto-detect & install hardware drivers" -ForegroundColor DarkGray
        Write-Host "    [5] " -ForegroundColor Cyan -NoNewline; Write-Host "Custom Apps        " -ForegroundColor White -NoNewline; Write-Host "Power user applications" -ForegroundColor DarkGray
        Write-Host "    [6] " -ForegroundColor Cyan -NoNewline; Write-Host "Game Setup         " -ForegroundColor White -NoNewline; Write-Host "Runtimes, DirectX & launchers" -ForegroundColor DarkGray
        Write-Host "    [7] " -ForegroundColor Cyan -NoNewline; Write-Host "ISOs Hub           " -ForegroundColor White -NoNewline; Write-Host "Windows & Linux OS downloads" -ForegroundColor DarkGray
        Write-Host "    [8] " -ForegroundColor Cyan -NoNewline; Write-Host "My Webs            " -ForegroundColor White -NoNewline; Write-Host "Developer bookmarks & quick links" -ForegroundColor DarkGray
        Write-Host "    [P] " -ForegroundColor Magenta -NoNewline; Write-Host "Python Scripts     " -ForegroundColor White -NoNewline; Write-Host "Automation tools & organizers" -ForegroundColor DarkGray
        Write-Host "    [0] " -ForegroundColor Green -NoNewline; Write-Host "System Optimizer   " -ForegroundColor White -NoNewline; Write-Host "Deep OS tweaks & personalization" -ForegroundColor DarkGray
        Write-Host "    [M] " -ForegroundColor Green -NoNewline; Write-Host "Maintenance        " -ForegroundColor White -NoNewline; Write-Host "Health, SFC, DISM & network resets" -ForegroundColor DarkGray
        Write-Host "    [9] " -ForegroundColor DarkGray -NoNewline; Write-Host "About              " -ForegroundColor White -NoNewline; Write-Host "NFS info & credits" -ForegroundColor DarkGray

        Write-Host ""
        Write-Host "  CONFIGURATION & CONTROL" -ForegroundColor Yellow
        Write-Host "    [U] " -ForegroundColor Magenta -NoNewline; Write-Host "Update Center      " -ForegroundColor White -NoNewline; Write-Host "Check updates & rollback engine" -ForegroundColor DarkGray
        Write-Host "    [S] " -ForegroundColor DarkCyan -NoNewline; Write-Host "Settings           " -ForegroundColor White -NoNewline; Write-Host "Terminal theme & animation config" -ForegroundColor DarkGray
        Write-Host "    [Q] " -ForegroundColor DarkRed -NoNewline; Write-Host "Quit CLI" -ForegroundColor DarkRed

        Write-Host ""
        Write-Host ("  " + ("=" * 72)) -ForegroundColor DarkRed
        Write-Host ""
        Write-Host "  >> Select option: " -ForegroundColor Red -NoNewline
        $choice = (Read-Host).Trim().ToUpper()

        switch ($choice) {
            # V2 Tools & Doctors
            "D" { Invoke-SystemDoctor }
            "N" { Show-NetworkDoctor }
            "V" { Show-DeveloperDoctor }
            "W" { Show-PackageManagerMenu }
            "E" { Show-EventLogAnalyzer }
            "F" { Show-PerformanceCenter }

            # Core Workflows (100% Exact V1 keys preserved)
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

            # Config & Control
            "U" { Show-UpdateMenu }
            "S" { Show-SettingsMenu }
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

# Compatibility alias
function Show-V2Dashboard {
    Show-MainMenu
}

# Launch Menu
Show-MainMenu
