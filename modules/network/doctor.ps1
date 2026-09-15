# ============================================================
#  NFS CLI V2 - network/doctor.ps1
#  Network Doctor: Diagnostics, Connectivity Tests & Safe Repairs
# ============================================================

function Show-NetworkDoctor {
    while ($true) {
        Clear-Host
        Write-Section "NETWORK DOCTOR"
        Write-Host ""
        Write-Host "  Diagnose adapter configuration, DNS latency, internet reachability & repair stack." -ForegroundColor DarkGray
        Write-Host ""

        Write-Host "  +-----------------------------------------------------+" -ForegroundColor DarkGreen
        Write-Host "  |  1.  Run Full Network Health Audit                  |" -ForegroundColor Green
        Write-Host "  |  2.  Test DNS Resolution & Latency (Multi-Host)     |" -ForegroundColor Cyan
        Write-Host "  |  3.  Ping & Packet Loss Test                        |" -ForegroundColor Cyan
        Write-Host "  |  4.  Flush DNS Resolver Cache                       |" -ForegroundColor Yellow
        Write-Host "  |  5.  Renew DHCP Lease (Release & Renew IP)          |" -ForegroundColor Yellow
        Write-Host "  |  6.  Full Network Stack Reset (Winsock + TCP/IP)    |" -ForegroundColor Red
        Write-Host "  |  7.  Restart Active Network Adapter                 |" -ForegroundColor Red
        Write-Host "  |  B.  Back                                           |" -ForegroundColor DarkGray
        Write-Host "  +-----------------------------------------------------+" -ForegroundColor DarkGreen
        Write-Host ""

        $choice = (Read-Host "  Select option").Trim().ToUpper()
        switch ($choice) {
            "1" { Invoke-NetworkAudit }
            "2" { Test-DNSResolutionLatency }
            "3" { Test-PingPacketLoss }
            "4" { Invoke-SafeFlushDNS }
            "5" { Invoke-SafeRenewIP }
            "6" { Invoke-SafeNetworkStackReset }
            "7" { Invoke-SafeAdapterRestart }
            "B" { return }
            default { Write-Warn "Invalid choice." ; Start-Sleep 1 }
        }
    }
}

