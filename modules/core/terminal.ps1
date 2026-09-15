# ============================================================
#  NFS CLI V2 - terminal.ps1
#  Terminal detection, ANSI formatting & startup sequence
# ============================================================

. "$PSScriptRoot\cinematic.ps1"

$script:ANSI_SUPPORTED = $false

function Initialize-Terminal {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

    # Detect VT/ANSI support safely
    try {
        if ($PSStyle -and $PSStyle.OutputRendering -ne "PlainText") {
            $script:ANSI_SUPPORTED = $true
        } elseif ($Host.UI.SupportsVirtualTerminal) {
            $script:ANSI_SUPPORTED = $true
        } else {
            $ver = [System.Environment]::OSVersion.Version
            if ($ver.Major -ge 10) {
                $script:ANSI_SUPPORTED = $true
            }
        }
    } catch {
        $script:ANSI_SUPPORTED = $false
    }
}

function Test-AnsiSupport {
    return $script:ANSI_SUPPORTED
}

function Show-NFSStartup {
    param(
        [object]$Config,
        [object]$VersionInfo,
        [switch]$Fast,
        [switch]$NoIntro
    )

    Initialize-Terminal

    # Execute the Extreme Cinematic Terminal Intro
    Invoke-CinematicIntro -Config $Config -VersionInfo $VersionInfo -Fast:$Fast -NoIntro:$NoIntro
}
