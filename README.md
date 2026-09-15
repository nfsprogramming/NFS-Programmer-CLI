# ⚡ NFS Programmer CLI — V2.0.0
> **Windows Developer & System Engineering Toolkit**

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

**NFS Programmer CLI V2** is a modular, high-performance terminal suite engineered for Windows power users, developers, and system administrators. It combines live hardware telemetry, system diagnostics, network doctoring, automated developer toolchain auditing, and official package management into a unified keyboard-driven CLI.

📖 **[Read the Official User Manual](USER_MANUAL.md)** for a complete guide to all features, commands, modules, and customization options.

---

## 🚀 Quick Install & Bootstrapping

Open **PowerShell (Run as Administrator)** and run:

```powershell
irm https://raw.githubusercontent.com/nfsprogramming/nfs-cli/main/install.ps1 | iex
```

Once installed, simply run `nfs` from any Command Prompt or PowerShell terminal.

---

## 🛠️ What's New in V2

### 🎛️ Terminal Welcome Dashboard
- **Live Hardware Telemetry**: Real-time CPU load %, RAM used/total GB, System Disk % used, GPU model, and system Uptime.
- **One-Touch Quick Actions**: Fast shortcuts to System Health, Network Doctor, Developer Environment, Cleanup, and Winget Studio.
- **Non-Intrusive Update Banner**: Instantly notifies you when updates are released on GitHub with one-key upgrade.

### 🩺 Diagnostic Doctors
- **System Doctor**: In-depth audit of CPU, Memory, Storage SMART status, Windows version & pending reboot checks, driver conflict error codes, and critical background services (Spooler, W32Time, CryptSvc, BITS, wuauserv).
- **Network Doctor**: Multi-adapter inspection, gateway reachability, public DNS resolution latency test (Google, Cloudflare, GitHub, AWS), and safe repair actions (Flush DNS, DHCP release/renew, Winsock & TCP/IP stack resets).
- **Developer Doctor**: Automated toolchain and compiler detection for Git, Python, Node.js, npm, Java/JDK, Go, Rust, Docker, VS Code, Flutter, Android SDK, and Windows Terminal, with one-click Winget installations.

### 📦 Package Management (Winget Studio)
- Direct integration with Windows Package Manager (`winget`):
  - Search packages across official Microsoft and community repos
  - Install and update software cleanly
  - Bulk upgrade all installed software (`winget upgrade --all`)
  - Export and import package bundles for rapid machine provisioning

### 🏎️ Performance Center & Event Logs
- **Performance Center**: Live resource consumption tracking, top 15 memory/CPU processes, and startup application inspector with safe confirmation before terminating any process.
- **Event Log Analyzer**: Smart filtering of Critical, Error, and Warning events across System, Application, and Driver event streams over the past 24 hours.

### 🛡️ Defensive Update & Rollback Engine
- Semantic version checks against official GitHub Releases (`nfsprogramming/nfs-cli`).
- Automatic pre-update backup creation before applying updates.
- One-click rollback command (`nfs update --rollback`) to restore previous versions safely.
- Offline-first resilience: never freezes or blocks when internet is unavailable.

---

## 📋 Command-Line Interface (CLI)

You can run `nfs` directly with commands and flags:

```powershell
# Check current version
nfs version

# View release notes & changelog
nfs changelog

# Check for updates
nfs update --check

# Install latest release safely
nfs update

# Rollback to previous version backup
nfs update --rollback

# Run System Doctor directly
nfs doctor

# Run Network Doctor directly
nfs doctor network

# Run Developer Doctor directly
nfs doctor dev
```

---

## 🏛️ Architecture & V1 Compatibility

NFS Programmer CLI V2 is built with **100% backward compatibility**. All 12 original V1 modules are preserved and accessible either directly or through the **Classic V1 Menu** (`[L]` key):

```text
NFS CLI V2
├── Core
│   ├── config.ps1       (User settings: animations, speed, theme, update channel)
│   ├── logger.ps1       (Multi-file structured logging: nfs-cli.log, update.log)
│   ├── terminal.ps1     (ANSI/VT console rendering, startup sequence)
│   └── update.ps1       (Semver checker, GitHub releases updater, rollback)
├── System
│   ├── doctor.ps1       (System Doctor: CPU, RAM, SMART Storage, Services)
│   ├── performance.ps1  (Live metrics, top processes, startup items)
│   └── eventlogs.ps1    (Critical/Error/Warning event log filtering)
├── Network
│   └── doctor.ps1       (Adapter, IP, DNS latency benchmarks, stack repair)
├── Developer
│   ├── doctor.ps1       (Toolchain audit: Git, Python, Node, Go, Rust, Docker)
│   └── packages.ps1     (Winget Studio: search, install, bulk upgrade)
└── Legacy / V1 Menus
    ├── 1. Scripts       (MAS, Spicetify, Win11 Debloat, Ultra Optimizer, IDM)
    ├── 2. Tools         (Minimal Setup, Browsers, Media, Creative Suite)
    ├── 3. Dev Kit       (AI Editors, Languages, IDEs, Databases)
    ├── 4. Drivers       (Auto-detect manufacturer & GPU drivers)
    ├── 5. Custom Apps   (Pro user tools, utilities, gaming launchers)
    ├── 6. Game Setup    (DirectX, VC++ Runtimes, .NET, Launchers)
    ├── 7. ISO Hub       (Windows 10/11, Ghost Spectre, Linux ISOs)
    ├── 8. My Webs       (Developer links, AI tools, profile bookmarks)
    ├── P. Python Tools  (File Organizer, Image Resizer, YT Downloader)
    ├── 0. Optimizer     (System tweaks, UI toggles, telemetry blocking)
    ├── M. Maintenance   (Cleanmgr, WinSXS cleanup, SMART, Battery reports)
    └── 9. About         (System specs and author contacts)
```

---

## ⚙️ Configuration

Custom settings are saved in `assets/configs/config.json`:

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

You can toggle animations (`Full`, `Minimal`, `Instant / None`), theme (`NFS Neon`, `Monochrome`, `Matrix`), and update behaviors dynamically inside the CLI via `[S] Settings & Theme`.

---

## 👨‍💻 Author
**NIFRAS** — *NFS PROGRAMMING*
* **GitHub**: [github.com/nfsprogramming](https://github.com/nfsprogramming)
* **Instagram**: [@NIFRAS](https://www.instagram.com/_.nfsphotography._/)
* **LinkedIn**: [linkedin.com/in/nfs-programming](https://linkedin.com/in/nfs-programming)
