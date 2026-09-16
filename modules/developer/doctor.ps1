# ============================================================
#  NFS CLI V2 - developer/doctor.ps1
#  Developer Doctor: Tool Detection, Version Audits & Quick Install
# ============================================================

function Get-DevToolStatus {
    $tools = @(
        @{ Name = "Git";              Cmd = "git";        Args = "--version";              WingetId = "Git.Git" },
        @{ Name = "Python";           Cmd = "python";     Args = "--version";              WingetId = "Python.Python.3.12" },
        @{ Name = "Node.js";          Cmd = "node";       Args = "--version";              WingetId = "OpenJS.NodeJS.LTS" },
        @{ Name = "npm";              Cmd = "npm";        Args = "--version";              WingetId = $null },
        @{ Name = "Java / JDK";       Cmd = "java";       Args = "-version";               WingetId = "EclipseAdoptium.Temurin.21.JDK" },
        @{ Name = "Go (Golang)";      Cmd = "go";         Args = "version";                WingetId = "GoLang.Go" },
        @{ Name = "Rust";             Cmd = "rustc";      Args = "--version";              WingetId = "Rustlang.Rustup" },
        @{ Name = "Docker";           Cmd = "docker";     Args = "--version";              WingetId = "Docker.DockerDesktop" },
        @{ Name = "VS Code";          Cmd = "code";       Args = "--version";              WingetId = "Microsoft.VisualStudioCode" },
        @{ Name = "Flutter";          Cmd = "flutter";    Args = "--version";              WingetId = "Google.FlutterSDK" },
        @{ Name = "Android SDK / adb";Cmd = "adb";        Args = "version";                WingetId = "Google.PlatformTools" },
        @{ Name = "PowerShell 7";     Cmd = "pwsh";       Args = "--version";              WingetId = "Microsoft.PowerShell" },
        @{ Name = "Windows Terminal"; Cmd = "wt";         Args = "-v";                     WingetId = "Microsoft.WindowsTerminal" }
    )

    $results = @()
    foreach ($t in $tools) {
        $installed = $false
        $versionStr = "Not installed"

        $cmdObj = Get-Command $t.Cmd -ErrorAction SilentlyContinue
        if ($cmdObj) {
            $installed = $true
            try {
                $psi = [System.Diagnostics.ProcessStartInfo]::new()
                $psi.FileName = $t.Cmd
                $psi.Arguments = $t.Args
                $psi.RedirectStandardOutput = $true
                $psi.RedirectStandardError = $true
                $psi.UseShellExecute = $false
                $psi.CreateNoWindow = $true

                $proc = [System.Diagnostics.Process]::Start($psi)
                $output = $proc.StandardOutput.ReadToEnd()
                $errorOut = $proc.StandardError.ReadToEnd()
                [void]$proc.WaitForExit(1000)

                $rawOut = if (-not [string]::IsNullOrWhiteSpace($output)) { $output } else { $errorOut }
                if ($rawOut) {
                    $firstLine = ($rawOut -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -First 1).Trim()
                    $cleanVer = $firstLine -replace "(?i)^.*?version\s*", "" -replace "(?i)^.*?(\d+\.\d+(\.\d+)?)", '$1'
                    $versionStr = if ($cleanVer.Length -gt 24) { $cleanVer.Substring(0, 21) + "..." } else { $cleanVer }
                } else {
                    $versionStr = "Installed"
                }
            } catch {
                $versionStr = "Installed"
            }
        } elseif ($t.Name -eq "Windows Terminal") {
            $appx = Get-AppxPackage *WindowsTerminal* -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($appx) {
                $installed = $true
                $versionStr = $appx.Version
            }
        } elseif ($t.Name -eq "Android SDK / adb") {
            if ($env:ANDROID_HOME -or $env:ANDROID_SDK_ROOT) {
                $installed = $true
                $versionStr = "SDK Configured"
            }
        }

        $results += [PSCustomObject]@{
            Name      = $t.Name
            Cmd       = $t.Cmd
            Installed = $installed
            Version   = $versionStr
            WingetId  = $t.WingetId
        }
    }
    return $results
}

