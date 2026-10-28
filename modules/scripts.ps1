# ============================================================
#  NFS CLI - scripts.ps1
#  Quick system scripts and one-click Windows fixes
# ============================================================
. "$PSScriptRoot\helpers.ps1"

function Show-ScriptsMenu {
    while ($true) {
        Clear-Host
        Write-Section "SCRIPTS"
        Write-Host ""
        Write-Host "  +-----------------------------------------------------+" -ForegroundColor DarkCyan
        Write-Host "  |  1.  Microsoft Activation Scripts (MAS)             |" -ForegroundColor Green
        Write-Host "  |  2.  Spicetify (User Mode - Safe Patch)             |" -ForegroundColor Green
        Write-Host "  |  3.  Flush DNS Cache                                |" -ForegroundColor Cyan
        Write-Host "  |  4.  Reset Windows Update                           |" -ForegroundColor Cyan
        Write-Host "  |  5.  Clear Temp Files                               |" -ForegroundColor Cyan
        Write-Host "  |  6.  Repair System Files (SFC + DISM)               |" -ForegroundColor Cyan
        Write-Host "  |  7.  Network Reset (Winsock + TCP/IP)               |" -ForegroundColor Cyan
        Write-Host "  |  8.  Enable/Disable Hyper-V                        |" -ForegroundColor Cyan
        Write-Host "  |  9.  Enable WSL2 (Windows Subsystem for Linux)      |" -ForegroundColor Cyan
        Write-Host "  |  10. Optimize SSD (TRIM)                           |" -ForegroundColor Cyan
        Write-Host "  |  11. Show System Info                               |" -ForegroundColor Cyan
        Write-Host "  |  12. Restart Explorer                               |" -ForegroundColor Cyan
        Write-Host "  |  13. Chris Titus Tech Windows Utility               |" -ForegroundColor Green
        Write-Host "  |  14. Win11 Debloater (Universal)                    |" -ForegroundColor Green
        Write-Host "  |  15. Reset Windows Store (WSReset)                  |" -ForegroundColor Cyan
        Write-Host "  |  16. NFS Ultra Optimizer (Gaming Mode)              |" -ForegroundColor Yellow
        Write-Host "  |  17. NFS Wallpaper Manager                          |" -ForegroundColor Green
        Write-Host "  |  18. NFS MyApps (IDM Supreme)                       |" -ForegroundColor Cyan
        Write-Host "  |  B.  Back                                           |" -ForegroundColor DarkGray
        Write-Host "  +-----------------------------------------------------+" -ForegroundColor DarkCyan
        Write-Host ""
        $choice = (Read-Host "  Select").Trim().ToUpper()

        switch ($choice) {
            "1"  { Invoke-MAS }
            "2"  { Invoke-Spicetify }
            "3"  { Invoke-FlushDNS }
            "4"  { Invoke-ResetWindowsUpdate }
            "5"  { Invoke-ClearTemp }
            "6"  { Invoke-RepairSystem }
            "7"  { Invoke-NetworkReset }
            "8"  { Invoke-ToggleHyperV }
            "9"  { Invoke-EnableWSL }
            "10" { Invoke-OptimizeSSD }
            "11" { Show-SystemInfo }
            "12" { Invoke-RestartExplorer }
            "13" { Invoke-CTTTool }
            "14" { Invoke-WinDebloat }
            "15" { Invoke-StoreReset }
            "16" { Invoke-UltraOptimizer }
            "17" { Show-WallpaperMenu }
            "18" { Invoke-IDMCrack }
            "B"  { return }
            default { Write-Warn "Invalid option." ; Start-Sleep 1 }
        }
    }
}

function Invoke-CTTTool {
    Write-Section "CHRIS TITUS TECH TOOL"
    Write-Info "Launching the ultimate Windows utility..."
    $cmd = "iwr -useb https://christitus.com/win | iex"
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command $cmd
}

