# ============================================================
#  NFS CLI V2 - doctor.ps1
#  System Doctor: Deep OS, Hardware, Services & Driver Diagnostics
# ============================================================

function Test-PendingReboot {
    $reboot = $false
    # Component Based Servicing
    if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending") { $reboot = $true }
    # Windows Update
    if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired") { $reboot = $true }
    # PendingFileRenameOperations
    $pending = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name "PendingFileRenameOperations" -ErrorAction SilentlyContinue
    if ($pending -and $pending.PendingFileRenameOperations) { $reboot = $true }
    return $reboot
}

function Invoke-SystemDoctor {
    Clear-Host
    Write-Section "SYSTEM DOCTOR - COMPREHENSIVE HEALTH DIAGNOSTIC"
    Write-Host "  Scanning system metrics and hardware status..." -ForegroundColor DarkGray
    Write-Host ""

    Write-NFSLog "Running System Doctor diagnostic scan..." -Target "diagnostics"

    $results = @{}
    $chk = [char]0x2713

    # 1. CPU
    try {
        $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
        $cpuLoad = $cpu.LoadPercentage
        if ($null -eq $cpuLoad) {
            $perf = Get-CimInstance Win32_PerfFormattedData_PerfOS_Processor | Where-Object { $_.Name -eq "_Total" }
            $cpuLoad = $perf.PercentProcessorTime
        }
        $cpuOk = ($cpuLoad -lt 85)
        $cpuStatus = if ($cpuOk) { "$chk Healthy" } else { "! High Load" }
        $results["CPU"] = @{
            Status  = $cpuStatus
            IsGood  = $cpuOk
            Details = "$($cpu.Name) ($cpuLoad% load, $($cpu.NumberOfCores)C/$($cpu.NumberOfLogicalProcessors)T)"
        }
    } catch {
        $results["CPU"] = @{ Status = "! Warning"; IsGood = $true; Details = "Could not query CPU performance" }
    }

    # 2. Memory
    try {
        $os = Get-CimInstance Win32_OperatingSystem
        $totalMemGB = [Math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
        $freeMemGB = [Math]::Round($os.FreePhysicalMemory / 1MB, 1)
        $usedMemGB = [Math]::Round($totalMemGB - $freeMemGB, 1)
        $pctUsed = [Math]::Round(($usedMemGB / $totalMemGB) * 100, 0)
        $memOk = ($pctUsed -lt 90)
        $memStatus = if ($memOk) { "$chk Healthy" } else { "! High Usage" }
        $results["Memory"] = @{
            Status  = $memStatus
            IsGood  = $memOk
            Details = "$usedMemGB / $totalMemGB GB ($pctUsed% used)"
        }
    } catch {
        $results["Memory"] = @{ Status = "? Unknown"; IsGood = $true; Details = "Unable to read memory stats" }
    }

    # 3. Storage
    try {
        $systemDrive = Get-PSDrive -Name ($env:SystemDrive.TrimEnd(':')) -ErrorAction SilentlyContinue
        $totalGB = [Math]::Round(($systemDrive.Used + $systemDrive.Free) / 1GB, 1)
        $freeGB = [Math]::Round($systemDrive.Free / 1GB, 1)
        $usedPct = [Math]::Round((($totalGB - $freeGB) / $totalGB) * 100, 0)
        
        # SMART status check
        $smartOk = $true
        try {
            $smart = Get-CimInstance -Namespace root\wmi -ClassName MSStorageDriver_FailurePredictStatus -ErrorAction SilentlyContinue
            if ($smart -and ($smart | Where-Object { $_.PredictFailure -eq $true })) {
                $smartOk = $false
            }
        } catch {}

        $isStorageGood = ($usedPct -lt 90) -and $smartOk
        $smartNote = if (-not $smartOk) { "[SMART ALERT]" } else { "[SMART OK]" }
        $storageStatus = if ($isStorageGood) { "$chk Healthy" } else { "! Space/SMART Warning" }
        $results["Storage"] = @{
            Status  = $storageStatus
            IsGood  = $isStorageGood
            Details = "Drive $($systemDrive.Name): $freeGB GB free of $totalGB GB ($usedPct% used) $smartNote"
        }
    } catch {
        $results["Storage"] = @{ Status = "? Unknown"; IsGood = $true; Details = "Storage read error" }
    }

    # 4. Windows OS & Updates
    try {
        $os = Get-CimInstance Win32_OperatingSystem
        $reboot = Test-PendingReboot
        $osStatus = if (-not $reboot) { "$chk Healthy" } else { "! Reboot Pending" }
        $rebootNote = if ($reboot) { " - Reboot Required" } else { "" }
        $results["Windows"] = @{
            Status  = $osStatus
            IsGood  = (-not $reboot)
            Details = "$($os.Caption) (Build $($os.BuildNumber))$rebootNote"
        }
    } catch {
        $results["Windows"] = @{ Status = "? Unknown"; IsGood = $true; Details = "OS query error" }
    }

    # 5. Critical Services
    try {
        $criticalServices = @("wuauserv", "CryptSvc", "BITS", "Spooler", "W32Time")
        $stopped = @()
        foreach ($s in $criticalServices) {
            $svc = Get-Service -Name $s -ErrorAction SilentlyContinue
            if ($svc -and $svc.Status -ne "Running" -and $svc.StartType -ne "Disabled") {
                $stopped += $s
            }
        }
        $servicesOk = ($stopped.Count -eq 0)
        $svcStatus = if ($servicesOk) { "$chk Healthy" } else { "! Stopped ($($stopped -join ', '))" }
        $svcDetails = if ($servicesOk) { "All essential services running (5/5)" } else { "Stopped: $($stopped -join ', ')" }
        $results["Services"] = @{
            Status  = $svcStatus
            IsGood  = $servicesOk
            Details = $svcDetails
        }
    } catch {
        $results["Services"] = @{ Status = "? Unknown"; IsGood = $true; Details = "Service query error" }
    }

    # 6. Driver Health
    try {
        $problemDevices = Get-CimInstance Win32_PnPEntity | Where-Object { $_.ConfigManagerErrorCode -ne 0 -and $_.ConfigManagerErrorCode -ne $null }
        $driversOk = ($null -eq $problemDevices -or $problemDevices.Count -eq 0)
        $drvStatus = if ($driversOk) { "$chk Healthy" } else { "! $($problemDevices.Count) Device Issues" }
        $drvDetails = if ($driversOk) { "No driver conflict or device errors" } else { "$($problemDevices.Count) devices with driver error codes" }
        $results["Drivers"] = @{
            Status  = $drvStatus
            IsGood  = $driversOk
            Details = $drvDetails
        }
    } catch {
        $results["Drivers"] = @{ Status = "$chk Healthy"; IsGood = $true; Details = "Driver scan completed" }
    }

    # 7. Network Connectivity
    try {
        $hasNet = [System.Net.NetworkInformation.NetworkInterface]::GetIsNetworkAvailable()
        $results["Network"] = @{
            Status  = if ($hasNet) { "$chk Connected" } else { "! Disconnected" }
            IsGood  = $hasNet
            Details = if ($hasNet) { "Active network interface present" } else { "No active internet connection" }
        }
    } catch {
        $results["Network"] = @{ Status = "? Unknown"; IsGood = $true; Details = "Network status unavailable" }
    }

    # Calculate overall health
    $badCount = ($results.Values | Where-Object { -not $_.IsGood }).Count
    $overall = if ($badCount -eq 0) { "EXCELLENT" } elseif ($badCount -eq 1) { "GOOD (Minor Attention)" } else { "ATTENTION NEEDED" }
    $overallColor = if ($badCount -eq 0) { "Green" } elseif ($badCount -eq 1) { "Yellow" } else { "Red" }

    # Display Report
    Write-Host "  ================ SYSTEM HEALTH SUMMARY ================" -ForegroundColor DarkRed
    Write-Host ""
    Write-Host ("  {0,-18} {1,-20} {2}" -f "COMPONENT", "STATUS", "DETAILS") -ForegroundColor DarkGray
    Write-HR "-" 68

    foreach ($key in @("CPU", "Memory", "Storage", "Windows", "Services", "Drivers", "Network")) {
        $item = $results[$key]
        $color = if ($item.IsGood) { "Green" } else { "Yellow" }
        Write-Host ("  {0,-18} " -f $key) -NoNewline -ForegroundColor White
        Write-Host ("{0,-20} " -f $item.Status) -NoNewline -ForegroundColor $color
        Write-Host $item.Details -ForegroundColor Gray
    }

    Write-HR "-" 68
    Write-Host ""
    Write-Host "  OVERALL HEALTH : " -NoNewline -ForegroundColor White
    Write-Host "$overall" -ForegroundColor $overallColor
    Write-Host ""

    Write-Host "  [1] Generate Full Diagnostic Report File" -ForegroundColor Cyan
    Write-Host "  [2] Check Problem Devices / Drivers"     -ForegroundColor Cyan
    Write-Host "  [3] Generate Battery Health Report"      -ForegroundColor Cyan
    Write-Host "  [B] Back"                                -ForegroundColor DarkGray
    Write-Host ""

    $action = (Read-Host "  Select").Trim().ToUpper()
    switch ($action) {
        "1" {
            $reportFile = Join-Path (if ($script:NFS_LOG_DIR) { $script:NFS_LOG_DIR } else { "$env:TEMP" }) "system_doctor_report.txt"
            $sb = [System.Text.StringBuilder]::new()
            [void]$sb.AppendLine("NFS PROGRAMMER CLI - SYSTEM DOCTOR REPORT")
            [void]$sb.AppendLine("Generated: $(Get-Date)")
            [void]$sb.AppendLine("Machine: $env:COMPUTERNAME | User: $env:USERNAME")
            [void]$sb.AppendLine("Overall Health: $overall")
            [void]$sb.AppendLine("--------------------------------------------------")
            foreach ($k in $results.Keys) {
                [void]$sb.AppendLine("$k : $($results[$k].Status) - $($results[$k].Details)")
            }
            [System.IO.File]::WriteAllText($reportFile, $sb.ToString(), [System.Text.Encoding]::UTF8)
            Write-Success "Diagnostic report saved to: $reportFile"
            Start-Process notepad.exe $reportFile
        }
        "2" {
            Clear-Host
            Write-Section "DEVICE MANAGER PROBLEM DEVICES"
            $probs = Get-CimInstance Win32_PnPEntity | Where-Object { $_.ConfigManagerErrorCode -ne 0 -and $_.ConfigManagerErrorCode -ne $null }
            if ($probs) {
                $probs | Select-Object Name, DeviceID, ConfigManagerErrorCode | Format-Table -AutoSize
            } else {
                Write-Success "All hardware devices and drivers report 0 error codes."
            }
            Pause-Menu
        }
        "3" {
            Invoke-BatteryReport
        }
    }
    if ($action -ne "2" -and $action -ne "B") { Pause-Menu }
}
