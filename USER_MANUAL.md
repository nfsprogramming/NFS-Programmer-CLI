# 📖 NFS PROGRAMMER CLI V2 — OFFICIAL USER MANUAL
> **Windows Developer & System Engineering Toolkit**  
> *Author: NIFRAS (NFS Programming)*  
> *Version: 2.0.0 | Build: 200*

---

## 📑 Table of Contents
1. [Introduction & Overview](#1-introduction--overview)
2. [System Requirements & Compatibility](#2-system-requirements--compatibility)
3. [Installation & Getting Started](#3-installation--getting-started)
4. [CLI Command-Line Interface (`nfs.cmd`)](#4-cli-command-line-interface-nfscmd)
5. [The Startup Experience & Controls](#5-the-startup-experience--controls)
6. [Welcome Dashboard Navigation](#6-welcome-dashboard-navigation)
7. [V2 Engineering Modules](#7-v2-engineering-modules)
   - [7.1 System Doctor](#71-system-doctor)
   - [7.2 Network Doctor](#72-network-doctor)
   - [7.3 Developer Doctor](#73-developer-doctor)
   - [7.4 Package Management (Winget Studio)](#74-package-management-winget-studio)
   - [7.5 Performance Center](#75-performance-center)
   - [7.6 Event Log Analyzer](#76-event-log-analyzer)
   - [7.7 Update & Rollback Center](#77-update--rollback-center)
8. [Classic V1 Menus & Modules (100% Preserved)](#8-classic-v1-menus--modules-100-preserved)
   - [8.1 Scripts & Fixes](#81-scripts--fixes)
   - [8.2 Tools & Essentials](#82-tools--essentials)
   - [8.3 Dev Kit](#83-dev-kit)
   - [8.4 Driver Update](#84-driver-update)
   - [8.5 Custom Apps & Suites](#85-custom-apps--suites)
   - [8.6 Game Setup & Runtimes](#86-game-setup--runtimes)
   - [8.7 ISO Hub & OS Tools](#87-iso-hub--os-tools)
   - [8.8 My Webs](#88-my-webs)
   - [8.9 Python Automation Scripts](#89-python-automation-scripts)
   - [8.10 System Optimizer](#810-system-optimizer)
   - [8.11 Maintenance & Diagnostics](#811-maintenance--diagnostics)
   - [8.12 About & Contact](#812-about--contact)
9. [Configuration & Customization (`config.json`)](#9-configuration--customization-configjson)
10. [Multi-Channel Logging System](#10-multi-channel-logging-system)
11. [Troubleshooting & FAQ](#11-troubleshooting--faq)

---

## 1. Introduction & Overview

**NFS Programmer CLI V2** is a modular, keyboard-driven console operating environment built for Windows developers, power users, and system engineers. 

V2 upgrades the suite from a collection of scripts into a cohesive system engineering suite featuring:
* **Live Hardware Telemetry**: Instant CPU, RAM, Disk, and Uptime readouts.
* **Diagnostic Doctors**: Real hardware audits, DNS latency tests, and automated toolchain checks.
* **Defensive Update Engine**: Semantic-versioned GitHub release updater with automatic backup and instant rollback.
* **Cyberpunk Cinematic Boot Sequence**: An original multi-layer terminal initialization sequence.
* **100% Backward Compatibility**: Every single feature, menu, and script from V1 remains accessible.

---

## 2. System Requirements & Compatibility

| Component | Minimum Requirement | Recommended |
| :--- | :--- | :--- |
| **Operating System** | Windows 10 (Build 1809+) 64-bit | Windows 11 (Build 22H2 or newer) |
| **Shell** | Windows PowerShell 5.1 | PowerShell 7.4+ |
| **Terminal Host** | Standard Windows Console Host | Windows Terminal |
| **Privileges** | Standard user (Auto-elevates to Admin) | Administrator (Run as Admin) |
| **Package Manager** | Optional | Windows Package Manager (`winget`) |
| **Architecture** | x64 / AMD64 | x64 / AMD64 |

---

## 3. Installation & Getting Started

### 3.1 One-Line Remote Installer
Open **PowerShell as Administrator** and paste:

```powershell
irm https://raw.githubusercontent.com/nfsprogramming/nfs-cli/main/install.ps1 | iex
```

The installer will:
1. Download all Core, System, Network, Developer, and V1 legacy modules to `%USERPROFILE%\nfs-cli`.
2. Add `%USERPROFILE%\nfs-cli` to your user `PATH`.
3. Create an **NFS CLI** desktop shortcut.
4. Prompt you to launch the CLI immediately.

### 3.2 Running Locally
If you have cloned or extracted the repository locally:
1. Open PowerShell or Command Prompt as Administrator in the project directory.
2. Launch via PowerShell:
   ```powershell
   powershell.exe -ExecutionPolicy Bypass -File .\main.ps1
   ```
3. Or simply launch using the bundled CLI wrapper:
   ```cmd
   .\nfs.cmd
   ```

---

## 4. CLI Command-Line Interface (`nfs.cmd`)

NFS Programmer CLI V2 includes a global wrapper (`nfs.cmd`) that supports direct terminal flags and commands:

```bash
# Display version and build information
nfs version

# Display the complete release changelog
nfs changelog

# Check GitHub Releases for new updates
nfs update --check

# Execute a safe update to the latest release
nfs update

# Roll back to a previous backup
nfs update --rollback

# Run the System Doctor health audit directly
nfs doctor

# Run the Network Doctor latency & adapter diagnostics directly
nfs doctor network

# Run the Developer Doctor toolchain audit directly
nfs doctor dev

# Launch the CLI with high-speed animation (~1.2s)
nfs --fast

# Launch the CLI immediately with animation bypassed (0.0s)
nfs --no-intro
```

---

## 5. The Startup Experience & Controls

When NFS Programmer CLI starts, it launches the **Extreme Cinematic Boot Sequence**:
1. **Awakening**: `NFS://BOOT` indicator appears from a black screen.
2. **Data Ignition**: Hexadecimal stream bursts converge toward the center.
3. **Live System HUD**: Reads real OS, RAM, Arch, and CPU information into corner boxes.
4. **Telemetry Gauges**: CPU, Memory, and Core progress bars synchronize.
5. **NFS Core Graph**: ASCII node topology activates node-by-node.
6. **Logo Assembly**: Particles converge into the official NFS logo followed by a Quantum Scan Beam.
7. **Glitch & Stabilization**: Controlled 100ms micro-jitter that immediately snaps to stability.
8. **Brand Reveal & System Lock**: System status checks are verified and locked.
9. **Final Command Handoff**: `NFS://CORE ONLINE` transitions smoothly into the Welcome Dashboard.

### Startup Controls
* **Skip Animation**: Press **any key** during the animation to jump straight to the dashboard.
* **Disable Permanently**: In `[S] Settings & Theme`, set **Startup Animation** to `Disabled (Instant)`.
* **Fast Mode**: Pass `--fast` or configure **Animation Speed** to `Fast`.
* **Small Terminals**: For window widths under 78 columns, a compact, clean sequence runs automatically without layout distortion.

---

## 6. Welcome Dashboard Navigation

After boot, the V2 Welcome Dashboard displays your live system overview:

```text
  ⚡ NFS PROGRAMMER CLI v2.0.0 ── Windows Developer & System Engineering
  ─────────────────────────────────────────────────────────────────────────────
  ● Host   : User@Hostname    ● Uptime : 1d 4h 22m    ● Health : Online & Healthy

  LIVE SYSTEM TELEMETRY
    CPU    [■■······] 12%       RAM    [■■■■····] 8.2 / 16.0 GB (51%)   DISK   [■■■■····] 45% (C:)
    GPU    NVIDIA GeForce RTX 4070

  DIAGNOSTICS & HEALTH
    [1] System Health Doctor          [2] Network Doctor Suite
    [3] Developer Tool Doctor         [4] Cleanup & System Maintenance
    [6] Event Logs & Diagnostics      [7] Real-Time Performance Center

  PACKAGES & WORKFLOWS
    [5] Winget Package Studio         [L] Classic V1 Menus (All 12 Modules)

  UTILITIES & CONFIGURATION
    [U] Update & Rollback Center      [S] Settings & Terminal Theme
    [A] About NFS CLI                 [Q] Quit

  ─────────────────────────────────────────────────────────────────────────────
  ⚡ Select option › 
```

To select an option, type the corresponding key and press **Enter**.

---

## 7. V2 Engineering Modules

### 7.1 System Doctor
**Command / Key:** `[1]` or `nfs doctor`  
**File:** [doctor.ps1](file:///e:/NFS%20PROGRAMMER%20CLI/modules/system/doctor.ps1)

The System Doctor performs a thorough, non-destructive audit of system health:
* **CPU**: Measures live processor load and verifies processor specifications.
* **Memory**: Calculates physical RAM usage, free capacity, and warns if usage exceeds 90%.
* **Storage & SMART**: Reads free space on the system drive and checks `MSStorageDriver_FailurePredictStatus` for impending hardware drive failures.
* **Windows Build & Reboot Check**: Verifies build number and queries Component-Based Servicing and Windows Update for pending reboots.
* **Critical Services**: Checks background services (`wuauserv`, `CryptSvc`, `BITS`, `Spooler`, `W32Time`).
* **Hardware Drivers**: Queries `Win32_PnPEntity` for devices returning non-zero configuration error codes.
* **Network Status**: Confirms active interface readiness.
* **Sub-Features**:
  * `[1]` Export diagnostic report to text file.
  * `[2]` View detailed list of problem hardware devices.
  * `[3]` Generate and open an official HTML Battery Health Report.

---

### 7.2 Network Doctor
**Command / Key:** `[2]` or `nfs doctor network`  
**File:** [doctor.ps1](file:///e:/NFS%20PROGRAMMER%20CLI/modules/network/doctor.ps1)

The Network Doctor diagnoses connectivity issues and provides safe repair actions:
* **Audit**: Active adapter name, link speed, IPv4/IPv6, default gateway reachability, DHCP status, and configured DNS servers.
* **DNS Resolution & Latency**: Tests high-precision resolution against 5 worldwide endpoints (`google.com`, `cloudflare.com`, `microsoft.com`, `github.com`, `aws.amazon.com`) with latency in milliseconds.
* **Ping & Loss Test**: Sends ICMP packets to `1.1.1.1` and `8.8.8.8` to evaluate packet loss and average round-trip times.
* **Safe Repairs (Confirmation Required)**:
  * **Flush DNS**: Clears Windows DNS resolver cache.
  * **Renew DHCP Lease**: Releases and requests a fresh IPv4 lease.
  * **Network Stack Reset**: Resets Winsock catalog and TCP/IP stack configuration.
  * **Restart Adapter**: Toggles the active network adapter off and on.

---

### 7.3 Developer Doctor
**Command / Key:** `[3]` or `nfs doctor dev`  
**File:** [doctor.ps1](file:///e:/NFS%20PROGRAMMER%20CLI/modules/developer/doctor.ps1)

The Developer Doctor audits developer toolchains and SDKs:
* Scans PATH and environment variables for:
  * **Git**
  * **Python**
  * **Node.js & npm**
  * **Java / JDK**
  * **Go (Golang)**
  * **Rust (`rustc`)**
  * **Docker Desktop**
  * **Visual Studio Code**
  * **Flutter SDK**
  * **Android SDK / `adb`**
  * **PowerShell 7**
  * **Windows Terminal**
* Displays detected installed versions or flags missing tools.
* Offers **one-click installation** of missing tools via Winget with explicit confirmation.

---

### 7.4 Package Management (Winget Studio)
**Command / Key:** `[5]`  
**File:** [packages.ps1](file:///e:/NFS%20PROGRAMMER%20CLI/modules/developer/packages.ps1)

A complete console interface for Windows Package Manager (`winget`):
1. **Search Packages**: Searches official Microsoft community repositories by keyword.
2. **Install Package**: Installs any application by its Winget ID with real-time feedback.
3. **Check for App Updates**: Lists all installed applications with newer versions available.
4. **Upgrade All Installed Apps**: Runs `winget upgrade --all` after user confirmation.
5. **Uninstall Application**: Removes software cleanly using package identifiers.
6. **Export Installed Packages**: Exports a portable JSON manifest of all installed software to your Desktop.
7. **Import Packages**: Installs all packages listed in an exported JSON manifest for rapid machine provisioning.

---

### 7.5 Performance Center
**Command / Key:** `[7]`  
**File:** [performance.ps1](file:///e:/NFS%20PROGRAMMER%20CLI/modules/system/performance.ps1)

Monitor and manage system resource consumption:
* **Live Telemetry**: Continuously updated CPU %, RAM %, and System Disk % utilization.
* **Top Processes by Memory**: Ranks the top 15 processes by Working Set memory consumption in MB.
* **Top Processes by CPU**: Ranks the top 15 processes by cumulative CPU time in seconds.
* **Startup Applications Inspector**: Audits all startup applications configured in `HKCU:\...\Run` and `HKLM:\...\Run`.
* **Safe Process Termination**: Enter a PID or process name to review process details (path, memory, PID) and terminate it with mandatory confirmation (no auto-killing).

---

### 7.6 Event Log Analyzer
**Command / Key:** `[6]`  
**File:** [eventlogs.ps1](file:///e:/NFS%20PROGRAMMER%20CLI/modules/system/eventlogs.ps1)

Inspect high-priority system and application events from the last 24 hours:
1. **System Events**: Filters `Critical` and `Error` events from the Windows System log.
2. **Application Events**: Filters `Error` and `Warning` events from the Application log.
3. **Hardware & Driver Events**: Scans for events from `Kernel-PnP`, `Disk`, and display drivers.
4. **Custom Event Filter**: Choose log source, error severity, and maximum events to retrieve.
5. **Export Event Summary**: Saves formatted event diagnostic records to a text file for sharing with IT support.

---

### 7.7 Update & Rollback Center
**Command / Key:** `[U]` or `nfs update`  
**File:** [update.ps1](file:///e:/NFS%20PROGRAMMER%20CLI/modules/core/update.ps1)

Maintains the CLI safely:
* **Check for Updates**: Queries `https://api.github.com/repos/nfsprogramming/nfs-cli/releases/latest` using semantic version comparison.
* **Defensive Update Workflow**:
  1. Validates release metadata.
  2. Downloads release zip to a temporary sandbox.
  3. Verifies package integrity.
  4. Automatically backs up your current installation into `backup/v<current>/`.
  5. Applies updated files.
  6. Validates the updated installation.
  7. If validation fails, automatically restores your previous version from backup.
* **Rollback to Previous Version**: Restores any existing backup folder in one click.
* **Changelog**: Displays release notes and version history.
* **Offline Resilience**: If GitHub is unreachable, reports offline status without blocking or crashing.

---

## 8. Classic V1 Menus & Modules (100% Preserved)

To access the original V1 menu, press **`[L]`** from the main dashboard. Every single V1 module and workflow is preserved:

### 8.1 Scripts & Fixes
**Option:** `[1]` in V1 Menu | **File:** [scripts.ps1](file:///e:/NFS%20PROGRAMMER%20CLI/modules/scripts.ps1)
* `1. Microsoft Activation Scripts (MAS)`: Opens MAS online activator via massgrave.dev.
* `2. Spicetify`: Safe user-mode Spicetify deployment bridge with de-elevation.
* `3. Flush DNS Cache`: Clears DNS resolver cache.
* `4. Reset Windows Update`: Stops update services and purges `SoftwareDistribution` & `Catroot2`.
* `5. Clear Temp Files`: Cleans `%TEMP%`, `%TMP%`, and Windows temp directories.
* `6. Repair System Files`: Executes `sfc /scannow` followed by DISM `/RestoreHealth`.
* `7. Network Reset`: Winsock and TCP/IP stack reset.
* `8. Enable/Disable Hyper-V`: Toggles Windows optional feature `Microsoft-Hyper-V-All`.
* `9. Enable WSL2`: Triggers Windows Subsystem for Linux installation.
* `10. Optimize SSD (TRIM)`: Runs `Optimize-Volume -ReTrim` across all fixed SSDs.
* `11. Show System Info`: Machine, CPU, GPU, RAM, and uptime readout.
* `12. Restart Explorer`: Restarts the `explorer.exe` shell process.
* `13. Chris Titus Tech Utility`: Launches CTT Windows Utility.
* `14. Win11 Debloater`: Launches Universal Win11 Debloater script.
* `15. Reset Windows Store`: Runs `wsreset.exe`.
* `16. NFS Ultra Optimizer`: Enables gaming power plan, disables power throttling, tunes system responsiveness.
* `17. NFS Wallpaper Manager`: Syncs wallpapers from GitHub and applies desktop backgrounds.
* `18. NFS MyApps (IDM Supreme)`: Launches IDM installer with admin elevation.

### 8.2 Tools & Essentials
**Option:** `[2]` in V1 Menu | **File:** [tools.ps1](file:///e:/NFS%20PROGRAMMER%20CLI/modules/tools.ps1)
* Minimal setup bundle (Chrome, VLC, LocalSend, Office, Python, Spotify).
* Categorized application installers: Browsers, Communication, Media, Creative Suite, Cloud Storage, Utilities.

### 8.3 Dev Kit
**Option:** `[3]` in V1 Menu | **File:** [devkit.ps1](file:///e:/NFS%20PROGRAMMER%20CLI/modules/devkit.ps1)
* AI-Powered Editors (Cursor, Windsurf, Trae, Antigravity).
* Languages & Runtimes (Python 3.12, Node.js LTS, Temurin JDK 21, Go, Rustup).
* Editors & IDEs (VS Code, Android Studio, JetBrains Toolbox).
* Source Control & Databases (Git, GitHub Desktop, Docker Desktop, Postman, DBeaver, TablePlus, Windows Terminal).

### 8.4 Driver Update
**Option:** `[4]` in V1 Menu | **File:** [drivers.ps1](file:///e:/NFS%20PROGRAMMER%20CLI/modules/drivers.ps1)
* Automatically detects manufacturer (ASUS, Lenovo, Dell, HP, Acer, MSI, Samsung, Razer) and installs the official vendor support application.
* Detects GPU vendor (NVIDIA, AMD, Intel) and launches the official driver download portal.

### 8.5 Custom Apps & Suites
**Option:** `[5]` in V1 Menu | **File:** [customapps.ps1](file:///e:/NFS%20PROGRAMMER%20CLI/modules/customapps.ps1)
* 34 hand-picked applications across Pro User Tools (Windhawk, Rainmeter, Spacedesk, WizTree, HWInfo64), Gaming/Social (Discord, Steam, Epic Games, Spotify), Utilities (7-Zip, Rufus, ShareX, VLC), and Productivity (Notion, Obsidian, Figma, Bitwarden).

### 8.6 Game Setup & Runtimes
**Option:** `[6]` in V1 Menu | **File:** [gamesetup.ps1](file:///e:/NFS%20PROGRAMMER%20CLI/modules/gamesetup.ps1)
* Essential runtimes: DirectX End-User Runtime, Visual C++ 2005-2022 All-in-One Redistributables, .NET Framework 3.5/6/8, and XNA Framework 4.0.
* Game launchers: Steam, Xbox App, Epic Games, GOG Galaxy, Battle.net, Playnite.
* Performance tuning: MSI Afterburner, RivaTuner Statistics Server (RTSS), CrystalDiskMark.

### 8.7 ISO Hub & OS Tools
**Option:** `[7]` in V1 Menu | **File:** [isos.ps1](file:///e:/NFS%20PROGRAMMER%20CLI/modules/isos.ps1) & [isotools.ps1](file:///e:/NFS%20PROGRAMMER%20CLI/modules/isotools.ps1)
* ISO Hub: Direct links to official Windows 10/11, Ghost Spectre Lite, ROG Edition, Hiren's BootCD PE, Ubuntu 24.04, Linux Mint, Pop!_OS, Kali Linux, Arch, and Fedora.
* OS Tools: Disable telemetry, remove bloatware, disable Xbox Game Bar, disable Cortana, enable Ultimate Performance plan, enable HAGS, enable dark mode, and create System Restore Points.

### 8.8 My Webs
**Option:** `[8]` in V1 Menu | **File:** [mywebs.ps1](file:///e:/NFS%20PROGRAMMER%20CLI/modules/mywebs.ps1)
* Quick-launch bookmarks for developer portals (GitHub, Vercel, Render, Netlify, Supabase, Firebase), AI Tools (ChatGPT, Claude, Perplexity, Gemini, Hugging Face), Dev Resources (StackOverflow, MDN, DevDocs), and Downloads.

### 8.9 Python Automation Scripts
**Option:** `[P]` in V1 Menu | **File:** [python_scripts.ps1](file:///e:/NFS%20PROGRAMMER%20CLI/modules/python_scripts.ps1)
* `1. Universal File Organizer`: Automatically organizes messy directories by extension into Documents, Images, Videos, etc.
* `2. Bulk Image Resizer & Converter`: Batch resizes and converts image collections with Pillow.
* `3. YouTube Video & Audio Downloader`: Downloads high-quality video and audio via `yt-dlp` and `ffmpeg`.

### 8.10 System Optimizer
**Option:** `[0]` in V1 Menu | **File:** [optimizer.ps1](file:///e:/NFS%20PROGRAMMER%20CLI/modules/optimizer.ps1)
* Personalization toggles: Theme (Dark/Light), Taskbar alignment (Left/Center), Taskbar size, Hidden files visibility, File extensions visibility, and Windows 11 Classic context menu restoration.
* Performance tweaks: Ultimate Power Plan unlock, Ultra Telemetry block, start menu web search disable, event logs purge, hibernation toggle, deep temp clean, and complete OneDrive uninstaller.

### 8.11 Maintenance & Diagnostics
**Option:** `[M]` in V1 Menu | **File:** [maintenance.ps1](file:///e:/NFS%20PROGRAMMER%20CLI/modules/maintenance.ps1)
* Cleanup: Disk Cleanup (cleanmgr sageset/sagerun), WinSXS Component Store analysis and deep cleanup (`/StartComponentCleanup /ResetBase`), and prefetch cache purge.
* Diagnostics: Read-only chkdsk, HTML battery health report, SMART storage drive failure predictor, and network connection profile viewer.

### 8.12 About & Contact
**Option:** `[9]` in V1 Menu | **File:** [about.ps1](file:///e:/NFS%20PROGRAMMER%20CLI/modules/about.ps1)
* Displays version specs, hardware summary, and author contact links (GitHub, Instagram, LinkedIn, WhatsApp).

---

## 9. Configuration & Customization (`config.json`)

User preferences are persisted in [config.json](file:///e:/NFS%20PROGRAMMER%20CLI/assets/configs/config.json):

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

### Configuration Options
| Setting | Allowed Values | Description |
| :--- | :--- | :--- |
| `animations` | `"full"`, `"minimal"`, `"none"` | Startup intro style. `"none"` loads instantly. |
| `animation_speed` | `"normal"`, `"fast"` | Animation pacing. `"fast"` runs in ~1.2s. |
| `update_check` | `true`, `false` | Automatically checks GitHub Releases on boot. |
| `update_channel` | `"stable"`, `"beta"` | Release branch to query. |
| `logging` | `true`, `false` | Enables structured multi-channel logging. |
| `theme` | `"nfs-neon"`, `"monochrome"`, `"matrix"` | Color palette for borders and text highlights. |

You can modify these settings through the interactive menu in **`[S] Settings & Theme`** or by editing `config.json` directly.

---

## 10. Multi-Channel Logging System

When logging is enabled, NFS Programmer CLI writes structured, timestamped logs to the `logs/` directory:

| Log File | Purpose |
| :--- | :--- |
| [nfs-cli.log](file:///e:/NFS%20PROGRAMMER%20CLI/logs/nfs-cli.log) | Main application events, startup sequence, and tool execution. |
| [update.log](file:///e:/NFS%20PROGRAMMER%20CLI/logs/update.log) | Update checks, release downloads, backups, and rollbacks. |
| [diagnostics.log](file:///e:/NFS%20PROGRAMMER%20CLI/logs/diagnostics.log) | Health audit logs from System Doctor and Network Doctor. |

* **Privacy Protection**: All loggers automatically scrub and redact sensitive tokens, passwords, and authorization keys.
* **Log Viewer**: View recent application and update logs directly in the CLI under `[S] Settings` or `[U] Update Center`.

---

## 11. Troubleshooting & FAQ

### Q: Do I need Administrator rights to run the CLI?
**A:** Yes for system repairs, optimizer tweaks, and software installations. If you launch the CLI as a standard user, it will prompt for elevation. Read-only commands such as `nfs version` and `nfs changelog` run directly without elevation.

### Q: How do I skip or disable the startup animation?
**A:**
* **Temporary Skip**: Press any key on your keyboard while the intro is playing.
* **CLI Flag**: Run `nfs --no-intro` or `nfs --fast`.
* **Permanent Setting**: Press `[S]` in the CLI, select `[1] Startup Animation`, and choose `[3] No Animation (Instant)`.

### Q: What happens if I am offline without an internet connection?
**A:** NFS Programmer CLI is designed offline-first. If GitHub or the internet is unreachable, the update check will report `[!] Update check unavailable (Offline)` and startup will continue immediately without hanging or throwing errors.

### Q: How do I restore an earlier version if an update causes issues?
**A:** Run `nfs update --rollback` or select `[U] Update Center` -> `[3] Rollback to Previous Version`. Backups created prior to each update are stored in the `backup/` directory.

### Q: Why do some winget installations prompt for confirmation?
**A:** The CLI adheres strictly to safe package installation practices. Destructive operations, network resets, and tool installations will always request your explicit confirmation before executing.

---

## 👨‍💻 Author & Support
**NIFRAS** — *NFS PROGRAMMING*
* **GitHub**: [github.com/nfsprogramming](https://github.com/nfsprogramming)
* **Instagram**: [@NIFRAS](https://www.instagram.com/_.nfsphotography._/)
* **LinkedIn**: [linkedin.com/in/nfs-programming](https://linkedin.com/in/nfs-programming)
