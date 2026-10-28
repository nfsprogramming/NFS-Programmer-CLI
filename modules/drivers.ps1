# ============================================================
#  NFS CLI - drivers.ps1
#  Auto-detect PC brand + GPU, install driver manager
# ============================================================
. "$PSScriptRoot\helpers.ps1"

function Show-DriversMenu {
    while ($true) {
        Clear-Host
        Write-Section "DRIVER UPDATE"
        Write-Host ""

        # Detect system info
        $cs  = Get-CimInstance Win32_ComputerSystem
        $gpu = Get-CimInstance Win32_VideoController | Select-Object -First 1

        Write-Host "  Detected System" -ForegroundColor DarkYellow
        Write-HR
        Write-Host "  Manufacturer : $($cs.Manufacturer)" -ForegroundColor White
        Write-Host "  Model        : $($cs.Model)" -ForegroundColor White
        Write-Host "  GPU          : $($gpu.Name)" -ForegroundColor White
        Write-HR
        Write-Host ""

        Write-Host "  +-----------------------------------------------------+" -ForegroundColor DarkGreen
        Write-Host "  |  1.  Auto-Install Manufacturer Driver App           |" -ForegroundColor Cyan
        Write-Host "  |  2.  Open GPU Driver Download Page                  |" -ForegroundColor Cyan
        Write-Host "  |  3.  Install NVIDIA GeForce Experience              |" -ForegroundColor Cyan
        Write-Host "  |  4.  Install AMD Radeon Software                    |" -ForegroundColor Cyan
        Write-Host "  |  5.  Install Intel Driver & Support Assistant       |" -ForegroundColor Cyan
        Write-Host "  |  6.  Open Windows Update (generic drivers)          |" -ForegroundColor Cyan
        Write-Host "  |  7.  Show All Device Drivers (Device Manager)       |" -ForegroundColor Cyan
        Write-Host "  |  B.  Back                                           |" -ForegroundColor DarkGray
        Write-Host "  +-----------------------------------------------------+" -ForegroundColor DarkGreen
        Write-Host ""
        $choice = (Read-Host "  Select").Trim().ToUpper()

        switch ($choice) {
            "1"  { Invoke-AutoDriverInstall $cs.Manufacturer }
            "2"  { Invoke-GPUDriverPage $gpu.Name }
            "3"  { Install-WingetApp "NVIDIA GeForce Experience" "Nvidia.GeForceExperience" ; Pause-Menu }
            "4"  { Install-WingetApp "AMD Software: Adrenalin"   "AdvancedMicroDevices.AMDSoftwareAdrenalinEdition" ; Pause-Menu }
            "5"  { Open-Url "https://www.intel.com/content/www/us/en/support/detect.html" "Intel Driver Assistant" ; Pause-Menu }
            "6"  { Start-Process "ms-settings:windowsupdate" ; Pause-Menu }
            "7"  { Start-Process devmgmt.msc ; Pause-Menu }
            "B"  { return }
            default { Write-Warn "Invalid option." ; Start-Sleep 1 }
        }
    }
}

function Invoke-AutoDriverInstall {
    param([string]$Manufacturer)
    Write-Section "AUTO DRIVER INSTALL"
    $config = Get-Config "drivers.json"
    if (-not $config) { Pause-Menu; return }

    $matched = $false
    foreach ($m in $config.manufacturers) {
        if ($Manufacturer -match $m.match) {
            Write-Info "Detected: $($m.label)"
            Write-Step "Installing $($m.label)..."
            if (-not (Assert-Winget)) { return }
            winget install --id $m.app -e --accept-source-agreements --accept-package-agreements --silent 2>&1 | Out-Null
            Write-Success "$($m.label) installed. Open it to update drivers."
            $matched = $true
            break
        }
    }

    if (-not $matched) {
        Write-Warn "Manufacturer '$Manufacturer' not recognized."
        Write-Info "Opening generic Windows Update instead..."
        Start-Process "ms-settings:windowsupdate"
    } else {
        Write-Host ""
        Write-Host "  [!] Drivers require a system restart to finalize changes." -ForegroundColor Yellow
        $restart = (Read-Host "  Restart now? (Y/N)").Trim().ToUpper()
        if ($restart -eq "Y") {
            Write-Success "Restarting system..."
            Start-Sleep 2
            Restart-Computer -Force
        } else {
            Write-Info "Please remember to restart your system manually."
        }
    }
    Pause-Menu
}

function Invoke-GPUDriverPage {
    param([string]$GpuName)
    Write-Section "GPU DRIVER PAGE"
    $config = Get-Config "drivers.json"
    if (-not $config) { Pause-Menu; return }

    $matched = $false
    foreach ($g in $config.gpu) {
        if ($GpuName -match $g.match) {
            Write-Info "Detected GPU vendor: $($g.match)"
            Open-Url $g.url $g.label
            $matched = $true
            break
        }
    }

    if (-not $matched) {
        Write-Warn "GPU vendor not detected from name: '$GpuName'"
        Write-Info "Opening general Windows Update..."
        Start-Process "ms-settings:windowsupdate"
    }
    Pause-Menu
}

