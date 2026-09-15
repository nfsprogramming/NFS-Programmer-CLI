# ============================================================
#  NFS CLI V2 - eventlogs.ps1
#  Event Log Analyzer: Critical, Error & Warning Inspector
# ============================================================

function Show-EventLogAnalyzer {
    while ($true) {
        Clear-Host
        Write-Section "EVENT LOG ANALYZER"
        Write-Host ""
        Write-Host "  Inspect recent Windows diagnostic, application, and system events." -ForegroundColor DarkGray
        Write-Host ""

        Write-Host "  +-----------------------------------------------------+" -ForegroundColor DarkRed
        Write-Host "  |  1.  System Events (Critical & Error - Last 24h)    |" -ForegroundColor Red
        Write-Host "  |  2.  Application Events (Errors & Warnings)         |" -ForegroundColor Yellow
        Write-Host "  |  3.  Hardware & Driver Error Events                 |" -ForegroundColor Cyan
        Write-Host "  |  4.  Custom Filter (By Event Level & Count)         |" -ForegroundColor White
        Write-Host "  |  5.  Export Recent Event Summary to File            |" -ForegroundColor Green
        Write-Host "  |  B.  Back                                           |" -ForegroundColor DarkGray
        Write-Host "  +-----------------------------------------------------+" -ForegroundColor DarkRed
        Write-Host ""

        $choice = (Read-Host "  Select option").Trim().ToUpper()
        switch ($choice) {
            "1" { Inspect-Events -LogName "System" -Levels @(1, 2) -Max 15 -Title "CRITICAL & ERROR SYSTEM EVENTS" }
            "2" { Inspect-Events -LogName "Application" -Levels @(2, 3) -Max 15 -Title "APPLICATION ERRORS & WARNINGS" }
            "3" { Inspect-DriverEvents }
            "4" { Show-CustomEventFilter }
            "5" { Export-EventSummary }
            "B" { return }
            default { Write-Warn "Invalid choice." ; Start-Sleep 1 }
        }
    }
}

function Inspect-Events {
    param(
        [string]$LogName = "System",
        [int[]]$Levels = @(1, 2),
        [int]$Max = 15,
        [string]$Title = "EVENTS"
    )

    Clear-Host
    Write-Section $Title
    Write-Host "  Querying $LogName log for high-priority events..." -ForegroundColor DarkGray
    Write-Host ""

    try {
        $filter = @{
            LogName   = $LogName
            Level     = $Levels
            StartTime = (Get-Date).AddHours(-24)
        }
        $events = Get-WinEvent -FilterHashtable $filter -MaxEvents $Max -ErrorAction Stop

        Write-Host ("  {0,-19} {1,-10} {2,-20} {3}" -f "TIMESTAMP", "LEVEL", "SOURCE", "EVENT ID / SUMMARY") -ForegroundColor DarkYellow
        Write-HR "-" 75

        foreach ($evt in $events) {
            $lvl = switch ($evt.Level) {
                1 { "CRITICAL" }
                2 { "ERROR" }
                3 { "WARNING" }
                default { "INFO" }
            }
            $lvlColor = switch ($evt.Level) {
                1 { "Red" }
                2 { "Red" }
                3 { "Yellow" }
                default { "White" }
            }

            $msgSummary = if ($evt.Message) {
                $evt.Message.Replace("`r", " ").Replace("`n", " ")
                if ($evt.Message.Length -gt 40) { $evt.Message.Substring(0, 37) + "..." } else { $evt.Message }
            } else { "Event ID $($evt.Id)" }

            $timeStr = $evt.TimeCreated.ToString("yyyy-MM-dd HH:mm")
            $sourceStr = if ($evt.ProviderName.Length -gt 19) { $evt.ProviderName.Substring(0, 16) + "..." } else { $evt.ProviderName }

            Write-Host ("  {0,-19} " -f $timeStr) -NoNewline -ForegroundColor DarkGray
            Write-Host ("{0,-10} " -f $lvl) -NoNewline -ForegroundColor $lvlColor
            Write-Host ("{0,-20} " -f $sourceStr) -NoNewline -ForegroundColor White
            Write-Host ("#{0}: {1}" -f $evt.Id, $msgSummary) -ForegroundColor Gray
        }
        Write-HR "-" 75
        Write-Host ""
        Write-Host "  Total found: $($events.Count) events in the past 24 hours." -ForegroundColor Green
    } catch [System.Exception] {
        if ($_.Exception.Message -like "*No events were found*") {
            Write-Success "No critical or error events recorded in the last 24 hours. System log is clean!"
        } else {
            Write-Warn "Event query note: $($_.Exception.Message)"
        }
    }
    Pause-Menu
}

