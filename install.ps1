# ============================================================
#  NFS PROGRAMMER CLI V2 - install.ps1
#  One-line remote bootstrapper & environment setup
#  Usage: irm https://raw.githubusercontent.com/nfsprogramming/nfs-cli/main/install.ps1 | iex
# ============================================================

$ErrorActionPreference = "Continue"

$REPO   = "nfsprogramming/nfs-cli"
$BRANCH = "main"
$RAW    = "https://raw.githubusercontent.com/$REPO/$BRANCH"
$INSTALL_DIR = "$env:USERPROFILE\nfs-cli"

Write-Host ""
Write-Host "  +-------------------------------------------------------+" -ForegroundColor Red
Write-Host "  |       NFS PROGRAMMER CLI V2 - INSTALLER               |" -ForegroundColor Red
Write-Host "  |    Windows Developer & System Engineering Toolkit     |" -ForegroundColor DarkGray
Write-Host "  +-------------------------------------------------------+" -ForegroundColor Red
Write-Host ""
Write-Host "  Target Directory: $INSTALL_DIR" -ForegroundColor Cyan
Write-Host ""

# -- Files to download -----------------------------------------
$files = @(
    "main.ps1",
    "nfs.cmd",
    "CHANGELOG.md",
    "README.md",
    "USER_MANUAL.md",
    "modules/helpers.ps1",
    "modules/scripts.ps1",
    "modules/tools.ps1",
    "modules/devkit.ps1",
    "modules/drivers.ps1",
    "modules/customapps.ps1",
    "modules/gamesetup.ps1",
    "modules/isotools.ps1",
    "modules/isos.ps1",
    "modules/mywebs.ps1",
    "modules/optimizer.ps1",
    "modules/maintenance.ps1",
    "modules/about.ps1",
    "modules/python_scripts.ps1",
    "modules/core/cinematic.ps1",
    "modules/core/config.ps1",
    "modules/core/logger.ps1",
    "modules/core/terminal.ps1",
    "modules/core/update.ps1",
    "modules/system/doctor.ps1",
    "modules/system/performance.ps1",
    "modules/system/eventlogs.ps1",
    "modules/network/doctor.ps1",
    "modules/developer/doctor.ps1",
    "modules/developer/packages.ps1",
    "assets/logo.txt",
    "assets/configs/config.json",
    "assets/configs/version.json",
    "assets/configs/apps.json",
    "assets/configs/drivers.json",
    "assets/configs/isos.json",
    "assets/configs/mywebs.json"
)

$i = 0
foreach ($file in $files) {
    $i++
    $pct  = [int](($i / $files.Count) * 100)
    $localPath = Join-Path $INSTALL_DIR $file.Replace("/", "\")
    $dir  = Split-Path $localPath -Parent

    Write-Progress -Activity "NFS CLI V2 Installer" -Status "Downloading $file" -PercentComplete $pct

    if (-not (Test-Path $dir)) { New-Item $dir -ItemType Directory -Force | Out-Null }

    try {
        Invoke-WebRequest "$RAW/$file" -OutFile $localPath -UseBasicParsing -ErrorAction Stop
        Write-Host "  [OK] $file" -ForegroundColor Green
    } catch {
        Write-Host "  [X] Failed: $file" -ForegroundColor Red
    }
}

Write-Progress -Activity "NFS CLI V2 Installer" -Completed

# -- Add to User PATH if not present ----------------------------
try {
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($userPath -notlike "*$INSTALL_DIR*") {
        [Environment]::SetEnvironmentVariable("Path", "$userPath;$INSTALL_DIR", "User")
        Write-Host "  [OK] Added $INSTALL_DIR to User PATH (run 'nfs' anywhere)." -ForegroundColor Green
    }
} catch {
    Write-Host "  [!] Could not add to PATH: $($_.Exception.Message)" -ForegroundColor Yellow
}

# -- Create desktop shortcut -----------------------------------
try {
    $desktopPath  = [Environment]::GetFolderPath("Desktop")
    $shortcutPath = Join-Path $desktopPath "NFS CLI.lnk"
    $wsh  = New-Object -ComObject WScript.Shell
    $link = $wsh.CreateShortcut($shortcutPath)
    $link.TargetPath       = "powershell.exe"
    $link.Arguments        = "-NoExit -ExecutionPolicy Bypass -File `"$INSTALL_DIR\main.ps1`""
    $link.WorkingDirectory = $INSTALL_DIR
    $link.Description      = "NFS Programmer CLI V2 - Windows Developer & System Toolkit"
    $link.Save()
    Write-Host "  [OK] Desktop shortcut created: NFS CLI.lnk" -ForegroundColor Green
} catch {
    Write-Host "  [!] Could not create desktop shortcut. Error: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "  ----------------------------------------------------" -ForegroundColor DarkRed
Write-Host "  NFS Programmer CLI V2 Installation complete!" -ForegroundColor Red
Write-Host "  Run with:  powershell -ExecutionPolicy Bypass -File `"$INSTALL_DIR\main.ps1`"" -ForegroundColor White
Write-Host "  Or simply type:  nfs" -ForegroundColor Green
Write-Host "  Or double-click 'NFS CLI' on your Desktop." -ForegroundColor White
Write-Host "  ----------------------------------------------------" -ForegroundColor DarkRed
Write-Host ""

# -- Auto-launch -----------------------------------------------
$launch = Read-Host "  Launch NFS CLI V2 now? (Y/N)"
if ($launch -and $launch.ToUpper() -eq "Y") {
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$INSTALL_DIR\main.ps1"
}
