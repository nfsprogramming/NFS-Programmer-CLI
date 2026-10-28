# ============================================================
#  NFS CLI V2 - cinematic.ps1
#  EXTREME CINEMATIC TERMINAL INTRO ENGINE
#  Multi-Layer Cyberpunk Developer Terminal Boot Sequence
# ============================================================

function Get-SystemSnapshot {
    $snap = [PSCustomObject]@{
        OS                = "Windows"
        Arch              = $env:PROCESSOR_ARCHITECTURE
        RAM               = 16
        CPU               = "Processor"
        HostName          = $env:COMPUTERNAME
        UserName          = $env:USERNAME
        PSVersion         = $PSVersionTable.PSVersion.ToString()
        SessionId         = ("NFS-" + (Get-Random -Minimum 0x1000 -Maximum 0xFFFF).ToString("X4"))
        DiscoveredModules = 0
        TerminalWidth     = 80
        TerminalHeight    = 25
    }

    try {
        $w = $Host.UI.RawUI.WindowSize.Width
        $h = $Host.UI.RawUI.WindowSize.Height
        if ($w -gt 20) { $snap.TerminalWidth = $w }
        if ($h -gt 10) { $snap.TerminalHeight = $h }
    } catch {}

    # Fast cached system data query
    try {
        $osObj = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
        if ($osObj -and $osObj.Caption) { $snap.OS = ($osObj.Caption -replace "Microsoft\s*", "") }
    } catch {}

    try {
        $mem = Get-CimInstance Win32_PhysicalMemory -ErrorAction SilentlyContinue | Measure-Object Capacity -Sum
        if ($mem -and $mem.Sum) { $snap.RAM = [Math]::Round($mem.Sum / 1GB, 0) }
    } catch {}

    try {
        $cpuObj = Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($cpuObj -and $cpuObj.Name) {
            $rawCpu = $cpuObj.Name -replace "\(R\)|\(TM\)", "" -replace "\s+", " "
            $snap.CPU = if ($rawCpu.Length -gt 26) { $rawCpu.Substring(0, 23) + "..." } else { $rawCpu }
        }
    } catch {}

    try {
        $root = if ($script:NFS_ROOT) { $script:NFS_ROOT } else { (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) }
        $modFiles = Get-ChildItem -Path (Join-Path $root "modules") -Recurse -Filter "*.ps1" -ErrorAction SilentlyContinue
        $snap.DiscoveredModules = if ($modFiles) { $modFiles.Count } else { 14 }
    } catch {
        $snap.DiscoveredModules = 14
    }

    return $snap
}

function Clear-NFSConsole {
    try {
        if (-not [Console]::IsOutputRedirected) {
            [Console]::Clear()
        } else {
            Write-Host ""
        }
    } catch {
        try { Clear-Host } catch { Write-Host "" }
    }
}

function Set-NFSCursorPosition {
    param([int]$x, [int]$y)
    try {
        if (-not [Console]::IsOutputRedirected) {
            [Console]::SetCursorPosition($x, $y)
        }
    } catch {}
}

function Show-CompactCinematicIntro {
    param([object]$Snap, [object]$VersionInfo, [double]$Speed = 1.0)
    Clear-NFSConsole
    Write-Host ""
    Write-Host "  NFS://BOOT" -ForegroundColor Red
    Start-Sleep -Milliseconds ([int](150 * $Speed))
    Write-Host "  CORE INITIALIZING..." -ForegroundColor DarkGray
    Start-Sleep -Milliseconds ([int](200 * $Speed))
    Write-Host ""
    Write-Host "  [+] OS       : $($Snap.OS) ($($Snap.Arch))" -ForegroundColor White
    Write-Host "  [+] MEMORY   : $($Snap.RAM) GB PHYSICAL" -ForegroundColor White
    Write-Host "  [+] CPU      : $($Snap.CPU)" -ForegroundColor White
    Write-Host "  [+] SESSION  : $($Snap.SessionId)" -ForegroundColor White
    Write-Host ""
    Write-Host "  NFS PROGRAMMER CLI v$($VersionInfo.version)" -ForegroundColor Red
    Write-Host "  $($VersionInfo.tagline)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  NFS://CORE ONLINE" -ForegroundColor Green
    Start-Sleep -Milliseconds ([int](400 * $Speed))
}

