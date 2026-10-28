# ============================================================
#  NFS CLI - isos.ps1
#  Official OS ISO download links
# ============================================================
. "$PSScriptRoot\helpers.ps1"

function Show-ISOsMenu {
    while ($true) {
        Clear-Host
        Write-Section "ISO HUB"
        $config = Get-Config "isos.json"
        if (-not $config) { Pause-Menu; return }

        Write-Host ""
        $i = 1
        foreach ($iso in $config.isos) {
            Write-Host ("  {0,2}. {1}" -f $i, $iso.name) -ForegroundColor Cyan
            Write-Host ("      {0}" -f $iso.notes) -ForegroundColor DarkGray
            $i++
        }
        Write-Host ""
        Write-Host ("  {0,2}. Open All ISO Pages" -f $i)  -ForegroundColor Yellow
        $allIdx = $i ; $i++
        Write-Host ""
        Write-Host "   B.  Back" -ForegroundColor DarkGray
        Write-Host ""
        $choice = (Read-Host "  Select").Trim().ToUpper()
        if ($choice -eq "B") { return }

        if ($choice -match "^\d+$") {
            $num = [int]$choice
            if ($num -eq $allIdx) {
                foreach ($iso in $config.isos) { Open-Url $iso.url $iso.name }
                Write-Success "All ISO pages opened in your browser."
                Pause-Menu
            } elseif ($num -ge 1 -and $num -le $config.isos.Count) {
                $iso = $config.isos[$num - 1]
                Open-Url $iso.url $iso.name
                Write-Info "$($iso.notes)"
                Pause-Menu
            } else {
                Write-Warn "Invalid option." ; Start-Sleep 1
            }
        } else {
            Write-Warn "Invalid option." ; Start-Sleep 1
        }
    }
}

