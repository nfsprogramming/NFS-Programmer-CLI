# ============================================================
#  NFS CLI - androidtools.ps1
#  Android & Termux Ethical Hacking Tools
# ============================================================
. "$PSScriptRoot\helpers.ps1"

function Show-AndroidToolsMenu {
    while ($true) {
        Clear-Host
        Write-Section "ANDROID & TERMUX TOOLS"
        Write-Host ""
        Write-Host "  -- Essential Hacking Tools (Termux) -------------------" -ForegroundColor DarkYellow
        Write-Host "   1.  Nmap (Network Scanner)      2.  Metasploit Framework" -ForegroundColor Cyan
        Write-Host "   3.  Sqlmap (SQL Injection)      4.  Zphisher (Phishing)" -ForegroundColor Cyan
        Write-Host "   5.  WebSift (OSINT Scraper)     6.  ZeroTrace (Anonymity)" -ForegroundColor Cyan
        Write-Host "   7.  ADB-Toolkit (Android Debug) 8.  TBomb (Call/SMS Bomber)" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  -- Setup Commands (Copy to Termux) --------------------" -ForegroundColor DarkYellow
        Write-Host "   9.  Initial Setup (Update/Git/Python)" -ForegroundColor White
        Write-Host ""
        Write-Host "  B.  Back" -ForegroundColor DarkGray
        Write-Host ""
        
        $choice = (Read-Host "  Select").Trim().ToUpper()

        if ($choice -eq "B") { return }

        switch ($choice) {
            "1" { Show-ToolInfo "Nmap" "Network discovery and security auditing tool." "pkg install nmap" "https://github.com/nmap/nmap" }
            "2" { Show-ToolInfo "Metasploit" "Exploitation framework for vulnerabilities." "pkg install unstable-repo && pkg install metasploit" "https://github.com/rapid7/metasploit-framework" }
            "3" { Show-ToolInfo "Sqlmap" "Automatic SQL injection and database takeover tool." "git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git sqlmap-dev" "https://github.com/sqlmapproject/sqlmap" }
            "4" { Show-ToolInfo "Zphisher" "Advanced phishing tool for Termux." "git clone https://github.com/htr-tech/zphisher" "https://github.com/htr-tech/zphisher" }
            "5" { Show-ToolInfo "WebSift" "OSINT tool for scraping emails and social links." "git clone https://github.com/s-r-e-e-r-a-j/WebSift" "https://github.com/s-r-e-e-r-a-j/WebSift" }
            "6" { Show-ToolInfo "ZeroTrace" "Route traffic through Tor for anonymity." "git clone https://github.com/s-r-e-e-r-a-j/ZeroTrace" "https://github.com/s-r-e-e-r-a-j/ZeroTrace" }
            "7" { Show-ToolInfo "ADB-Toolkit" "Powerful toolkit for ADB penetration testing." "git clone https://github.com/ASHWIN990/ADB-Toolkit" "https://github.com/ASHWIN990/ADB-Toolkit" }
            "8" { Show-ToolInfo "TBomb (Call Bomber)" "Open-source SMS/Call bomber for Termux." "git clone https://github.com/TheSpeedX/TBomb.git" "https://github.com/TheSpeedX/TBomb" }
            "9" { Show-ToolInfo "Initial Setup" "Standard update and dependency installation." "pkg update && pkg upgrade -y && pkg install git python curl wget php -y" "" }
            default { Write-Warn "Invalid option." ; Start-Sleep 1 }
        }
    }
}

function Show-ToolInfo {
    param($Name, $Desc, $Command, $Url)
    Clear-Host
    Write-Section "$Name"
    Write-Host ""
    Write-Host "  Description: " -NoNewline -ForegroundColor White
    Write-Host $Desc -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Install Command (Termux):" -ForegroundColor White
    Write-Host "  $Command" -ForegroundColor Green
    Write-Host ""
    if ($Url) {
        Write-Host "  GitHub Repository:" -ForegroundColor White
        Write-Host "  $Url" -ForegroundColor Blue
        Write-Host ""
    }
    
    Write-Host "  [C] Copy command to clipboard" -ForegroundColor Yellow
    if ($Url) { Write-Host "  [O] Open GitHub in browser" -ForegroundColor Yellow }
    Write-Host "  [B] Back" -ForegroundColor DarkGray
    Write-Host ""
    
    $subChoice = (Read-Host "  Select").Trim().ToUpper()
    if ($subChoice -eq "C") {
        Set-Clipboard -Value $Command
        Write-Success "Command copied to clipboard!"
        Start-Sleep 1
    } elseif ($subChoice -eq "O" -and $Url) {
        Open-Url $Url $Name
    }
}
