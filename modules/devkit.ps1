# ============================================================
#  NFS CLI - devkit.ps1
#  Developer environment setup
# ============================================================
. "$PSScriptRoot\helpers.ps1"

function Show-DevKitMenu {
    while ($true) {
        Clear-Host
        Write-Section "DEV KIT"
        Write-Host ""
        Write-Host "  +-----------------------------------------------------+" -ForegroundColor DarkBlue
        Write-Host "  |  AI-POWERED EDITORS                                 |" -ForegroundColor Blue
        Write-Host "  |  1.  Antigravity (The Future)                       |" -ForegroundColor Red
        Write-Host "  |  2.  Windsurf (Codeium)                             |" -ForegroundColor Cyan
        Write-Host "  |  3.  Trae (ByteDance)                               |" -ForegroundColor Cyan
        Write-Host "  |  4.  Codex / OpenAI                                 |" -ForegroundColor Cyan
        Write-Host "  |  5.  Cursor                                         |" -ForegroundColor Cyan
        Write-Host "  |  6.  OpenCode                                       |" -ForegroundColor Cyan
        Write-Host "  |  7.  Blackbox AI                                    |" -ForegroundColor Cyan
        Write-Host "  |                                                     |" -ForegroundColor DarkBlue
        Write-Host "  |  LANGUAGES & RUNTIMES                               |" -ForegroundColor Blue
        Write-Host "  |  8.  Python 3.12                                    |" -ForegroundColor Cyan
        Write-Host "  |  9.  Node.js LTS                                    |" -ForegroundColor Cyan
        Write-Host "  |  10. Java 21 (Temurin JDK)                         |" -ForegroundColor Cyan
        Write-Host "  |  11. Go (Golang)                                    |" -ForegroundColor Cyan
        Write-Host "  |  12. Rust (rustup)                                  |" -ForegroundColor Cyan
        Write-Host "  |                                                     |" -ForegroundColor DarkBlue
        Write-Host "  |  EDITORS & IDEs                                     |" -ForegroundColor Blue
        Write-Host "  |  13. Visual Studio Code                             |" -ForegroundColor Cyan
        Write-Host "  |  14. Android Studio                                 |" -ForegroundColor Cyan
        Write-Host "  |  15. JetBrains Toolbox                              |" -ForegroundColor Cyan
        Write-Host "  |                                                     |" -ForegroundColor DarkBlue
        Write-Host "  |  SOURCE CONTROL & MOBILE                            |" -ForegroundColor Blue
        Write-Host "  |  16. Git for Windows                                |" -ForegroundColor Cyan
        Write-Host "  |  17. Flutter SDK                                    |" -ForegroundColor Cyan
        Write-Host "  |                                                     |" -ForegroundColor DarkBlue
        Write-Host "  |  DATABASE & CONTAINERS                              |" -ForegroundColor Blue
        Write-Host "  |  18. Docker Desktop                                 |" -ForegroundColor Cyan
        Write-Host "  |  19. Postman (API Testing)                          |" -ForegroundColor Cyan
        Write-Host "  |  20. DBeaver (Database Tool)                        |" -ForegroundColor Cyan
        Write-Host "  |  21. PowerShell 7 (Core)                            |" -ForegroundColor Cyan
        Write-Host "  |  22. Windows Terminal (Supreme)                     |" -ForegroundColor Red
        Write-Host "  |  23. GitHub Desktop                                 |" -ForegroundColor Cyan
        Write-Host "  |  24. Insomnia (API Client)                          |" -ForegroundColor Cyan
        Write-Host "  |  25. TablePlus (DB Tool)                            |" -ForegroundColor Cyan
        Write-Host "  |                                                     |" -ForegroundColor DarkBlue
        Write-Host "  |  B.  Back                                           |" -ForegroundColor DarkGray
        Write-Host "  +-----------------------------------------------------+" -ForegroundColor DarkBlue
        Write-Host ""
        $choice = (Read-Host "  Select").Trim().ToUpper()

        switch ($choice) {
            "1"  { Open-Url "https://antigravity.ai"         "Antigravity AI" }
            "2"  { Install-WingetApp "Windsurf"              "Codeium.Windsurf" }
            "3"  { Install-WingetApp "Trae"                  "ByteDance.Trae" }
            "4"  { Open-Url "https://openai.com/blog/openai-codex" "OpenAI Codex" }
            "5"  { Install-WingetApp "Cursor"                "Anysphere.Cursor" }
            "6"  { Open-Url "https://opencode.io"            "OpenCode" }
            "7"  { Open-Url "https://www.blackbox.ai"        "Blackbox AI" }
            "8"  { Install-WingetApp "Python 3.12"           "Python.Python.3.12" }
            "9"  { Install-WingetApp "Node.js LTS"           "OpenJS.NodeJS.LTS" }
            "10" { Install-WingetApp "Eclipse Temurin 21"    "EclipseAdoptium.Temurin.21.JDK" }
            "11" { Install-WingetApp "Go"                    "GoLang.Go" }
            "12" { Invoke-InstallRust }
            "13" { Install-WingetApp "VS Code"               "Microsoft.VisualStudioCode" }
            "14" { Install-WingetApp "Android Studio"        "Google.AndroidStudio" }
            "15" { Install-WingetApp "JetBrains Toolbox"     "JetBrains.Toolbox" }
            "16" { Install-WingetApp "Git"                   "Git.Git" }
            "17" { Install-WingetApp "Flutter SDK"           "Google.FlutterSDK" }
            "18" { Install-WingetApp "Docker Desktop"        "Docker.DockerDesktop" }
            "19" { Install-WingetApp "Postman"               "Postman.Postman" }
            "20" { Install-WingetApp "DBeaver"               "dbeaver.dbeaver" }
            "21" { Install-WingetApp "PowerShell 7"          "Microsoft.PowerShell" }
            "22" { Install-WingetApp "Windows Terminal"      "Microsoft.WindowsTerminal" }
            "23" { Install-WingetApp "GitHub Desktop"        "GitHub.GitHubDesktop" }
            "24" { Install-WingetApp "Insomnia"              "Kong.Insomnia" }
            "25" { Install-WingetApp "TablePlus"             "TablePlus.TablePlus" }
            "B"  { return }
            default { Write-Warn "Invalid option."; Start-Sleep 1; continue }
        }
        Pause-Menu
    }
}

function Invoke-InstallRust {
    Write-Section "RUST (RUSTUP)"
    Write-Info "Downloading rustup installer..."
    $rustupPath = "$env:TEMP\rustup-init.exe"
    Invoke-WebRequest "https://win.rustup.rs/x86_64" -OutFile $rustupPath
    Write-Step "Running rustup installer..."
    Start-Process $rustupPath -ArgumentList "-y" -Wait
    Write-Success "Rust installed. Restart your terminal to use 'cargo'."
}

