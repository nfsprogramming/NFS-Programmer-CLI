# ============================================================
#  NFS CLI - gamesetup.ps1
#  Game environment & launcher setup
# ============================================================
. "$PSScriptRoot\helpers.ps1"

function Show-GameSetupMenu {
    while ($true) {
        Clear-Host
        Write-Section "GAME SETUP"
        Write-Host ""
        Write-Host "  -- Essential Runtimes ----------------------------------" -ForegroundColor DarkYellow
        Write-Host "   1.  DirectX (Runtime)       2.  VC++ Redist (All)"      -ForegroundColor Cyan
        Write-Host "   3.  .NET Framework          4.  XNA Framework 4.0"      -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  -- Game Launchers --------------------------------------" -ForegroundColor DarkYellow
        Write-Host "   5.  Steam                   6.  Xbox App (Game Pass)"    -ForegroundColor Cyan
        Write-Host "   7.  Epic Games              8.  GOG Galaxy"              -ForegroundColor Cyan
        Write-Host "   9.  Battle.net              10. Playnite (Library)"      -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  -- Performance & Tools ---------------------------------" -ForegroundColor DarkYellow
        Write-Host "  11.  MSI Afterburner         12. RivaTuner (RTSS)"        -ForegroundColor Cyan
        Write-Host "  13.  HWiNFO Monitoring       14. CrystalDiskMark"         -ForegroundColor Cyan
        Write-Host ""
        Write-Host "   B.  Back"                        -ForegroundColor DarkGray
        Write-Host ""
        $choice = (Read-Host "  Select").Trim().ToUpper()

        switch ($choice) {
            "1"  { Invoke-InstallDirectX }
            "2"  { Invoke-InstallVCRedist }
            "3"  { Invoke-InstallDotNet }
            "4"  { Invoke-InstallXNA }
            "5"  { Install-WingetApp "Steam"                 "Valve.Steam" }
            "6"  { Install-WingetApp "Xbox App"              "Microsoft.GamingApp" }
            "7"  { Install-WingetApp "Epic Games"            "EpicGames.EpicGamesLauncher" }
            "8"  { Install-WingetApp "GOG Galaxy"            "GOG.Galaxy" }
            "9"  { Install-WingetApp "Battle.net"            "Blizzard.BattleNet" }
            "10" { Install-WingetApp "Playnite"              "Playnite.Playnite" }
            "11" { Install-WingetApp "MSI Afterburner"       "Guru3D.Afterburner" }
            "12" { Install-WingetApp "RivaTuner"             "Guru3D.RTSS" }
            "13" { Install-WingetApp "HWiNFO"                "REALiX.HWiNFO" }
            "14" { Install-WingetApp "CrystalDiskMark"       "CrystalDewWorld.CrystalDiskMark" }
            "B"  { return }
            default { Write-Warn "Invalid option."; Start-Sleep 1 }
        }
        Pause-Menu
    }
}

function Invoke-InstallDirectX {
    Write-Section "DIRECTX END-USER RUNTIME"
    Write-Info "Downloading DirectX installer..."
    $dxPath = "$env:TEMP\dxwebsetup.exe"
    Invoke-WebRequest "https://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe" -OutFile $dxPath
    Write-Step "Running installer (requires manual clicks)..."
    Start-Process $dxPath -Wait
    Write-Success "DirectX setup finished."
}

function Invoke-InstallVCRedist {
    Write-Section "VC++ REDISTRIBUTABLES"
    Write-Step "Installing all-in-one VC++ Redists via winget..."
    Install-WingetApp "VC++ 2005-2022" "Microsoft.VCRedist.2015+.x64"
    Write-Success "Visual C++ runtimes installed."
}

function Invoke-InstallDotNet {
    Write-Section ".NET FRAMEWORK"
    Write-Step "Enabling .NET Framework 3.5 via DISM..."
    dism /online /enable-feature /featurename:NetFx3 /all /norestart
    Write-Step "Installing .NET 6, 7, 8 Runtimes..."
    Install-WingetApp ".NET 6" "Microsoft.DotNet.Runtime.6"
    Install-WingetApp ".NET 8" "Microsoft.DotNet.Runtime.8"
    Write-Success ".NET Frameworks setup complete."
}

function Invoke-InstallXNA {
    Write-Section "XNA FRAMEWORK 4.0"
    Write-Info "Downloading XNA Framework 4.0..."
    $xnaPath = "$env:TEMP\xnafx40_redist.msi"
    Invoke-WebRequest "https://download.microsoft.com/download/A/C/2/AC2C903B-6368-46F6-AD16-47FBA0FD36D9/xnafx40_redist.msi" -OutFile $xnaPath
    Write-Step "Installing XNA Framework..."
    Start-Process msiexec.exe -ArgumentList "/i `"$xnaPath`" /quiet /norestart" -Wait
    Write-Success "XNA Framework 4.0 installed."
}

