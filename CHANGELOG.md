# Changelog

All notable changes to the **NFS Programmer CLI** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.0.0] - 2026-09-15

### Added
- **Premium Startup Experience**:
  - Multi-phase fast startup sequence (~1.5–2.5s maximum) with spinner, compact ASCII logo reveal, and sequential title display.
  - Real-time initialization checks: Core engine, Configuration, Module discovery, Environment diagnostics, and Update service connectivity.
  - Safe ANSI/VT terminal detection with seamless fallback for standard Windows consoles.
  - User-configurable animation modes: Full, Minimal, or Instant (Disabled).
- **V2 Welcome Dashboard**:
  - Live hardware metrics card featuring real-time CPU load %, RAM used/total GB, System Disk % used, GPU model, and system Uptime.
  - One-touch Quick Actions navigation for modern developer & system engineering workflows.
  - Non-intrusive Update Notification Banner with changelog highlights and direct update triggers.
- **Defensive Update & Rollback Engine**:
  - Automated version comparison against official GitHub Releases (`nfsprogramming/nfs-cli`) using Semantic Versioning.
  - Safe multi-step upgrade workflow: release validation, temp download, payload verification, pre-update backup, file replacement, post-update verification, and automatic rollback on failure.
  - Dedicated Rollback module (`Invoke-NFSRollback`) to restore prior backups at any time.
  - CLI commands: `nfs update`, `nfs update --check`, `nfs update --latest`, `nfs update --rollback`, `nfs version`, `nfs changelog`.
  - Offline-first resilience: graceful network fallbacks without startup blocking or crashes.
- **System Doctor**:
  - Comprehensive health evaluation of CPU, Memory load, Storage SMART prediction status, Windows build & pending reboot flags, Driver conflict error codes, and Critical Windows background services (Spooler, W32Time, CryptSvc, BITS, wuauserv).
  - Summarized Health Score Card and exportable diagnostic reports.
- **Network Doctor**:
  - Diagnostics for active adapters, IPv4/IPv6 addressing, gateway reachability, DHCP status, and DNS configurations.
  - High-precision DNS resolution and latency benchmarks across major worldwide endpoints (Google, Cloudflare, Microsoft, GitHub, AWS).
  - ICMP ping and packet loss tests.
  - Safe repair actions with explicit confirmations: DNS flush, DHCP release/renew, Winsock & TCP/IP stack resets, and adapter restarts.
- **Developer Doctor**:
  - Automated environment inspection and version detection for Git, Python, Node.js, npm, Java/JDK, Go, Rust, Docker, VS Code, Flutter, Android SDK/adb, PowerShell 7, and Windows Terminal.
  - One-click installation of missing toolchains via official Winget IDs with explicit user confirmation.
- **Package Management (Winget Studio)**:
  - Complete terminal UI for Windows Package Manager (`winget`): Search, Install, Check Updates, Upgrade All, Uninstall, Export manifest, and Import batch manifests.
- **Performance Center**:
  - Real-time CPU, RAM, and Disk load monitors.
  - Top 15 resource consumers sorted by Working Set RAM or CPU execution time.
  - Startup Applications Inspector for user and machine registry run keys.
  - Safe process inspector and terminator with strict confirmation prompts.
- **Event Log Analyzer**:
  - Filter and summarize Critical, Error, and Warning events across System, Application, and Driver logs from the past 24 hours.
  - Human-readable summaries with event IDs, sources, and readable error text.
  - Export capabilities for forensic review.
- **Multi-Channel Logging System**:
  - Segregated, timestamped logs saved to `logs/` (`nfs-cli.log`, `update.log`, `diagnostics.log`).
  - Automatic token and credential sanitization.
- **Configuration & Settings System**:
  - Centralized settings stored in `assets/configs/config.json` (animation style, animation speed, auto-update check, update channel, logging toggle, interface theme).
- **Command-Line Interface**:
  - `nfs.cmd` script for running commands directly from Command Prompt or PowerShell terminal.

### Improved
- Structured error handling across all modules (`[✗] Operation failed... Reason: ... Suggested action: ...`).
- High-contrast, dark-mode terminal UI adhering to the NFS Neon design language.
- Faster module loading and verified non-blocking network requests.

### Preserved
- **100% of all working V1 features and workflows**:
  - Scripts (MAS, Spicetify, Windows Update reset, SFC/DISM repair, Network stack, Hyper-V, WSL2, SSD TRIM, Ultra Optimizer, Wallpapers, IDM Supreme)
  - Tools (Minimal setup bundle, Browsers, Communication, Media, Creative Suite, Cloud Storage, Utilities)
  - Dev Kit (AI Editors, Languages & Runtimes, IDEs, Mobile & Source Control, Database & Containers)
  - Driver Update (Auto-detect PC manufacturer & GPU, official download portals)
  - Custom Apps (Pro user tools, Gaming & Social, Essential utilities, Productivity & Creative)
  - Game Setup (DirectX, VC++ all-in-one runtimes, .NET runtimes, XNA, Launchers, Performance monitors)
  - ISO Hub (Official and optimized OS ISO download links)
  - My Webs (Quick launch dev, AI, and profile links)
  - Python Scripts (Universal File Organizer, Bulk Image Resizer, YouTube Downloader)
  - System Optimizer (UI personalization, Explorer restart, Power plans, Telemetry blocks, Cleaners)
  - Maintenance (Cleanmgr, WinSXS Component Store analysis & cleanup, Prefetch, SMART disk, Battery reports)
  - About (System specs readout and developer contact links)
  - Dedicated Classic V1 Menu accessible via `[L]` key from the V2 Dashboard.

---

## [1.0.0] - Initial Release
- Original release of NFS Programmer CLI with 12 modular PowerShell scripts and basic terminal menu.