function Invoke-CinematicIntro {
    param(
        [object]$Config,
        [object]$VersionInfo,
        [switch]$Fast,
        [switch]$NoIntro
    )

    # Honor No-Intro flags
    if ($NoIntro -or ($Config -and $Config.animations -eq "none")) {
        return
    }

    # Speed calculation
    $speed = 1.0
    if ($Fast -or ($Config -and $Config.animation_speed -eq "fast")) {
        $speed = 0.4
    } elseif ($Config -and $Config.animations -eq "minimal") {
        $speed = 0.5
    }

    # Snapshot system once
    $snap = Get-SystemSnapshot

    # Check terminal width: if small (< 78), run compact version
    if ($snap.TerminalWidth -lt 78) {
        Show-CompactCinematicIntro -Snap $snap -VersionInfo $versionInfo -Speed $speed
        return
    }

    # Cursor hiding with guaranteed restoration in finally
    $cursorWasVisible = $true
    try {
        $cursorWasVisible = [Console]::CursorVisible
        [Console]::CursorVisible = $false
    } catch {}

    try {
        # Check for keypress during any phase to allow fast user skip
        $checkSkip = {
            try {
                if (-not [Console]::IsInputRedirected -and [Console]::KeyAvailable) {
                    $null = [Console]::ReadKey($true)
                    return $true
                }
            } catch {}
            return $false
        }

        # -------------------------------------------------------------
        # PHASE 00: TERMINAL AWAKENING (0.0s -> 0.3s)
        # -------------------------------------------------------------
        [Console]::BackgroundColor = 'Black'
        Clear-NFSConsole
        Write-Host "`n`n"
        Write-Host "  _ " -NoNewline -ForegroundColor DarkRed
        Start-Sleep -Milliseconds ([int](120 * $speed))
        if (& $checkSkip) { return }

        Write-Host "`r  NFS://BOOT" -ForegroundColor Red
        Start-Sleep -Milliseconds ([int](100 * $speed))
        Write-Host "  NFS CORE INITIALIZING..." -ForegroundColor DarkGray
        Start-Sleep -Milliseconds ([int](150 * $speed))
        if (& $checkSkip) { return }

        # -------------------------------------------------------------
        # PHASE 01: CONTROLLED DATA IGNITION & HEX STREAMS (0.3s -> 0.8s)
        # -------------------------------------------------------------
        $hexSeeds = @(
            "0x7F  A2  09  FF  18  4C  >>  NFS::KERNEL_V2_INIT",
            "NFS::CORE::01::A7::FF  [BUS: BUS_OK]  0x00A4 0x7E10",
            "7B 0A 19 C4 88 2D 91 EF  ||  TELEMETRY_ENGINE: ENGAGED",
            "0x99 0xFA 0x11 0x4B 0x77  >>  SECURITY_CONSTRAINTS: ACTIVE",
            "SYSTEM_DESCRIPTOR: WIN-x64-HYPERLINK  0x3F 0x8C 0x12"
        )

        foreach ($stream in $hexSeeds) {
            Write-Host "  $stream" -ForegroundColor DarkGray
            Start-Sleep -Milliseconds ([int](50 * $speed))
            if (& $checkSkip) { return }
        }

        # -------------------------------------------------------------
        # PHASE 02 & 03: LIVE SYSTEM HUD & TELEMETRY GAUGES (0.8s -> 1.4s)
        # -------------------------------------------------------------
        Clear-NFSConsole
        Write-Host ""
        Write-Host "  ── NFS://CORE ──────────────────────────  ── SYSTEM HUD ──────────────────────────" -ForegroundColor DarkRed
        Write-Host "     SESSION : $($snap.SessionId.PadRight(25))    HOST    : $($snap.HostName.PadRight(25))" -ForegroundColor White
        Write-Host "     ARCH    : $($snap.Arch.PadRight(25))    OS      : $($snap.OS.PadRight(25))" -ForegroundColor White
        Write-Host "     PS_VER  : $($snap.PSVersion.PadRight(25))    RAM     : $($("$($snap.RAM) GB PHYSICAL").PadRight(25))" -ForegroundColor White
        Write-Host "  ────────────────────────────────────────  ────────────────────────────────────────" -ForegroundColor DarkRed
        Write-Host ""

        # Telemetry progress gauges
        $gauges = @(
            @{ Label = "CPU "; Pct = 80;  Color = "Red";     Note = "OPERATIONAL" },
            @{ Label = "MEM "; Pct = 65;  Color = "DarkRed"; Note = "$($snap.RAM) GB STACK READY" },
            @{ Label = "CORE"; Pct = 100; Color = "White";   Note = "SYNCHRONIZED" }
        )

        foreach ($g in $gauges) {
            $bars = [Math]::Floor($g.Pct / 5)
            $empty = 20 - $bars
            $barStr = ("#" * $bars) + ("-" * $empty)
            Write-Host ("  {0}  [{1}] {2,3}%  >> {3}" -f $g.Label, $barStr, $g.Pct, $g.Note) -ForegroundColor $g.Color
            Start-Sleep -Milliseconds ([int](70 * $speed))
            if (& $checkSkip) { return }
        }

        # -------------------------------------------------------------
        # PHASE 04: NFS CORE GRAPH (1.4s -> 1.9s)
        # -------------------------------------------------------------
        Write-Host ""
        Write-Host "  NFS TOPOLOGY ACTIVATION:" -ForegroundColor DarkGray
        
        $graphStages = @(
            "          (o)--------(o)              [CORE_ENGINE]",
            "         /              \             [SYSTEM_DOCTOR]",
            "      (o)--(o)      (o)--(o)          [NETWORK_DOCTOR]",
            "       \     \      /                 [DEVELOPER_DOCTOR]",
            "        (o)---(*)--(o)                [WINGET_STUDIO]",
            "              |",
            "        NFS V2 ACTIVE"
        )

        foreach ($line in $graphStages) {
            $lineColor = if ($line -like "*(*) *") { "White" } elseif ($line -like "*V2 ACTIVE*") { "Green" } else { "Red" }
            Write-Host "  $line" -ForegroundColor $lineColor
            Start-Sleep -Milliseconds ([int](45 * $speed))
            if (& $checkSkip) { return }
        }

        Start-Sleep -Milliseconds ([int](180 * $speed))

        # -------------------------------------------------------------
        # PHASE 05 & 06: LOGO ASSEMBLY & QUANTUM SCAN BEAM (1.9s -> 2.8s)
        # -------------------------------------------------------------
        Clear-NFSConsole
        Write-Host ""

        $logoPath = ""
        $root = if ($script:NFS_ROOT) { $script:NFS_ROOT } else { (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) }
        $candidateLogo = Join-Path $root "assets\logo.txt"
        if (Test-Path $candidateLogo) {
            $logoLines = Get-Content $candidateLogo -Encoding UTF8
        } else {
            $logoLines = @(
                "       .-------------------------------------------.",
                "       | [o][o][o]                                 |",
                "       |  .-------------------------------------.  |",
                "       |  |    XXX    XX XXXXXXX XXXXXXX        |  |",
                "       |  |    XXXX   XX XX      XX             |  |",
                "       |  |    XX XX  XX XXXXX   XXXXXXX        |  |",
                "       |  |    XX  XX XX XX           XX        |  |",
                "       |  |    XX   XXXX XX      XXXXXXX        |  |",
                "       |  |    XX    XXX XX      XXXXXXX        |  |",
                "       |  '-------------------------------------'  |",
                "       '-------------------------------------------'"
            )
        }

        # Progressive Scan Wipe
        for ($scan = 0; $scan -lt $logoLines.Count; $scan += 2) {
            Set-NFSCursorPosition 0 2
            for ($i = 0; $i -lt $logoLines.Count; $i++) {
                if ($i -eq $scan -or $i -eq ($scan + 1)) {
                    Write-Host "  $($logoLines[$i])  << [QUANTUM_SCAN]" -ForegroundColor White
                } elseif ($i -lt $scan) {
                    Write-Host "  $($logoLines[$i])" -ForegroundColor Red
                } else {
                    Write-Host "  $($logoLines[$i])" -ForegroundColor DarkGray
                }
            }
            Start-Sleep -Milliseconds ([int](40 * $speed))
            if (& $checkSkip) { return }
        }

        # Final clean logo stabilization
        Set-NFSCursorPosition 0 2
        for ($i = 0; $i -lt $logoLines.Count; $i++) {
            Write-Host "  $($logoLines[$i])" -ForegroundColor Red
        }

        # -------------------------------------------------------------
        # PHASE 07: CONTROLLED MICRO-GLITCH TRANSITION (2.8s -> 3.0s)
        # -------------------------------------------------------------
        if ($speed -gt 0.3) {
            Start-Sleep -Milliseconds 60
            Set-NFSCursorPosition 0 5
            Write-Host "   >> 0x7F::NFS_GLITCH_DISPLACEMENT_CORRECTED << " -ForegroundColor DarkRed
            Start-Sleep -Milliseconds 50
            Set-NFSCursorPosition 0 5
            Write-Host "  $($logoLines[3])" -ForegroundColor Red
        }

        # -------------------------------------------------------------
        # PHASE 08 & 09: BRAND REVEAL & SYSTEM LOCK (3.0s -> 3.5s)
        # -------------------------------------------------------------
        Write-Host "  ─────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkRed
        Write-Host "  ⚡ NFS PROGRAMMER CLI " -ForegroundColor Red -NoNewline
        Write-Host "v$($VersionInfo.version) " -ForegroundColor DarkGray -NoNewline
        Write-Host "── $($VersionInfo.tagline)" -ForegroundColor Gray
        Write-Host "  ─────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkRed
        Write-Host ""
        Start-Sleep -Milliseconds ([int](120 * $speed))
        if (& $checkSkip) { return }

        # System Lock indicators
        $checkMark = [char]0x2713
        Write-Host "  SYSTEM LOCK STATUS:" -ForegroundColor DarkGray
        Write-Host "  [$checkMark] CORE ENGINE      : ONLINE" -ForegroundColor Green
        Start-Sleep -Milliseconds ([int](60 * $speed))
        Write-Host "  [$checkMark] MODULES DISCOVERY: $($snap.DiscoveredModules) MODULES READY" -ForegroundColor Green
        Start-Sleep -Milliseconds ([int](60 * $speed))
        Write-Host "  [$checkMark] ENVIRONMENT      : $($snap.OS) ($($snap.Arch))" -ForegroundColor Green
        Start-Sleep -Milliseconds ([int](60 * $speed))
        Write-Host "  [$checkMark] SESSION STATE    : $($snap.SessionId) INITIALIZED" -ForegroundColor Green

        # -------------------------------------------------------------
        # PHASE 10: FINAL COMMAND & CLEAN HANDOFF (3.5s -> 3.8s)
        # -------------------------------------------------------------
        Write-Host ""
        Write-Host "  >> NFS://CORE ONLINE" -ForegroundColor Red
        Write-Host "  >> COMMAND INTERFACE READY." -ForegroundColor White
        Start-Sleep -Milliseconds ([int](350 * $speed))

    } catch {
        # Never let intro errors crash the application
        Write-Host "`n  [!] Startup animation bypassed: $($_.Exception.Message)" -ForegroundColor Yellow
        Start-Sleep -Milliseconds 300
    } finally {
        # Guaranteed restoration of cursor
        try {
            [Console]::CursorVisible = $true
        } catch {}
    }
}
