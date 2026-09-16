# ============================================================
#  NFS CLI V2 - performance.ps1
#  Performance Center: Real-time Metrics, Top Processes & Startup
# ============================================================

function Show-PerformanceCenter {
    while ($true) {
        Clear-Host
        Write-Section "PERFORMANCE CENTER"
        Write-Host ""

        # Real-time metrics
        $os = Get-CimInstance Win32_OperatingSystem
        $totalMemGB = [Math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
        $freeMemGB = [Math]::Round($os.FreePhysicalMemory / 1MB, 1)
        $usedMemGB = [Math]::Round($totalMemGB - $freeMemGB, 1)
        $pctMem = [Math]::Round(($usedMemGB / $totalMemGB) * 100, 0)

        $cpuLoad = 0
        try {
            $perf = Get-CimInstance Win32_PerfFormattedData_PerfOS_Processor | Where-Object { $_.Name -eq "_Total" }
            $cpuLoad = $perf.PercentProcessorTime
        } catch {
            $cpuLoad = (Get-CimInstance Win32_Processor | Select-Object -First 1).LoadPercentage
        }

        $sysDrive = Get-PSDrive -Name ($env:SystemDrive.TrimEnd(':')) -ErrorAction SilentlyContinue
        $diskPct = [Math]::Round((($sysDrive.Used) / ($sysDrive.Used + $sysDrive.Free)) * 100, 0)

        $cpuColor = if ($cpuLoad -gt 85) { "Red" } elseif ($cpuLoad -gt 60) { "Yellow" } else { "Green" }
        $memColor = if ($pctMem -gt 85) { "Red" } elseif ($pctMem -gt 70) { "Yellow" } else { "Green" }
        $diskColor = if ($diskPct -gt 85) { "Red" } elseif ($diskPct -gt 70) { "Yellow" } else { "Green" }

        Write-Host "  CURRENT SYSTEM UTILIZATION" -ForegroundColor Yellow
        Write-HR "-" 56
        Write-Host ("  CPU Usage  : {0,3}%" -f $cpuLoad) -ForegroundColor $cpuColor
        Write-Host ("  RAM Usage  : {0,3}%  ({1} GB / {2} GB)" -f $pctMem, $usedMemGB, $totalMemGB) -ForegroundColor $memColor
        Write-Host ("  Disk ($($sysDrive.Name):)  : {0,3}% used" -f $diskPct) -ForegroundColor $diskColor
        Write-HR "-" 56
        Write-Host ""

        Write-Host "  MONITORING ACTIONS" -ForegroundColor Yellow
        Write-Host "    [1] " -ForegroundColor Cyan -NoNewline; Write-Host "Top Processes by Memory Usage" -ForegroundColor White
        Write-Host "    [2] " -ForegroundColor Cyan -NoNewline; Write-Host "Top Processes by CPU Usage" -ForegroundColor White
        Write-Host "    [3] " -ForegroundColor Cyan -NoNewline; Write-Host "Inspect Startup Applications" -ForegroundColor White
        Write-Host "    [4] " -ForegroundColor Yellow -NoNewline; Write-Host "Find & Terminate Process (Safe Confirmation)" -ForegroundColor White
        Write-Host "    [5] " -ForegroundColor White -NoNewline; Write-Host "Refresh Metrics" -ForegroundColor White
        Write-Host ""
        Write-Host "  NAVIGATION" -ForegroundColor Yellow
        Write-Host "    [B] " -ForegroundColor DarkGray -NoNewline; Write-Host "Back" -ForegroundColor White
        Write-Host ("  " + ("=" * 70)) -ForegroundColor DarkCyan
        Write-Host ""

        Write-Host "  >> Select option: " -ForegroundColor Cyan -NoNewline
        $choice = (Read-Host).Trim().ToUpper()
        switch ($choice) {
            "1" { Show-TopProcesses -SortBy "WS" }
            "2" { Show-TopProcesses -SortBy "CPU" }
            "3" { Show-StartupApps }
            "4" { Invoke-SafeProcessKill }
            "5" { continue }
            "B" { return }
            default { Write-Warn "Invalid choice." ; Start-Sleep 1 }
        }
    }
}

function Show-TopProcesses {
    param([ValidateSet("WS", "CPU")][string]$SortBy = "WS")
    Clear-Host
    $sortTitle = if ($SortBy -eq 'WS') { 'MEMORY (MB)' } else { 'CPU TIME (SEC)' }
    Write-Section "TOP PROCESSES BY $sortTitle"
    Write-Host ""

    $sortProp = if ($SortBy -eq "WS") { "WorkingSet64" } else { "CPU" }
    $procs = Get-Process | Sort-Object -Property $sortProp -Descending | Select-Object -First 15

    Write-Host ("  {0,-8} {1,-26} {2,10} {3,10}" -f "PID", "NAME", "RAM (MB)", "CPU (SEC)") -ForegroundColor DarkYellow
    Write-HR "-" 60

    foreach ($p in $procs) {
        $ramMB = [Math]::Round($p.WorkingSet64 / 1MB, 1)
        $cpuSec = if ($p.CPU) { [Math]::Round($p.CPU, 1) } else { 0 }
        Write-Host ("  {0,-8} {1,-26} {2,10} {3,10}" -f $p.Id, ($p.ProcessName.Substring(0, [Math]::Min(25, $p.ProcessName.Length))), $ramMB, $cpuSec) -ForegroundColor White
    }

    Write-HR "-" 60
    Pause-Menu
}

function Show-StartupApps {
    Clear-Host
    Write-Section "STARTUP APPLICATIONS INSPECTOR"
    Write-Host ""

    $startups = @()

    # HKCU Run
    $hkcu = Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -ErrorAction SilentlyContinue
    if ($hkcu) {
        $hkcu.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' } | ForEach-Object {
            $startups += [PSCustomObject]@{ Scope = "User (HKCU)"; Name = $_.Name; Command = $_.Value }
        }
    }

    # HKLM Run
    $hklm = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -ErrorAction SilentlyContinue
    if ($hklm) {
        $hklm.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' } | ForEach-Object {
            $startups += [PSCustomObject]@{ Scope = "System (HKLM)"; Name = $_.Name; Command = $_.Value }
        }
    }

    if ($startups.Count -gt 0) {
        Write-Host ("  {0,-15} {1,-22} {2}" -f "SCOPE", "NAME", "COMMAND") -ForegroundColor DarkYellow
        Write-HR "-" 75
        foreach ($s in $startups) {
            $cmd = if ($s.Command.Length -gt 40) { $s.Command.Substring(0, 37) + "..." } else { $s.Command }
            Write-Host ("  {0,-15} {1,-22} {2}" -f $s.Scope, ($s.Name.Substring(0, [Math]::Min(21, $s.Name.Length))), $cmd) -ForegroundColor White
        }
    } else {
        Write-Info "No registry startup entries found."
    }

    Write-Host ""
    Write-Info "To manage startup items interactively, you can also use Task Manager (Ctrl+Shift+Esc)."
    Pause-Menu
}

