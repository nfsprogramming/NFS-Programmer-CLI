# ============================================================
#  NFS CLI - customapps.ps1
#  Your personal hand-picked app collection
# ============================================================
. "$PSScriptRoot\helpers.ps1"

function Show-CustomAppsMenu {
    while ($true) {
        Clear-Host
        Write-Section "CUSTOM APPS & SUITES"
        Write-Host ""
        Write-Host "  -- Pro User Tools -------------------------------------" -ForegroundColor DarkYellow
        Write-Host "   1.  Windhawk (OS Modding)   2.  Spacedesk (Monitor)" -ForegroundColor Cyan
        Write-Host "   3.  Rainmeter (Desktop)     4.  Notion (Workspace)" -ForegroundColor Cyan
        Write-Host "   5.  Telegram Desktop        6.  Wise Uninstaller"   -ForegroundColor Cyan
        Write-Host "   7.  AnyDesk (Remote)        8.  CrystalDiskMark"    -ForegroundColor Cyan
        Write-Host "   9.  Photoshop (Official)    10. Mechvibes (Sound)"   -ForegroundColor Cyan
        Write-Host "   31. Microsoft PowerToys     32. WizTree (Fast Scan)" -ForegroundColor Red
        Write-Host "   33. HWInfo64 (Hardware)     34. Process Hacker"     -ForegroundColor Red
        Write-Host ""
        Write-Host "  -- Gaming & Social ------------------------------------" -ForegroundColor DarkYellow
        Write-Host "  11.  Discord                 12. Steam"              -ForegroundColor White
        Write-Host "  13.  Epic Games Launcher     14. WhatsApp"           -ForegroundColor White
        Write-Host "  15.  Spotify                 16. OBS Studio"         -ForegroundColor White
        Write-Host ""
        Write-Host "  -- Essential Utilities --------------------------------" -ForegroundColor DarkYellow
        Write-Host "  17.  VLC Media Player        18. 7-Zip"              -ForegroundColor Cyan
        Write-Host "  19.  qBittorrent             20. Everything Search"  -ForegroundColor Cyan
        Write-Host "  21.  ShareX (Screenshots)    22. Rufus (USB Tool)"   -ForegroundColor Cyan
        Write-Host "  23.  Handbrake (Video)       24. WinRAR"             -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  -- Productivity & Creative ----------------------------" -ForegroundColor DarkYellow
        Write-Host "  25.  Google Chrome           26. Obsidian"           -ForegroundColor White
        Write-Host "  27.  LocalSend               28. Bitwarden"          -ForegroundColor White
        Write-Host "  29.  Canva Desktop           30. Figma"              -ForegroundColor White
        Write-Host ""
        Write-Host "  B.  Back" -ForegroundColor DarkGray
        Write-Host ""
        $choice = (Read-Host "  Select").Trim().ToUpper()

        switch ($choice) {
            "1"  { Install-WingetApp "Windhawk"              "Windhawk.Windhawk" }
            "2"  { Install-WingetApp "Spacedesk"              "datavideo.spacedesk" }
            "3"  { Install-WingetApp "Rainmeter"             "Rainmeter.Rainmeter" }
            "4"  { Install-WingetApp "Notion"                "Notion.Notion" }
            "5"  { Install-WingetApp "Telegram"              "Telegram.TelegramDesktop" }
            "6"  { Install-WingetApp "Wise Uninstaller"      "Wise.WiseProgramUninstaller" }
            "7"  { Install-WingetApp "AnyDesk"               "AnyDeskSoftwareGmbH.AnyDesk" }
            "8"  { Install-WingetApp "CrystalDiskMark"       "CrystalDewWorld.CrystalDiskMark" }
            "9"  { Open-Url "https://www.adobe.com/products/photoshop.html" "Adobe Photoshop" }
            "10" { Install-WingetApp "Mechvibes"             "Mechvibes.Mechvibes" }
            "11" { Install-WingetApp "Discord"               "Discord.Discord" }
            "12" { Install-WingetApp "Steam"                 "Valve.Steam" }
            "13" { Install-WingetApp "Epic Games"           "EpicGames.EpicGamesLauncher" }
            "14" { Install-WingetApp "WhatsApp"              "WhatsApp.WhatsApp" }
            "15" { Install-WingetApp "Spotify"               "Spotify.Spotify" }
            "16" { Install-WingetApp "OBS Studio"            "OBSProject.OBSStudio" }
            "17" { Install-WingetApp "VLC Player"            "VideoLAN.VLC" }
            "18" { Install-WingetApp "7-Zip"                 "7zip.7zip" }
            "19" { Install-WingetApp "qBittorrent"            "qBittorrent.qBittorrent" }
            "20" { Install-WingetApp "Everything"             "voidtools.Everything" }
            "21" { Install-WingetApp "ShareX"                 "ShareX.ShareX" }
            "22" { Install-WingetApp "Rufus"                  "Rufus.Rufus" }
            "23" { Install-WingetApp "Handbrake"              "Handbrake.Handbrake" }
            "24" { Install-WingetApp "WinRAR"                 "RARLab.WinRAR" }
            "25" { Install-WingetApp "Google Chrome"         "Google.Chrome" }
            "26" { Install-WingetApp "Obsidian"               "Obsidian.Obsidian" }
            "27" { Install-WingetApp "LocalSend"              "LocalSend.LocalSend" }
            "28" { Install-WingetApp "Bitwarden"              "Bitwarden.Bitwarden" }
            "29" { Install-WingetApp "Canva"                 "Canva.Canva" }
            "30" { Install-WingetApp "Figma"                 "Figma.Figma" }
            "31" { Install-WingetApp "PowerToys"             "Microsoft.PowerToys" }
            "32" { Install-WingetApp "WizTree"               "AntibodySoftware.WizTree" }
            "33" { Install-WingetApp "HWInfo64"              "REALiX.HWiNFO" }
            "34" { Install-WingetApp "Process Hacker"        "SystemInformant.SystemInformer" }
            "B"  { return }
            default { Write-Warn "Invalid option." ; Start-Sleep 1 }
        }
        Pause-Menu
    }
}