function Invoke-WinDebloat {
    Write-Section "WINDOWS 11 DEBLOATER"
    Write-Info "Opening the Universal Debloater script..."
    $cmd = "irm https://raw.githubusercontent.com/Raphire/Win11Debloater/master/Win11Debloater.ps1 | iex"
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command $cmd
}

function Invoke-MAS {
    Write-Section "MICROSOFT ACTIVATION SCRIPTS"
    Write-Info "Running MAS via official online script..."
    $cmd = "irm https://get.activated.win | iex"
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command $cmd
    Pause-Menu
}

function Invoke-Spicetify {
    Write-Section "SPICETIFY (USER MODE)"
    Write-Info "Launching Spicetify Installer..."
    Write-Info "Opening Non-Administrator PowerShell for Permission Safety..."
    
    # Create temporary script
    $tempScript = "$env:TEMP\spicetify_supreme_deploy.ps1"
    
    $content = @"
Clear-Host
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Write-Host ">>> NFS SUPREME SPICETIFY DEPLOYMENT <<<" -ForegroundColor Green
Write-Host "---------------------------------------" -ForegroundColor Gray
Write-Host ""
Write-Host "  >> TASK 1: Closing Spotify..." -ForegroundColor Cyan
Stop-Process -Name Spotify -Force -ErrorAction SilentlyContinue
Start-Sleep 1

Write-Host "  >> TASK 2: Fetching Spicetify CLI..." -ForegroundColor Cyan
iwr -useb https://raw.githubusercontent.com/spicetify/cli/main/install.ps1 | iex

# Force bypass admin check and clear existing backups
Write-Host "  >> TASK 2.1: Configuring Security Override..." -ForegroundColor Cyan
spicetify config bypass_admin 1
spicetify restore backup

Write-Host "  >> TASK 3: Fetching Marketplace..." -ForegroundColor Cyan
irm https://raw.githubusercontent.com/spicetify/spicetify-marketplace/main/resources/install.ps1 | iex

Write-Host "  >> TASK 4: Initializing Backup & Apply..." -ForegroundColor Cyan
spicetify backup apply --bypass-admin
spicetify apply --bypass-admin

Write-Host ""
Write-Host ">>> SUCCESS: Spicetify is now ready!" -ForegroundColor Green
Write-Host ">>> RESTART SPOTIFY TO SEE CHANGES." -ForegroundColor Yellow
Write-Host ""
Write-Host "Press any key to exit this window..."
`$null = [Console]::ReadKey(`$true)
"@

    $content | Out-File $tempScript -Encoding UTF8 -Force

    # Use a VBScript Bridge to reliably drop privileges and launch PowerShell.
    # This is the most compatible way to 'de-elevate' and prevents Explorer folder issues.
    try {
        Write-Info "Executing Supreme De-Elevation Bridge..."
        $vbsPath = "$env:TEMP\spicetify_bridge.vbs"
        # Correctly escape quotes for VBScript: double the double-quotes inside the string.
        $vbsContent = "Set objShell = CreateObject(`"Shell.Application`"): objShell.ShellExecute `"powershell.exe`", `"-NoProfile -ExecutionPolicy Bypass -File `"`"$tempScript`"`"`", `"`", `"open`", 1"
        $vbsContent | Out-File $vbsPath -Encoding ASCII -Force
        
        Start-Process "wscript.exe" -ArgumentList "`"$vbsPath`"" -Wait
        Remove-Item $vbsPath -Force -ErrorAction SilentlyContinue
        Write-Success "Handoff Successful: Spicetify is deploying in User Mode."
    } catch {
        Write-Warn "Bridge failed. Falling back to standard process..."
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$tempScript`""
    }
    
    Pause-Menu
}


function Invoke-FlushDNS {
    Write-Section "FLUSH DNS"
    ipconfig /flushdns
    Write-Success "DNS cache cleared."
    Pause-Menu
}

function Invoke-ResetWindowsUpdate {
    Write-Section "RESET WINDOWS UPDATE"
    if (-not (Assert-Admin)) { Pause-Menu; return }
    Write-Step "Stopping services..."
    Stop-Service wuauserv, cryptSvc, bits, msiserver -Force -ErrorAction SilentlyContinue
    Write-Step "Renaming SoftwareDistribution & Catroot2..."
    Rename-Item "$env:SystemRoot\SoftwareDistribution" "SoftwareDistribution.old" -ErrorAction SilentlyContinue
    Rename-Item "$env:SystemRoot\System32\catroot2" "catroot2.old" -ErrorAction SilentlyContinue
    Write-Step "Restarting services..."
    Start-Service wuauserv, cryptSvc, bits, msiserver -ErrorAction SilentlyContinue
    Write-Success "Windows Update reset. Try updating now."
    Pause-Menu
}

function Invoke-ClearTemp {
    Write-Section "CLEAR TEMP FILES"
    $folders = @(
        $env:TEMP,
        $env:TMP,
        "$env:SystemRoot\Temp",
        "$env:LOCALAPPDATA\Temp"
    )
    $total = 0
    foreach ($f in $folders) {
        if (Test-Path $f) {
            $size = (Get-ChildItem $f -Recurse -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
            Get-ChildItem $f -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
            $total += $size
            Write-Info "Cleaned: $f"
        }
    }
    $mb = [Math]::Round($total / 1MB, 2)
    Write-Success "Freed approximately $mb MB."
    Pause-Menu
}

function Invoke-RepairSystem {
    Write-Section "REPAIR SYSTEM FILES"
    if (-not (Assert-Admin)) { Pause-Menu; return }
    Write-Step "Running SFC /scannow..."
    sfc /scannow
    Write-Step "Running DISM RestoreHealth..."
    DISM /Online /Cleanup-Image /RestoreHealth
    Write-Success "System repair complete."
    Pause-Menu
}

function Invoke-NetworkReset {
    Write-Section "NETWORK RESET"
    if (-not (Assert-Admin)) { Pause-Menu; return }
    netsh winsock reset
    netsh int ip reset
    ipconfig /release
    ipconfig /flushdns
    ipconfig /renew
    Write-Success "Network stack reset. Restart your PC for full effect."
    Pause-Menu
}

function Invoke-ToggleHyperV {
    Write-Section "HYPER-V TOGGLE"
    if (-not (Assert-Admin)) { Pause-Menu; return }
    $feature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
    if ($feature.State -eq "Enabled") {
        Write-Warn "Hyper-V is ENABLED. Disabling..."
        Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -NoRestart
        Write-Success "Hyper-V disabled. Restart required."
    } else {
        Write-Info "Hyper-V is DISABLED. Enabling..."
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -NoRestart
        Write-Success "Hyper-V enabled. Restart required."
    }
    Pause-Menu
}

function Invoke-EnableWSL {
    Write-Section "ENABLE WSL2"
    if (-not (Assert-Admin)) { Pause-Menu; return }
    Write-Step "Enabling WSL feature..."
    wsl --install
    Write-Success "WSL2 installation triggered. Follow on-screen prompts."
    Pause-Menu
}

function Invoke-OptimizeSSD {
    Write-Section "SSD TRIM"
    if (-not (Assert-Admin)) { Pause-Menu; return }
    Write-Step "Running Optimize-Volume on all drives..."
    Get-Volume | Where-Object { $_.DriveType -eq "Fixed" -and $_.DriveLetter } | ForEach-Object {
        Write-Info "Trimming drive $($_.DriveLetter)..."
        Optimize-Volume -DriveLetter $_.DriveLetter -ReTrim -Verbose
    }
    Write-Success "SSD optimization complete."
    Pause-Menu
}

function Show-SystemInfo {
    Write-Section "SYSTEM INFORMATION"
    $cs  = Get-CimInstance Win32_ComputerSystem
    $os  = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor
    $gpu = Get-CimInstance Win32_VideoController
    $ram = [Math]::Round($cs.TotalPhysicalMemory / 1GB, 2)

    Write-HR
    Write-Host "  Machine    : $($cs.Name)" -ForegroundColor White
    Write-Host "  Maker      : $($cs.Manufacturer) - $($cs.Model)" -ForegroundColor White
    Write-Host "  OS         : $($os.Caption) ($($os.Version))" -ForegroundColor White
    Write-Host "  CPU        : $($cpu.Name)" -ForegroundColor White
    Write-Host "  RAM        : $ram GB" -ForegroundColor White
    Write-Host "  GPU        : $($gpu.Name)" -ForegroundColor White
    $uptime = (Get-Date) - $os.LastBootUpTime
    $hrs = [Math]::Round($uptime.TotalHours, 2)
    Write-Host "  Uptime     : $hrs hrs" -ForegroundColor White
    Write-HR
    Pause-Menu
}

function Invoke-RestartExplorer {
    Write-Section "RESTART EXPLORER"
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep 1
    Start-Process explorer
    Write-Success "Explorer restarted."
    Pause-Menu
}

function Invoke-StoreReset {
    Write-Section "WINDOWS STORE RESET"
    Write-Info "Running wsreset.exe... Please wait."
    wsreset.exe
    Write-Success "Windows Store cache cleared."
    Pause-Menu
}

function Invoke-UltraOptimizer {
    Write-Section "NFS ULTRA OPTIMIZER"
    if (-not (Assert-Admin)) { Pause-Menu; return }
    
    Write-Host "  [1] Enable (Gaming Mode)  [2] Disable (Restore Defaults)" -ForegroundColor Yellow
    $mode = Read-Host "  Select"
    
    if ($mode -eq "1") {
        Write-Step "Setting Power Plan to Ultimate Performance..."
        # Duplicating and setting the Ultimate Performance scheme
        powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
        powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61
        
        Write-Step "Disabling Power Throttling..."
        reg add "HKLM\System\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d 1 /f | Out-Null
        
        Write-Step "Optimizing CPU Priority for Games..."
        # NetworkThrottlingIndex: FFFFFFFF disables throttling
        reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 4294967295 /f | Out-Null
        # SystemResponsiveness: 0 prioritizes games over background tasks
        reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f | Out-Null
        
        Write-Success "NFS Ultra Optimization Applied!"
    } elseif ($mode -eq "2") {
        Write-Step "Reverting Power Plan to Balanced..."
        powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e
        
        Write-Step "Enabling Power Throttling (Default)..."
        reg delete "HKLM\System\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /f 2>$null
        
        Write-Step "Restoring System Profile Defaults..."
        reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 10 /f | Out-Null
        reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 20 /f | Out-Null
        
        Write-Success "NFS Ultra Optimization Reverted to Defaults."
    } else {
        Write-Warn "Action cancelled."
    }
    Pause-Menu
}

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@ -ErrorAction SilentlyContinue

function Show-WallpaperMenu {
    Write-Section "NFS WALLPAPER MANAGER & SYNC"
    
    $desktopPath = Join-Path ([Environment]::GetFolderPath("Desktop")) "NFS Supreme Wallpapers"
    $wallDirCandidate = Get-ChildItem -Path $NFS_ROOT -Directory | Where-Object { $_.Name -like "Desktop Wallpapers*" } | Select-Object -First 1
    $localWallDir = if ($wallDirCandidate) { $wallDirCandidate.FullName } else { Join-Path $NFS_ROOT "Desktop Wallpapers...🖥️" }

    # Step 1: Sync from GitHub option
    Write-Question "Do you want to sync/download new wallpapers from GitHub to your Desktop? (y/n)"
    $syncChoice = Read-Host "> "
    if ($syncChoice -eq "y") {
        if (-not (Test-Path $desktopPath)) { New-Item -Path $desktopPath -ItemType Directory -Force | Out-Null }
        
        Write-Step "Downloading Supreme Wallpapers collection..."
        $zipPath = Join-Path $env:TEMP "walls.zip"
        $repoUrl = "https://github.com/nfsprogramming/nfs-cli/archive/refs/heads/main.zip" # Project Repo
        
        try {
            Invoke-WebRequest -Uri $repoUrl -OutFile $zipPath -ErrorAction Stop
            Write-Step "Extracting to Desktop..."
            $extractPath = Join-Path $env:TEMP "nfs_extract"
            if (Test-Path $extractPath) { Remove-Item $extractPath -Recurse -Force }
            Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
            
            # Find the wallpaper folder in the extracted content (handling emoji/naming)
            $extractedWallDir = Get-ChildItem -Path $extractPath -Recurse -Directory | Where-Object { $_.Name -like "Desktop Wallpapers*" } | Select-Object -First 1
            
            if ($extractedWallDir) {
                Copy-Item -Path "$($extractedWallDir.FullName)\*" -Destination $desktopPath -Force -Recurse
                Write-Success "Sync Complete! Wallpapers saved to: Desktop\NFS Supreme Wallpapers"
                explorer.exe $desktopPath
            } else {
                Write-Warn "Could not find wallpaper folder in the download. Manual import needed."
            }
        } catch {
            Write-Warn "Download failed. Check your internet connection."
        }
    }

    # Step 2: Show Manager (Prefer Desktop folder if it exists and has files, otherwise local)
    $wallDir = if (Test-Path $desktopPath) { $desktopPath } else { $localWallDir }
    
    if (-not (Test-Path $wallDir)) {
        Write-Warn "Wallpaper directory not found: $wallDir"
        Pause-Menu
        return
    }

    $files = Get-ChildItem -Path $wallDir -File | Where-Object { $_.Extension -match '\.(jpg|jpeg|png)$' }
    if (-not $files) {
        if ($wallDir -eq $desktopPath) {
            # Fallback to local if desktop is empty
            $wallDir = $localWallDir
            $files = Get-ChildItem -Path $wallDir -File | Where-Object { $_.Extension -match '\.(jpg|jpeg|png)$' }
        }
    }

    if (-not $files) {
        Write-Warn "No wallpapers found in $wallDir"
        Pause-Menu
        return
    }

    Write-Info "Available Wallpapers:"
    for ($i=0; $i -lt $files.Count; $i++) {
        $color = if ($i % 2 -eq 0) { "Cyan" } else { "Green" }
        Write-Host "  [$($i+1)] $($files[$i].Name)" -ForegroundColor $color
    }
    Write-Host "  [B] Back" -ForegroundColor DarkGray
    Write-HR

    $choice = Read-Host "Select a wallpaper number"
    if ($choice -eq "B") { return }

    if ([int]::TryParse($choice, [ref]$idx) -and $idx -le $files.Count -and $idx -gt 0) {
        $selected = $files[$idx-1].FullName
        Write-Step "Applying Wallpaper: $($files[$idx-1].Name)..."
        try {
            [Wallpaper]::SystemParametersInfo(0x0014, 0, $selected, 0x01 -bor 0x02) | Out-Null
            Write-Success "Wallpaper Applied Successfully!"
        } catch {
            Write-Warn "Failed to set wallpaper. You may need to do it manually."
        }
    } else {
        Write-Warn "Invalid selection."
    }
    Pause-Menu
}

function Invoke-IDMCrack {
    Write-Section "NFS MYAPPS - IDM SUPREME"
    $crackPath = Join-Path $NFS_ROOT "myapps\IDM_6.4x_Crack_v20.6.exe"
    
    if (Test-Path $crackPath) {
        Write-Step "Launching IDM Crack..."
        Write-Info "Please follow the instructions in the crack installer."
        Start-Process $crackPath -Verb RunAs
        Write-Success "IDM Crack launched with Admin privileges."
    } else {
        Write-Warn "IDM Crack not found at: $crackPath"
    }
    Pause-Menu
}