function Show-DeveloperDoctor {
    $chk = [char]0x2713
    $cross = [char]0x2717

    while ($true) {
        Clear-Host
        Write-Section "DEVELOPER DOCTOR - ENVIRONMENT AUDIT"
        Write-Host "  Scanning path and toolchains for developer runtimes, compilers, and IDEs..." -ForegroundColor DarkGray
        Write-Host ""

        $audit = Get-DevToolStatus

        Write-Host ("  {0,-22} {1,-14} {2}" -f "TOOL / RUNTIME", "STATUS", "DETECTED VERSION") -ForegroundColor DarkYellow
        Write-HR "-" 64

        $missingWithWinget = @()
        foreach ($item in $audit) {
            $statusText = if ($item.Installed) { "$chk Installed" } else { "$cross Missing" }
            $statusColor = if ($item.Installed) { "Green" } else { "DarkGray" }
            $verColor = if ($item.Installed) { "White" } else { "DarkGray" }

            Write-Host ("  {0,-22} " -f $item.Name) -NoNewline -ForegroundColor White
            Write-Host ("{0,-14} " -f $statusText) -NoNewline -ForegroundColor $statusColor
            Write-Host $item.Version -ForegroundColor $verColor

            if (-not $item.Installed -and $item.WingetId) {
                $missingWithWinget += $item
            }
        }

        Write-HR "-" 64
        Write-Host ""

        Write-Host "  AUDIT ACTIONS" -ForegroundColor Yellow
        Write-Host "    [1] " -ForegroundColor Cyan -NoNewline; Write-Host "Install a Missing Tool via Winget" -ForegroundColor White
        Write-Host "    [2] " -ForegroundColor White -NoNewline; Write-Host "Refresh Environment Audit" -ForegroundColor White
        Write-Host ""
        Write-Host "  NAVIGATION" -ForegroundColor Yellow
        Write-Host "    [B] " -ForegroundColor DarkGray -NoNewline; Write-Host "Back" -ForegroundColor White
        Write-Host ("  " + ("=" * 64)) -ForegroundColor DarkBlue
        Write-Host ""

        Write-Host "  >> Select option: " -ForegroundColor Cyan -NoNewline
        $choice = (Read-Host).Trim().ToUpper()
        switch ($choice) {
            "1" {
                if ($missingWithWinget.Count -eq 0) {
                    Write-Success "All supported developer tools are already installed!"
                    Pause-Menu
                    continue
                }
                Clear-Host
                Write-Section "INSTALL MISSING DEVELOPER TOOLS"
                Write-Host "  Select a tool to install via Windows Package Manager (Winget):" -ForegroundColor DarkGray
                Write-Host ""
                for ($i = 0; $i -lt $missingWithWinget.Count; $i++) {
                    Write-Host ("  [{0}] {1,-20} (Winget ID: {2})" -f ($i + 1), $missingWithWinget[$i].Name, $missingWithWinget[$i].WingetId) -ForegroundColor Cyan
                }
                Write-Host "  [B] Cancel" -ForegroundColor DarkGray
                Write-Host ""

                $pick = Read-Host "  Select tool #"
                if ($pick.ToUpper() -eq "B") { continue }
                if ([int]::TryParse($pick, [ref]$idx) -and $idx -ge 1 -and $idx -le $missingWithWinget.Count) {
                    $selected = $missingWithWinget[$idx - 1]
                    Write-Host ""
                    Write-Warn "You are about to install: $($selected.Name) ($($selected.WingetId))"
                    $confirm = (Read-Host "  Confirm installation? [Y/N]").Trim().ToUpper()
                    if ($confirm -eq "Y") {
                        Install-WingetApp $selected.Name $selected.WingetId
                        Pause-Menu
                    }
                }
            }
            "2" { continue }
            "B" { return }
            default { Write-Warn "Invalid choice." ; Start-Sleep 1 }
        }
    }
}
