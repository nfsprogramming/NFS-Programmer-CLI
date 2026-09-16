# ============================================================
#  NFS CLI V2 - developer/packages.ps1
#  Winget Studio: Package Search, Installation, Updates & Backup
# ============================================================

function Show-PackageManagerMenu {
    if (-not (Assert-Winget)) {
        Pause-Menu
        return
    }

    while ($true) {
        Clear-Host
        Write-Section "PACKAGE MANAGEMENT (WINGET STUDIO)"
        Write-Host ""
        Write-Host "  :: WINGET PACKAGE STUDIO" -ForegroundColor Cyan
        Write-Host ("  " + ("=" * 70)) -ForegroundColor DarkCyan
        Write-Host "  Manage Windows applications, runtimes, and developer packages using official Winget." -ForegroundColor DarkGray
        Write-Host ""

        Write-Host "  OPERATIONS" -ForegroundColor Yellow
        Write-Host "    [1] " -ForegroundColor Cyan -NoNewline; Write-Host "Search Packages" -ForegroundColor White
        Write-Host "    [2] " -ForegroundColor Cyan -NoNewline; Write-Host "Install Package by ID or Name" -ForegroundColor White
        Write-Host "    [3] " -ForegroundColor Yellow -NoNewline; Write-Host "Check for App Updates (winget upgrade)" -ForegroundColor White
        Write-Host "    [4] " -ForegroundColor Green -NoNewline; Write-Host "Upgrade All Installed Apps" -ForegroundColor White
        Write-Host "    [5] " -ForegroundColor Red -NoNewline; Write-Host "Uninstall an Application" -ForegroundColor White
        Write-Host "    [6] " -ForegroundColor White -NoNewline; Write-Host "Export Installed Packages List (JSON)" -ForegroundColor White
        Write-Host "    [7] " -ForegroundColor White -NoNewline; Write-Host "Import Packages List (Batch Install)" -ForegroundColor White
        Write-Host ""
        Write-Host "  NAVIGATION" -ForegroundColor Yellow
        Write-Host "    [B] " -ForegroundColor DarkGray -NoNewline; Write-Host "Back" -ForegroundColor White
        Write-Host ("  " + ("=" * 70)) -ForegroundColor DarkCyan
        Write-Host ""

        Write-Host "  >> Select option: " -ForegroundColor Cyan -NoNewline
        $choice = (Read-Host).Trim().ToUpper()
        switch ($choice) {
            "1" { Invoke-WingetSearch }
            "2" { Invoke-WingetInstallPrompt }
            "3" { Invoke-WingetCheckUpdates }
            "4" { Invoke-WingetUpgradeAll }
            "5" { Invoke-WingetUninstallPrompt }
            "6" { Invoke-WingetExport }
            "7" { Invoke-WingetImport }
            "B" { return }
            default { Write-Warn "Invalid choice." ; Start-Sleep 1 }
        }
    }
}

function Invoke-WingetSearch {
    Clear-Host
    Write-Section "SEARCH PACKAGES"
    $query = Read-Host "  Enter app or package name to search"
    if ([string]::IsNullOrWhiteSpace($query)) { return }

    Write-Step "Searching official package repositories for '$query'..."
    winget search $query
    Pause-Menu
}

function Invoke-WingetInstallPrompt {
    Clear-Host
    Write-Section "INSTALL PACKAGE"
    $pkgId = Read-Host "  Enter Winget Package ID (e.g. Git.Git, VideoLAN.VLC)"
    if ([string]::IsNullOrWhiteSpace($pkgId)) { return }

    Install-WingetApp $pkgId $pkgId
    Pause-Menu
}

function Invoke-WingetCheckUpdates {
    Clear-Host
    Write-Section "CHECK APP UPDATES"
    Write-Step "Querying Winget for outdated packages..."
    winget upgrade
    Pause-Menu
}

function Invoke-WingetUpgradeAll {
    Clear-Host
    Write-Section "UPGRADE ALL INSTALLED PACKAGES"
    Write-Warn "This will scan and update all available winget packages."
    Write-Host ""
    $confirm = (Read-Host "  Proceed with bulk upgrade? [Y/N]").Trim().ToUpper()
    if ($confirm -eq "Y") {
        Write-Step "Upgrading all outdated applications..."
        winget upgrade --all --include-unknown --accept-source-agreements --accept-package-agreements
        Write-Success "Upgrade process finished."
        Write-NFSLog "Completed winget upgrade --all" -Target "app"
    } else {
        Write-Info "Bulk upgrade cancelled."
    }
    Pause-Menu
}

function Invoke-WingetUninstallPrompt {
    Clear-Host
    Write-Section "UNINSTALL APPLICATION"
    $pkg = Read-Host "  Enter Package ID or Exact App Name to remove"
    if ([string]::IsNullOrWhiteSpace($pkg)) { return }

    Write-Warn "You are about to uninstall '$pkg'."
    $confirm = (Read-Host "  Are you sure? [Y/N]").Trim().ToUpper()
    if ($confirm -eq "Y") {
        Write-Step "Uninstalling $pkg..."
        winget uninstall --id $pkg -e
        Write-Success "Uninstall command completed."
        Write-NFSLog "Uninstalled package $pkg via winget" -Level "WARN"
    } else {
        Write-Info "Uninstall cancelled."
    }
    Pause-Menu
}

function Invoke-WingetExport {
    Clear-Host
    Write-Section "EXPORT INSTALLED PACKAGES"
    $defaultFile = Join-Path ([Environment]::GetFolderPath("Desktop")) "winget-packages.json"
    $outPath = Read-Host "  Enter export path [Default: $defaultFile]"
    if ([string]::IsNullOrWhiteSpace($outPath)) { $outPath = $defaultFile }

    Write-Step "Exporting package manifest to $outPath..."
    winget export -o $outPath --accept-source-agreements
    if (Test-Path $outPath) {
        Write-Success "Package manifest exported to: $outPath"
    } else {
        Write-Err "Export failed."
    }
    Pause-Menu
}

function Invoke-WingetImport {
    Clear-Host
    Write-Section "IMPORT PACKAGES MANIFEST"
    $inPath = Read-Host "  Enter path to packages.json file"
    if ([string]::IsNullOrWhiteSpace($inPath) -or -not (Test-Path $inPath)) {
        Write-Err "File not found: $inPath"
        Pause-Menu
        return
    }

    Write-Warn "This will batch-install packages listed in $inPath."
    $confirm = (Read-Host "  Proceed with import? [Y/N]").Trim().ToUpper()
    if ($confirm -eq "Y") {
        Write-Step "Importing and installing packages..."
        winget import -i $inPath --accept-source-agreements --accept-package-agreements
        Write-Success "Import command completed."
    } else {
        Write-Info "Import cancelled."
    }
    Pause-Menu
}
