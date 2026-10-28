# ============================================================
#  NFS CLI - tools.ps1
#  Common productivity & utility app installer
# ============================================================
. "$PSScriptRoot\helpers.ps1"

function Show-ToolsMenu {
    while ($true) {
        Clear-Host
        Write-Section "TOOLS"
        $config = Get-Config "apps.json"
        if (-not $config) { Pause-Menu; return }

        Write-Host "  1. MINIMAL SETUP (Auto-Install Selection)" -ForegroundColor Green
        Write-Host "  2. BROWSERS" -ForegroundColor Cyan
        Write-Host "  3. COMMUNICATION" -ForegroundColor Cyan
        Write-Host "  4. MEDIA" -ForegroundColor Cyan
        Write-Host "  5. CREATIVE SUITE" -ForegroundColor Cyan
        Write-Host "  6. CLOUD STORAGE" -ForegroundColor Cyan
        Write-Host "  7. UTILITIES" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  B. Back" -ForegroundColor DarkGray
        Write-Host ""

        $choice = (Read-Host "  Select").Trim().ToUpper()
        if ($choice -eq "B") { return }

        switch ($choice) {
            "1" { Show-AppSubMenu "Minimal Setup" $config.recommended ; continue }
            "2" { Show-AppSubMenu "Browsers"      $config.browsers    ; continue }
            "3" { Show-AppSubMenu "Communication" $config.communication ; continue }
            "4" { Show-AppSubMenu "Media"         $config.media       ; continue }
            "5" { Show-AppSubMenu "Creative"      $config.creative    ; continue }
            "6" { Show-AppSubMenu "Cloud"         $config.cloud       ; continue }
            "7" { Show-AppSubMenu "Utilities"     $config.utilities   ; continue }
            default { Write-Warn "Invalid option."; Start-Sleep 1 }
        }
    }
}

function Show-AppSubMenu {
    param($Title, $AppList)
    while ($true) {
        Clear-Host
        Write-Section "$($Title.ToUpper())"
        $i = 1
        foreach ($app in $AppList) {
            Write-Host ("  {0,2}. {1}" -f $i, $app.name) -ForegroundColor Cyan
            $i++
        }
        Write-Host ""
        if ($Title -eq "Minimal Setup") {
            Write-Host ("  {0,2}. INSTALL ALL (Minimal Bundle)" -f $i) -ForegroundColor Green
            $allIdx = $i
        } else {
            $allIdx = -1
        }
        Write-Host ""
        Write-Host "  B. Back" -ForegroundColor DarkGray
        Write-Host ""

        $choice = (Read-Host "  Select #").Trim().ToUpper()
        if ($choice -eq "B") { return }

        if ($choice -match "^\d+$") {
            $num = [int]$choice
            if ($num -eq $allIdx) {
                foreach ($a in $AppList) { 
                    if ($a.id) { Install-WingetApp $a.name $a.id }
                    else { Write-Info "Skipping $($a.name) (Direct Link Only)" }
                }
                Pause-Menu
                return
            } elseif ($num -ge 1 -and $num -le $AppList.Count) {
                $app = $AppList[$num - 1]
                if ($app.id -eq "Tonec.InternetDownloadManager") {
                    Invoke-IDMFullInstall
                } elseif ($app.url) {
                    Open-Url $app.url $app.name
                } else {
                    Install-WingetApp $app.name $app.id
                }
                Pause-Menu
            } else {
                Write-Warn "Invalid option." ; Start-Sleep 1
            }
        }
    }
}

function Invoke-IDMFullInstall {
    Write-Section "IDM FULL INSTALLATION"
    
    # 1. Install IDM Online
    Write-Step "Step 1: Installing IDM from official source..."
    Install-WingetApp "Internet Download Manager" "Tonec.InternetDownloadManager"
    
    # 2. User Acknowledgement
    Write-HR
    Write-Warn "CRITICAL: The next step requires turning off Windows Real-time Protection"
    Write-Warn "to apply the IDM crack/patch from your 'my apps' folder."
    Write-Host ""
    $confirm = Read-Host "  Do you acknowledge and want to proceed? (Y/N)"
    if ($confirm.ToUpper() -ne "Y") {
        Write-Info "Custom install aborted by user."
        return
    }

    # 3. Disable Security
    if (Assert-Admin) {
        Write-Step "Step 2: Disabling Windows Real-time Monitoring..."
        Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
        Write-Success "Protection temporarily disabled."
    } else {
        Write-Err "Admin rights required to disable security. Skipping crack step."
        return
    }

    # 4. Install Crack
    Write-Step "Step 3: Applying IDM Crack..."
    $crackPath = Join-Path $script:NFS_ROOT "my apps\IDM_6.4x_Crack_v20.6.exe"
    if (Test-Path $crackPath) {
        Write-Info "Running: $(Split-Path $crackPath -Leaf)"
        Start-Process $crackPath -Wait
        Write-Success "Crack application attempt finished."
    } else {
        Write-Err "Crack file not found at: $crackPath"
    }

    # 5. Re-enable Security
    Write-Step "Step 4: Re-enabling Windows Real-time Monitoring..."
    Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction SilentlyContinue
    Write-Success "System security restored."
    Write-HR
    Write-Success "IDM Full Installation flow complete."
}

