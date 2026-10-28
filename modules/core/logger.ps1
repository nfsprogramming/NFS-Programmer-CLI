# ============================================================
#  NFS CLI V2 - logger.ps1
#  Multi-channel structured logging engine
# ============================================================

$script:NFS_LOG_DIR = $null

function Initialize-NFSLogger {
    param([string]$RootDir)
    if (-not $RootDir) {
        $RootDir = if ($script:NFS_ROOT) { $script:NFS_ROOT } else { (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) }
    }
    $script:NFS_LOG_DIR = Join-Path $RootDir "logs"
    if (-not (Test-Path $script:NFS_LOG_DIR)) {
        New-Item -Path $script:NFS_LOG_DIR -ItemType Directory -Force | Out-Null
    }
}

function Write-NFSLog {
    param(
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR", "DEBUG", "DIAG")]
        [string]$Level = "INFO",
        [ValidateSet("app", "update", "diagnostics")]
        [string]$Target = "app"
    )

    # Check if logging is enabled in config
    if ($script:NFS_CONFIG -and $script:NFS_CONFIG.logging -eq $false) {
        return
    }

    if (-not $script:NFS_LOG_DIR -or -not (Test-Path $script:NFS_LOG_DIR)) {
        Initialize-NFSLogger
    }

    $fileName = switch ($Target) {
        "update"      { "update.log" }
        "diagnostics" { "diagnostics.log" }
        default       { "nfs-cli.log" }
    }
    $logFile = Join-Path $script:NFS_LOG_DIR $fileName

    # Sanitize message (remove sensitive patterns like passwords/tokens)
    $cleanMessage = $Message -replace "(?i)(password|token|secret|apikey)\s*[:=]\s*([^\s,;]+)", '$1=******'

    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss.fff")
    $logLine = "[$timestamp] [$Level] $cleanMessage"

    try {
        [System.IO.File]::AppendAllText($logFile, "$logLine`r`n", [System.Text.Encoding]::UTF8)
    } catch {
        # Fallback without crashing
    }
}

function Get-NFSLogLines {
    param(
        [ValidateSet("app", "update", "diagnostics")]
        [string]$Target = "app",
        [int]$Tail = 50
    )
    if (-not $script:NFS_LOG_DIR) { Initialize-NFSLogger }
    $fileName = switch ($Target) {
        "update"      { "update.log" }
        "diagnostics" { "diagnostics.log" }
        default       { "nfs-cli.log" }
    }
    $logFile = Join-Path $script:NFS_LOG_DIR $fileName
    if (Test-Path $logFile) {
        return Get-Content $logFile -Tail $Tail -ErrorAction SilentlyContinue
    }
    return @()
}