function Invoke-SafeProcessKill {
    Clear-Host
    Write-Section "TERMINATE PROCESS (CONFIRMATION REQUIRED)"
    Write-Warn "Never terminate unknown processes or essential Windows services."
    Write-Host ""

    $inputVal = Read-Host "  Enter Process Name or Process ID (or B to cancel)"
    if ($inputVal.Trim().ToUpper() -eq "B" -or [string]::IsNullOrWhiteSpace($inputVal)) { return }

    $targetProc = $null
    if ($inputVal -match "^\d+$") {
        $targetProc = Get-Process -Id ([int]$inputVal) -ErrorAction SilentlyContinue
    } else {
        $targetProc = Get-Process -Name $inputVal -ErrorAction SilentlyContinue | Select-Object -First 1
    }

    if (-not $targetProc) {
        Write-Err "Process '$inputVal' not found."
        Pause-Menu
        return
    }

    Write-Host ""
    Write-Host "  Process Details:" -ForegroundColor DarkCyan
    Write-Host "  PID         : $($targetProc.Id)" -ForegroundColor White
    Write-Host "  Name        : $($targetProc.ProcessName)" -ForegroundColor White
    Write-Host "  Memory (MB) : $([Math]::Round($targetProc.WorkingSet64 / 1MB, 1))" -ForegroundColor White
    try { Write-Host "  Path        : $($targetProc.Path)" -ForegroundColor White } catch {}
    Write-Host ""

    Write-Warn "This operation will terminate the process immediately."
    $confirm = (Read-Host "  Are you sure you want to stop this process? [Y/N]").Trim().ToUpper()
    if ($confirm -eq "Y") {
        try {
            Stop-Process -Id $targetProc.Id -Force -ErrorAction Stop
            Write-Success "Process $($targetProc.ProcessName) (PID $($targetProc.Id)) terminated."
            Write-NFSLog "User terminated process $($targetProc.ProcessName) (PID: $($targetProc.Id))" -Level "WARN"
        } catch {
            Write-Err "Failed to terminate process: $($_.Exception.Message)"
        }
    } else {
        Write-Info "Process termination cancelled by user."
    }
    Pause-Menu
}
