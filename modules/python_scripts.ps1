# ============================================================
#  NFS CLI - python_scripts.ps1
#  Python Automation Scripts & Tools
# ============================================================

function Show-PythonScriptsMenu {
    while ($true) {
        Clear-Host
        Write-Section "PYTHON SCRIPTS"
        Write-Host ""
        Write-Host "  +-----------------------------------------------------+" -ForegroundColor DarkMagenta
        Write-Host "  |  1.  Universal File Organizer                       |" -ForegroundColor Magenta
        Write-Host "  |  2.  Bulk Image Resizer & Converter                 |" -ForegroundColor Magenta
        Write-Host "  |  3.  YouTube Video & Audio Downloader               |" -ForegroundColor Magenta
        Write-Host "  |  B.  Back                                           |" -ForegroundColor DarkGray
        Write-Host "  +-----------------------------------------------------+" -ForegroundColor DarkMagenta
        Write-Host ""
        $choice = (Read-Host "  Select").Trim().ToUpper()

        switch ($choice) {
            "1"  { Invoke-PyFileOrganizer }
            "2"  { Invoke-PyImageResizer }
            "3"  { Invoke-PyYTDownloader }
            "B"  { return }
            default { Write-Warn "Invalid option." ; Start-Sleep 1 }
        }
    }
}

function Invoke-PyFileOrganizer {
    Write-Section "UNIVERSAL FILE ORGANIZER"
    $scriptPath = Join-Path $NFS_ROOT "python_scripts\organizer.py"
    if (Test-Path $scriptPath) {
        Write-Info "Launching Python script..."
        python $scriptPath
    } else {
        Write-Warn "Script not found at: $scriptPath"
    }
    Pause-Menu
}

function Invoke-PyImageResizer {
    Write-Section "BULK IMAGE RESIZER"
    $scriptPath = Join-Path $NFS_ROOT "python_scripts\image_resizer.py"
    if (Test-Path $scriptPath) {
        Write-Info "Checking dependencies..."
        python -c "import PIL" 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Warn "Pillow library is missing. Installing it now..."
            pip install Pillow
        }
        Write-Info "Launching Python script..."
        python $scriptPath
    } else {
        Write-Warn "Script not found at: $scriptPath"
    }
    Pause-Menu
}

function Invoke-PyYTDownloader {
    Write-Section "YOUTUBE DOWNLOADER"
    $scriptPath = Join-Path $NFS_ROOT "python_scripts\yt_downloader.py"
    if (Test-Path $scriptPath) {
        Write-Info "Checking dependencies..."
        
        # Check and install yt-dlp
        python -c "import yt_dlp" 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Warn "yt-dlp library is missing. Installing it now..."
            pip install yt-dlp
        }
        
        # Check and install ffmpeg (required for audio extraction and merging high-quality video)
        if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
            Write-Warn "FFmpeg is missing! It's required for high-quality downloads."
            Write-Info "Installing FFmpeg via winget (this may take a minute)..."
            winget install --id=Gyan.FFmpeg -e --accept-source-agreements --accept-package-agreements
            
            # Note: The user might need to restart their terminal for the PATH variable to update.
            Write-Warn "If it still fails after this, please restart your CLI to apply the PATH changes."
        }
        
        Write-Info "Launching Python script..."
        python $scriptPath
    } else {
        Write-Warn "Script not found at: $scriptPath"
    }
    Pause-Menu
}
