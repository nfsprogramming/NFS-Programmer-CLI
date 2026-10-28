# ⚡ NFS Programmer CLI (v2.0.0)

> **Windows Developer & System Engineering Toolkit**  
> A high-performance, modular PowerShell terminal environment engineered for power users, software developers, and system administrators.

```text
  ███╗   ██╗███████╗███████╗
  ████╗  ██║██╔════╝██╔════╝
  ██╔██╗ ██║█████╗  ███████╗
  ██║╚██╗██║██╔══╝  ╚════██║
  ██║ ╚████║██║     ███████║
  ╚═╝  ╚═══╝╚═╝     ╚══════╝
       P R O G R A M M I N G
        - B Y   N I F R A S -
```

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-0078D6.svg)](https://microsoft.com/windows)
[![Shell](https://img.shields.io/badge/Shell-PowerShell%205.1%20%7C%207%2B-5391FE.svg)](https://github.com/PowerShell/PowerShell)
[![Version](https://img.shields.io/badge/Version-2.0.0-success.svg)](assets/configs/version.json)

---

## 📑 Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
  - [Interactive Dashboard Mode](#interactive-dashboard-mode)
  - [CLI Command-Line Mode](#cli-command-line-mode)
- [Configuration](#configuration)
- [Project Structure](#project-structure)
- [Validation & Diagnostics](#validation--diagnostics)
- [Limitations & Security Considerations](#limitations--security-considerations)
- [Contributing](#contributing)
- [License](#license)
- [Author & Acknowledgements](#author--acknowledgements)

---

## Overview

**NFS Programmer CLI** is a keyboard-driven console operating environment built for Windows. It provides live hardware telemetry, deep operating system diagnostics, network troubleshooting, developer toolchain auditing, package management automation via Windows Package Manager (`winget`), and system maintenance tasks in a clean terminal user interface.

For an exhaustive guide covering every command, menu key, and diagnostic option, consult the [USER_MANUAL.md](USER_MANUAL.md).

---

## Key Features

### 🎛️ Terminal Welcome Dashboard
- **Live Hardware Telemetry**: Real-time readings of CPU load %, RAM used/total GB, System Disk % used, GPU model, and system Uptime.
- **One-Touch Quick Actions**: Single-key shortcuts to System Health (`[H]`), Network Doctor (`[N]`), Developer Environment (`[D]`), Cleanup (`[C]`), Winget Studio (`[W]`), and the Classic V1 Menu (`[L]`).
- **Non-Intrusive Update Banner**: Instant notifications for upstream version availability with offline-safe fallbacks.

### 🩺 Diagnostic Doctors
- **System Doctor (`nfs doctor`)**: Evaluates CPU health, Memory pressure, Storage SMART status, Windows build & pending reboot status, driver conflict codes, and essential background services (Spooler, W32Time, CryptSvc, BITS, wuauserv).
- **Network Doctor (`nfs doctor network`)**: Inspects active adapters, gateway reachability, IP configuration, DNS latency across major endpoints (Cloudflare, Google, AWS, GitHub), and safe network stack repairs (DNS flush, DHCP renew, Winsock/TCP reset).
- **Developer Doctor (`nfs doctor dev`)**: Inspects compilers and toolchains (Git, Python, Node.js, npm, Java/JDK, Go, Rust, Docker, VS Code, Flutter, Android SDK/adb, PowerShell 7, Windows Terminal) with automated installation assistance via `winget`.

### 📦 Package Management (Winget Studio)
- Direct integration with Windows Package Manager (`winget`):
  - Search packages across official Microsoft and community repositories.
  - Install, update, and manage developer tooling cleanly.
  - Execute bulk upgrades (`winget upgrade --all`).
  - Export and import package manifests for automated machine provisioning.

### 🏎️ Performance Center & Event Log Analyzer
- **Performance Center**: Live resource consumption tracking, top 15 CPU and memory-intensive processes, and startup application inspector with safe confirmation before terminating any process.
- **Event Log Analyzer**: Filters and summarizes Critical, Error, and Warning events across System, Application, and Driver event channels over the past 24 hours.

### 🛡️ Defensive Update & Rollback Engine
- Semantic version resolution against GitHub Releases (`nfsprogramming/nfs-cli`).
- Automatic pre-update backup creation before applying releases.
- One-command rollback (`nfs update --rollback`) to restore prior versions immediately.
- Offline-first resilience: non-blocking network calls that never freeze the terminal when internet is absent.

### 🐍 Python Automation Suite
- **Universal File Organizer**: Automated directory sorting by file categories.
- **Bulk Image Resizer**: Batch resizing, format conversion, and compression using Pillow.
- **YouTube Video & Audio Downloader**: High-efficiency media downloads leveraging `yt-dlp` and `ffmpeg`.

### 🏛️ 100% V1 Backward Compatibility
- Preserves all 12 original V1 utility modules: System Scripts, Essential Tools, Dev Kit, Driver Updates, Custom Applications, Game Setup & Runtimes, ISO Hub, Web Bookmarks, Optimizer, Maintenance, Wallpapers, and System Info.

---

## Tech Stack

| Component | Technology | Description |
| :--- | :--- | :--- |
| **Core Shell** | PowerShell (5.1+ / 7+) | Modular scripts (`.ps1`) for orchestration, CIM/WMI queries, and UI rendering |
| **CLI Wrapper** | Batch (`nfs.cmd`) | Command launcher forwarding flags to `main.ps1` |
| **Automation** | Python 3.x | File organization, image processing (Pillow), video downloading (`yt-dlp`) |
| **Package Engine**| `winget` | Official Windows Package Manager for package queries and unattended installs |
| **Configuration** | JSON | Settings (`config.json`), version manifest (`version.json`), app/driver catalogues |
| **Logging** | Multi-channel file logger | Timestamped structured logs (`nfs-cli.log`, `update.log`, `diagnostics.log`) |

---

## Prerequisites

- **Operating System**: Windows 10 (Build 1809 or newer) or Windows 11 (64-bit recommended).
- **PowerShell**: Windows PowerShell 5.1 (built into Windows) or PowerShell Core (7.0+).
- **Execution Policy**: Script execution enabled for current user or process (`RemoteSigned` or `Bypass`).
- **Privileges**: Administrator privileges are required for system-level actions (services, driver diagnostics, system repairs, optimizations). Read-only commands (`version`, `changelog`, `update -Check`) run without elevation.
- **Optional**: Python 3.8+ (for Python automation utilities) and `winget` (for automated software installs).

---

## Installation

### Method 1: Automated Web Bootstrapper (Recommended)

Open **PowerShell (Run as Administrator)** and execute:

```powershell
irm https://raw.githubusercontent.com/nfsprogramming/nfs-cli/main/install.ps1 | iex
```

The bootstrapper downloads all core modules into `$env:USERPROFILE\nfs-cli`, configures your User `PATH`, and creates an optional Desktop shortcut.

### Method 2: Manual Clone

Clone the repository using `git`:

```cmd
git clone https://github.com/nfsprogramming/nfs-cli.git "C:\nfs-cli"
cd "C:\nfs-cli"
```

To run `nfs` globally from any Command Prompt or PowerShell terminal, add the installation folder to your User `PATH`:

```powershell
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\nfs-cli", [EnvironmentVariableTarget]::User)
```

---

## Usage

### Interactive Dashboard Mode

Run `nfs` (or execute `main.ps1`) to enter the interactive cyber-terminal:

```powershell
# From Command Prompt or PowerShell:
nfs

# Or directly via PowerShell:
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\main.ps1
```

**Keyboard Navigation Highlights:**
- `[H]` — Run System Doctor
- `[N]` — Run Network Doctor
- `[D]` — Run Developer Doctor
- `[W]` — Launch Winget Studio
- `[P]` — Open Performance Center
- `[E]` — Open Event Log Analyzer
- `[C]` — Execute Clean Up & Maintenance
- `[L]` — Open Classic V1 Menu Suite
- `[S]` — Settings & Appearance
- `[Q]` — Exit CLI

### CLI Command-Line Mode

Run direct non-interactive commands:

```cmd
:: Display version and build details
nfs version

:: View version release notes and changelog
nfs changelog

:: Check if updates are available on GitHub
nfs update -Check

:: Apply latest update with automated backup
nfs update

:: Roll back to the previous version backup
nfs update -Rollback

:: Run System Doctor diagnostic directly
powershell -ExecutionPolicy Bypass -File .\main.ps1 -Command "doctor"

:: Run Network Doctor diagnostic directly
powershell -ExecutionPolicy Bypass -File .\main.ps1 -Command "doctor" -SubCommand "network"

:: Run Developer Toolchain Doctor directly
powershell -ExecutionPolicy Bypass -File .\main.ps1 -Command "doctor" -SubCommand "dev"
```

---

## Configuration

User configuration is persisted in [`assets/configs/config.json`](assets/configs/config.json):

```json
{
  "animations": "full",
  "animation_speed": "normal",
  "update_check": true,
  "update_channel": "stable",
  "logging": true,
  "theme": "nfs-neon"
}
```

- **`animations`**: `"full"`, `"minimal"`, or `"instant"` (disables animation delays).
- **`animation_speed`**: `"fast"`, `"normal"`, or `"slow"`.
- **`update_check`**: `true` / `false` (toggles update checks on launch).
- **`update_channel`**: `"stable"` or `"beta"`.
- **`logging`**: `true` / `false` (writes structured logs to `logs/`).
- **`theme`**: Terminal theme profile (`"nfs-neon"`, `"matrix"`, `"monochrome"`).

---

## Project Structure

```text
NFS-Programmer-CLI/
├── assets/
│   ├── configs/
│   │   ├── apps.json            # Curated application catalog
│   │   ├── config.json          # User preferences and theme options
│   │   ├── drivers.json         # Hardware driver portals and identifiers
│   │   ├── isos.json            # Verified operating system ISO links
│   │   ├── mywebs.json          # Developer and workflow web bookmarks
│   │   └── version.json         # Version, build metadata, and license
│   └── logo.txt                 # Terminal ASCII branding banner
├── modules/
│   ├── core/
│   │   ├── cinematic.ps1        # Terminal startup sequences and animations
│   │   ├── config.ps1           # Settings loader, validator, and saver
│   │   ├── logger.ps1           # Multi-file structured logger with sanitization
│   │   ├── terminal.ps1         # ANSI/VT console rendering and styling engine
│   │   └── update.ps1           # Semantic version checker, updater, and rollback
│   ├── developer/
│   │   ├── doctor.ps1           # Toolchain and compiler detector
│   │   └── packages.ps1         # Winget Studio interface and batch installer
│   ├── network/
│   │   └── doctor.ps1           # Network adapter, latency, and stack repair
│   ├── system/
│   │   ├── doctor.ps1           # Hardware, SMART, reboot, and service auditor
│   │   ├── eventlogs.ps1        # Event log filter (Critical, Error, Warning)
│   │   └── performance.ps1      # Live CPU/RAM processes and startup manager
│   ├── about.ps1                # System overview and author information
│   ├── customapps.ps1           # Curated utilities and power-user software
│   ├── devkit.ps1               # Developer environments, IDEs, and runtimes
│   ├── drivers.ps1              # Manufacturer and GPU driver installer
│   ├── gamesetup.ps1            # Gaming runtimes (DirectX, VC++ redists, .NET)
│   ├── helpers.ps1              # Shared utility functions and formatting helpers
│   ├── isos.ps1                 # Operating system download links
│   ├── isotools.ps1             # Bootable USB creation tools (Rufus, Ventoy)
│   ├── maintenance.ps1          # Disk cleanup, WinSXS servicing, battery reports
│   ├── mywebs.ps1               # Quick-launch bookmarks for developer workflows
│   ├── optimizer.ps1            # Windows tweaks, visual settings, telemetry
│   ├── python_scripts.ps1       # Python module runner and launcher
│   ├── scripts.ps1              # System scripts, fixes, and wallpaper manager
│   └── tools.ps1                # Essential productivity software setup
├── python_scripts/
│   ├── image_resizer.py         # Pillow-powered batch image processor
│   ├── organizer.py             # File system categorization utility
│   └── yt_downloader.py         # yt-dlp/ffmpeg media downloader
├── Desktop Wallpapers...🖥️/     # Included wallpaper collection
├── .gitignore                   # Repository ignore specifications
├── CHANGELOG.md                 # Semantic version change history
├── install.ps1                  # One-line remote bootstrap installer
├── LICENSE                      # MIT Open Source License
├── main.ps1                     # Main PowerShell script entrypoint
├── nfs.cmd                      # Windows command prompt launcher
├── README.md                    # Repository documentation
└── USER_MANUAL.md               # Complete reference manual
```

---

## Validation & Diagnostics

All core modules and scripts can be verified locally:

```powershell
# 1. Syntax check across all PowerShell scripts
Get-ChildItem -Recurse -Filter *.ps1 | ForEach-Object {
    $err = $null
    [System.Management.Automation.Language.Parser]::ParseFile($_.FullName, [ref]$null, [ref]$err)
    if ($err) { Write-Error "$($_.Name): $err" } else { Write-Host "✔ $($_.Name) valid" -ForegroundColor Green }
}

# 2. Syntax check across Python scripts
python -m py_compile python_scripts\organizer.py python_scripts\image_resizer.py python_scripts\yt_downloader.py

# 3. Version & Manifest validation
powershell -ExecutionPolicy Bypass -File .\main.ps1 version
```

---

## Limitations & Security Considerations

- **Windows Platform**: Designed specifically for Microsoft Windows (Windows 10 / 11) using Windows APIs, WMI/CIM classes, and `winget`. It is not compatible with Linux or macOS.
- **Administrative Privileges**: System-level repairs, service management, and software installations require running PowerShell as Administrator. Read-only diagnostic commands run cleanly in unprivileged shells.
- **Third-Party Utilities**: Modules that invoke external software (e.g., `winget`, `yt-dlp`, `ffmpeg`, `Rufus`) rely on those tools being present or installed through official repositories.
- **Safety First**: Destructive system actions (terminating processes, network stack reset, file deletions) always require explicit confirmation from the user before execution.

---

## Contributing

Contributions, bug reports, and suggestions are welcome!

1. **Fork** the repository on GitHub.
2. **Create a branch** for your feature or bug fix (`git checkout -b feature/my-feature`).
3. **Validate syntax and formatting** using PowerShell and Python syntax verification.
4. **Commit your changes** with clear, descriptive messages (`git commit -m "feat: add diagnostic check"`).
5. **Push your branch** (`git push origin feature/my-feature`) and open a **Pull Request**.

---

## License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for full details.

---

## Author & Acknowledgements

**NIFRAS** — *NFS Programming*
- **GitHub**: [@nfsprogramming](https://github.com/nfsprogramming)
- **Instagram**: [@_.nfsphotography._](https://www.instagram.com/_.nfsphotography._/)
- **LinkedIn**: [nfs-programming](https://linkedin.com/in/nfs-programming)

*Special thanks to the open-source PowerShell and Windows developer communities.*