function Inspect-DriverEvents {
    Clear-Host
    Write-Section "HARDWARE & DRIVER EVENTS"
    Write-Host "  Scanning for Kernel-PnP, Disk, and Display driver warnings..." -ForegroundColor DarkGray
    Write-Host ""

    try {
        $filter = @{
            LogName      = "System"
            ProviderName = @("Microsoft-Windows-Kernel-PnP", "Disk", "Display", "Nvlddmkm", "amdkmdag")
            Level        = @(1, 2, 3)
            StartTime    = (Get-Date).AddDays(-3)
        }
        $events = Get-WinEvent -FilterHashtable $filter -MaxEvents 15 -ErrorAction Stop

        Write-Host ("  {0,-19} {1,-10} {2,-20} {3}" -f "TIMESTAMP", "LEVEL", "SOURCE", "EVENT ID / SUMMARY") -ForegroundColor DarkYellow
        Write-HR "-" 75

        foreach ($evt in $events) {
            $lvl = switch ($evt.Level) { 1 { "CRITICAL" }; 2 { "ERROR" }; 3 { "WARNING" }; default { "INFO" } }
            $lvlColor = if ($evt.Level -le 2) { "Red" } else { "Yellow" }
            $timeStr = $evt.TimeCreated.ToString("yyyy-MM-dd HH:mm")
            $sourceStr = if ($evt.ProviderName.Length -gt 19) { $evt.ProviderName.Substring(0, 16) + "..." } else { $evt.ProviderName }

            Write-Host ("  {0,-19} " -f $timeStr) -NoNewline -ForegroundColor DarkGray
            Write-Host ("{0,-10} " -f $lvl) -NoNewline -ForegroundColor $lvlColor
            Write-Host ("{0,-20} " -f $sourceStr) -NoNewline -ForegroundColor White
            Write-Host ("#{0}: {1}" -f $evt.Id, ($evt.Message.Substring(0, [Math]::Min(35, $evt.Message.Length)))) -ForegroundColor Gray
        }
    } catch {
        Write-Success "No driver or hardware errors found in recent event logs."
    }
    Pause-Menu
}

function Show-CustomEventFilter {
    Clear-Host
    Write-Section "CUSTOM EVENT LOG FILTER"
    Write-Host ""
    Write-Host "  [1] System Log   [2] Application Log   [3] Security Log" -ForegroundColor Yellow
    $logChoice = Read-Host "  Select Log"
    $selectedLog = switch ($logChoice) { "2" { "Application" }; "3" { "Security" }; default { "System" } }

    Write-Host "  [1] Errors Only   [2] Errors + Warnings   [3] Critical Only" -ForegroundColor Yellow
    $lvlChoice = Read-Host "  Select Level"
    $selectedLevels = switch ($lvlChoice) { "2" { @(1, 2, 3) }; "3" { @(1) }; default { @(1, 2) } }

    $count = Read-Host "  Maximum events to fetch (default: 20)"
    $maxEvents = if ([int]::TryParse($count, [ref]$c) -and $c -gt 0) { $c } else { 20 }

    Inspect-Events -LogName $selectedLog -Levels $selectedLevels -Max $maxEvents -Title "CUSTOM FILTER: $selectedLog"
}

function Export-EventSummary {
    Clear-Host
    Write-Section "EXPORT EVENT LOG SUMMARY"
    $exportDir = if ($script:NFS_LOG_DIR) { $script:NFS_LOG_DIR } else { "$env:TEMP" }
    $exportFile = Join-Path $exportDir "event_analysis_$(Get-Date -Format 'yyyyMMdd_HHmm').txt"

    Write-Step "Gathering recent high-priority events from System & Application logs..."
    try {
        $events = Get-WinEvent -FilterHashtable @{ LogName = @("System", "Application"); Level = @(1, 2); StartTime = (Get-Date).AddDays(-1) } -MaxEvents 50 -ErrorAction Stop
        
        $sb = [System.Text.StringBuilder]::new()
        [void]$sb.AppendLine("NFS PROGRAMMER CLI - EVENT LOG ANALYSIS REPORT")
        [void]$sb.AppendLine("Generated: $(Get-Date)")
        [void]$sb.AppendLine("Host: $env:COMPUTERNAME | User: $env:USERNAME")
        [void]$sb.AppendLine("---------------------------------------------------------------")

        foreach ($e in $events) {
            [void]$sb.AppendLine("[$($e.TimeCreated)] [$($e.LogName)] Level: $($e.LevelDisplayName) | Provider: $($e.ProviderName) | EventID: $($e.Id)")
            [void]$sb.AppendLine("Message: $($e.Message)")
            [void]$sb.AppendLine("")
        }

        [System.IO.File]::WriteAllText($exportFile, $sb.ToString(), [System.Text.Encoding]::UTF8)
        Write-Success "Event summary exported to: $exportFile"
        Write-Host "  Open exported file? (Y/N)" -ForegroundColor Yellow
        $o = Read-Host "  >"
        if ($o.Trim().ToUpper() -eq "Y") { Start-Process notepad.exe $exportFile }
    } catch {
        Write-Warn "No critical/error events found or could not export: $($_.Exception.Message)"
    }
    Pause-Menu
}