function Invoke-NetworkAudit {
    Clear-Host
    Write-Section "NETWORK HEALTH AUDIT"
    Write-Host "  Probing network interfaces, IP configuration, gateway and internet..." -ForegroundColor DarkGray
    Write-Host ""

    Write-NFSLog "Running Network Doctor health audit..." -Target "diagnostics"
    $chk = [char]0x2713

    # 1. Active Adapter
    $activeAdapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1
    if ($activeAdapter) {
        Write-Host "  [$chk] Adapter       : $($activeAdapter.Name) ($($activeAdapter.InterfaceDescription)) - $($activeAdapter.LinkSpeed)" -ForegroundColor Green
    } else {
        Write-Host "  [!] Adapter       : No active network adapter found (Status: Down)" -ForegroundColor Red
    }

    # 2. IP Configuration
    $ipConfig = Get-NetIPAddress -InterfaceIndex ($activeAdapter.InterfaceIndex) -AddressFamily IPv4 -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($ipConfig) {
        Write-Host "  [$chk] IPv4 Address  : $($ipConfig.IPAddress) / $($ipConfig.PrefixLength)" -ForegroundColor Green
    } else {
        Write-Host "  [!] IPv4 Address  : None assigned" -ForegroundColor Yellow
    }

    # 3. Default Gateway
    $gateway = (Get-NetRoute -DestinationPrefix "0.0.0.0/0" -InterfaceIndex ($activeAdapter.InterfaceIndex) -ErrorAction SilentlyContinue | Select-Object -First 1).NextHop
    if ($gateway) {
        $gwPing = Test-Connection -ComputerName $gateway -Count 1 -Quiet -ErrorAction SilentlyContinue
        if ($gwPing) {
            Write-Host "  [$chk] Gateway       : $gateway (Reachable)" -ForegroundColor Green
        } else {
            Write-Host "  [!] Gateway       : $gateway (Unreachable/No Ping)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  [!] Gateway       : No default gateway detected" -ForegroundColor Red
    }

    # 4. DNS Servers
    $dnsServers = (Get-DnsClientServerAddress -InterfaceIndex ($activeAdapter.InterfaceIndex) -AddressFamily IPv4 -ErrorAction SilentlyContinue).ServerAddresses
    if ($dnsServers -and $dnsServers.Count -gt 0) {
        Write-Host "  [$chk] DNS Servers   : $($dnsServers -join ', ')" -ForegroundColor Green
    } else {
        Write-Host "  [!] DNS Servers   : Not configured" -ForegroundColor Yellow
    }

    # 5. Public DNS Resolution
    $dnsTestOk = $false
    try {
        $resolve = [System.Net.Dns]::GetHostAddresses("cloudflare.com")
        if ($resolve -and $resolve.Count -gt 0) {
            $dnsTestOk = $true
            Write-Host "  [$chk] DNS Resolver  : Working (Resolved cloudflare.com -> $($resolve[0].IPAddressToString))" -ForegroundColor Green
        }
    } catch {
        Write-Host "  [!] DNS Resolver  : Failed to resolve external host" -ForegroundColor Red
    }

    # 6. Internet Connectivity
    $netAvailable = [System.Net.NetworkInformation.NetworkInterface]::GetIsNetworkAvailable()
    if ($netAvailable -and $dnsTestOk) {
        Write-Host "  [$chk] Internet      : Connected & Operational" -ForegroundColor Green
    } else {
        Write-Host "  [!] Internet      : Limited or No Connectivity" -ForegroundColor Red
    }

    Write-Host ""
    Pause-Menu
}

function Test-DNSResolutionLatency {
    Clear-Host
    Write-Section "DNS RESOLUTION & LATENCY TEST"
    Write-Host "  Resolving top worldwide domains and measuring response time..." -ForegroundColor DarkGray
    Write-Host ""

    $targets = @("google.com", "microsoft.com", "github.com", "cloudflare.com", "aws.amazon.com")

    Write-Host ("  {0,-20} {1,-18} {2,12}" -f "TARGET HOST", "RESOLVED IP", "TIME (MS)") -ForegroundColor DarkYellow
    Write-HR "-" 56

    foreach ($t in $targets) {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        try {
            $ips = [System.Net.Dns]::GetHostAddresses($t)
            $sw.Stop()
            $firstIp = $ips[0].IPAddressToString
            $color = if ($sw.ElapsedMilliseconds -lt 60) { "Green" } elseif ($sw.ElapsedMilliseconds -lt 200) { "Yellow" } else { "Red" }
            Write-Host ("  {0,-20} {1,-18} " -f $t, $firstIp) -NoNewline -ForegroundColor White
            Write-Host ("{0,12} ms" -f $sw.ElapsedMilliseconds) -ForegroundColor $color
        } catch {
            $sw.Stop()
            Write-Host ("  {0,-20} {1,-18} {2,12}" -f $t, "FAILED", "ERR") -ForegroundColor Red
        }
    }
    Write-HR "-" 56
    Pause-Menu
}

function Test-PingPacketLoss {
    Clear-Host
    Write-Section "PING & PACKET LOSS TEST"
    Write-Host "  Sending 4 ICMP packets to 1.1.1.1 (Cloudflare) and 8.8.8.8 (Google)..." -ForegroundColor DarkGray
    Write-Host ""

    foreach ($hostIp in @("1.1.1.1", "8.8.8.8")) {
        Write-Host "  Pinging $hostIp..." -ForegroundColor Cyan
        try {
            $pings = Test-Connection -ComputerName $hostIp -Count 4 -ErrorAction Stop
            $avgTime = [Math]::Round(($pings | Measure-Object -Property ResponseTime -Average).Average, 1)
            $lossCount = 4 - $pings.Count
            Write-Host "  Results for $hostIp : Received $($pings.Count)/4, Avg Latency: $avgTime ms, Loss: $lossCount" -ForegroundColor (if ($lossCount -eq 0) { "Green" } else { "Yellow" })
        } catch {
            Write-Host "  Ping to $hostIp failed or timed out." -ForegroundColor Red
        }
        Write-Host ""
    }
    Pause-Menu
}

function Invoke-SafeFlushDNS {
    Clear-Host
    Write-Section "FLUSH DNS RESOLVER CACHE"
    Write-Step "Executing ipconfig /flushdns..."
    ipconfig /flushdns
    Write-Success "DNS cache successfully purged."
    Write-NFSLog "DNS Cache flushed." -Target "diagnostics"
    Pause-Menu
}

function Invoke-SafeRenewIP {
    Clear-Host
    Write-Section "RENEW DHCP LEASE"
    Write-Warn "This will temporarily disconnect your network while obtaining a new DHCP lease."
    Write-Host ""
    $confirm = (Read-Host "  Proceed with IP release and renew? [Y/N]").Trim().ToUpper()
    if ($confirm -eq "Y") {
        Write-Step "Releasing current IP configuration..."
        ipconfig /release | Out-Null
        Start-Sleep 1
        Write-Step "Renewing IP lease from DHCP server..."
        ipconfig /renew | Out-Null
        Write-Success "IP configuration renewed."
        Write-NFSLog "IP address released and renewed via DHCP." -Target "diagnostics"
    } else {
        Write-Info "Operation cancelled."
    }
    Pause-Menu
}

function Invoke-SafeNetworkStackReset {
    Clear-Host
    Write-Section "FULL NETWORK STACK RESET"
    if (-not (Assert-Admin)) { Pause-Menu; return }

    Write-Warn "CAUTION: This operation will:"
    Write-Host "   - Reset Winsock catalog to default clean state" -ForegroundColor Yellow
    Write-Host "   - Reset TCP/IP stack configuration" -ForegroundColor Yellow
    Write-Host "   - Release and flush all DNS and IP bindings" -ForegroundColor Yellow
    Write-Host "   - A system restart is RECOMMENDED after completion" -ForegroundColor Yellow
    Write-Host ""

    $confirm = (Read-Host "  Are you sure you want to perform a full Network Stack Reset? [Y/N]").Trim().ToUpper()
    if ($confirm -eq "Y") {
        Write-Step "Resetting Winsock..."
        netsh winsock reset | Out-Null
        Write-Step "Resetting TCP/IP stack..."
        netsh int ip reset | Out-Null
        Write-Step "Flushing DNS and releasing IP..."
        ipconfig /flushdns | Out-Null
        ipconfig /release | Out-Null
        Start-Sleep 1
        ipconfig /renew | Out-Null
        Write-Success "Network stack successfully reset."
        Write-NFSLog "Performed full network stack reset (Winsock + TCP/IP)." -Target "diagnostics" -Level "WARN"
        Write-Host ""
        Write-Host "  Would you like to restart your computer now? [Y/N]" -ForegroundColor Yellow
        $rst = (Read-Host "  >").Trim().ToUpper()
        if ($rst -eq "Y") {
            Restart-Computer -Force
        }
    } else {
        Write-Info "Network reset cancelled."
    }
    Pause-Menu
}

function Invoke-SafeAdapterRestart {
    Clear-Host
    Write-Section "RESTART NETWORK ADAPTER"
    if (-not (Assert-Admin)) { Pause-Menu; return }

    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    if (-not $adapters) {
        Write-Warn "No active network adapters found."
        Pause-Menu
        return
    }

    Write-Host "  Active Adapters:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $adapters.Count; $i++) {
        Write-Host "  [$($i+1)] $($adapters[$i].Name) ($($adapters[$i].InterfaceDescription))" -ForegroundColor White
    }
    Write-Host "  [B] Cancel" -ForegroundColor DarkGray
    Write-Host ""

    $choice = (Read-Host "  Select adapter to restart").Trim().ToUpper()
    if ($choice -eq "B") { return }

    if ([int]::TryParse($choice, [ref]$idx) -and $idx -ge 1 -and $idx -le $adapters.Count) {
        $selected = $adapters[$idx - 1]
        Write-Warn "This will briefly disconnect $($selected.Name)."
        $confirm = (Read-Host "  Restart $($selected.Name)? [Y/N]").Trim().ToUpper()
        if ($confirm -eq "Y") {
            try {
                Write-Step "Disabling $($selected.Name)..."
                Disable-NetAdapter -Name $selected.Name -Confirm:$false
                Start-Sleep 2
                Write-Step "Re-enabling $($selected.Name)..."
                Enable-NetAdapter -Name $selected.Name -Confirm:$false
                Write-Success "$($selected.Name) restarted successfully."
                Write-NFSLog "Restarted network adapter $($selected.Name)." -Target "diagnostics"
            } catch {
                Write-Err "Failed to restart adapter: $($_.Exception.Message)"
            }
        }
    } else {
        Write-Warn "Invalid selection."
    }
    Pause-Menu
}
