# ============================================================
#  NFS CLI - mywebs.ps1
#  Quick-launch personal and dev websites
# ============================================================
. "$PSScriptRoot\helpers.ps1"

function Show-MyWebsMenu {
    while ($true) {
        Clear-Host
        Write-Section "MY WEBS"
        $config = Get-Config "mywebs.json"
        if (-not $config) { Pause-Menu; return }

        $categories = @(
            @{ Key="websites"; Label="My Profiles"      },
            @{ Key="tools";    Label="AI Tools"         },
            @{ Key="dev";      Label="Dev Resources"    },
            @{ Key="downloads";Label="Downloads"        }
        )

        $index = 1
        $allSites = @()
        foreach ($cat in $categories) {
            Write-Host ""
            Write-Host "  -- $($cat.Label) ------------------------------------" -ForegroundColor DarkYellow
            foreach ($site in $config.($cat.Key)) {
                Write-Host ("  {0,2}. {1}" -f $index, $site.name) -ForegroundColor Cyan
                Write-Host ("      {0}" -f $site.url) -ForegroundColor DarkGray
                $allSites += $site
                $index++
            }
        }

        Write-Host ""
        Write-Host ("  {0,2}. Open ALL sites" -f $index) -ForegroundColor Yellow
        $allIdx = $index
        Write-Host ""
        Write-Host "   B.  Back" -ForegroundColor DarkGray
        Write-Host ""

        $choice = (Read-Host "  Select").Trim().ToUpper()
        if ($choice -eq "B") { return }

        if ($choice -match "^\d+$") {
            $num = [int]$choice
            if ($num -eq $allIdx) {
                foreach ($s in $allSites) { Open-Url $s.url $s.name }
                Write-Success "All sites launched!"
                Pause-Menu
            } elseif ($num -ge 1 -and $num -le $allSites.Count) {
                $site = $allSites[$num - 1]
                Open-Url $site.url $site.name
                Pause-Menu
            } else {
                Write-Warn "Invalid option." ; Start-Sleep 1
            }
        } else {
            Write-Warn "Invalid option." ; Start-Sleep 1
        }
    }
}

