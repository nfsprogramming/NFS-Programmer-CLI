# ============================================================
#  NFS CLI - about.ps1
#  About screen & version info
# ============================================================
. "$PSScriptRoot\helpers.ps1"

function Show-About {
    Clear-Host
    Write-Host ""
    Write-Host "  +-------------------------------------------------------+" -ForegroundColor Red
    Write-Host "  |           NFS PROGRAMMER CLI  -  v1.0                |" -ForegroundColor Red
    Write-Host "  |           Built by  NIFRAS                           |" -ForegroundColor Red
    Write-Host "  +-------------------------------------------------------+" -ForegroundColor Red
    Write-Host ""
    Write-Host "  A modular Windows toolkit for power users.             " -ForegroundColor Gray
    Write-Host ""
    Write-HR "="
    Write-Host ""
    Write-Host "  MODULES" -ForegroundColor Yellow
    Write-Host "  -----------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "  Scripts    ->  Activation (MAS), Spicetify, Fixes"        -ForegroundColor White
    Write-Host "  Tools      ->  Minimal Setup (Chrome, Office, etc.)"      -ForegroundColor White
    Write-Host "  Dev Kit    ->  AI Editors (Cursor, Trae) + Languages"     -ForegroundColor White
    Write-Host "  Drivers    ->  Auto-detect brand + GPU install"           -ForegroundColor White
    Write-Host "  Custom Apps->  Pro User collection (Rainmeter, Notion)"   -ForegroundColor White
    Write-Host "  Game Setup ->  Essential runtimes (DirectX) + Launchers"  -ForegroundColor White
    Write-Host "  ISOs       ->  OS Downloads & Tools (Rufus, Ventoy)"      -ForegroundColor White
    Write-Host "  My Webs    ->  Quick-launch dev profiles"                 -ForegroundColor White
    Write-Host "  Optimizer  ->  Performance tweaks & Personalization"      -ForegroundColor Green
    Write-Host ""
    Write-HR "="
    Write-Host ""
    Write-Host "  SYSTEM OVERVIEW" -ForegroundColor Yellow
    Write-Host "  -----------------------------------------------------" -ForegroundColor DarkGray
    try {
        $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
        $mem = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum
        $gpu = Get-CimInstance Win32_VideoController | Select-Object -First 1
        Write-Host "  CPU : $($cpu.Name)" -ForegroundColor White
        Write-Host "  RAM : $([Math]::Round($mem.Sum / 1GB, 0)) GB" -ForegroundColor White
        Write-Host "  GPU : $($gpu.Name)" -ForegroundColor White
    } catch {
        Write-Host "  System info retrieval failed." -ForegroundColor DarkRed
    }
    Write-Host ""
    Write-HR "="
    Write-Host ""
    Write-Host "  CONTACT & LINKS" -ForegroundColor Yellow
    Write-Host "  -----------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "  GitHub     : https://github.com/nfsprogramming" -ForegroundColor Cyan
    Write-Host "  Instagram  : https://instagram.com/_.nfsphotography._" -ForegroundColor Cyan
    Write-Host "  LinkedIn   : https://linkedin.com/in/nfs-programming" -ForegroundColor Cyan
    Write-Host "  WhatsApp   : https://wa.me/8925147213" -ForegroundColor Cyan
    Write-Host ""
    Write-HR "="
    Write-Host ""
    Pause-Menu
}
