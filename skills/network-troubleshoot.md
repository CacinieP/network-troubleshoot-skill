---
name: network-troubleshoot
description: Systematic network troubleshooting for developers. Diagnoses connectivity, DNS, proxy, SSL/TLS, HTTP, firewall, and package manager issues with automated diagnostic commands and resolution steps. Includes proxy layer mismatch detection for multi-process apps (Electron+Go, Docker Desktop, VS Code+extensions).
triggers:
  - network
  - connect
  - DNS
  - proxy
  - timeout
  - ECONNREFUSED
  - ECONNRESET
  - ETIMEDOUT
  - SSL
  - TLS
  - certificate
  - firewall
  - CORS
  - ping
  - curl
  - 网络问题
  - 连不上
  - 无法访问
  - 代理
  - 超时
  - mismatch
  - layer
  - TUN
  - gRPC
  - 语言服务器
  - context deadline exceeded
---

# Network Troubleshoot Skill

You are a network diagnostics expert. When invoked, systematically diagnose and resolve network issues using the workflow below.

## Step 1: Collect Symptom Information

Ask the user or infer from error output:

- **Error message**: exact text (e.g., `ECONNREFUSED`, `ETIMEDOUT`, `ERR_NAME_NOT_RESOLVED`)
- **Target**: what host/port/URL is failing
- **Context**: what command triggered it (npm install, git push, curl, browser, app)
- **Scope**: everything or just specific hosts
- **Timing**: sudden failure or never worked
- **Environment**: OS, network type (home/office/VPN), proxy usage

If the user provides an error, extract these automatically without asking.

## Step 2: Classify the Issue

Match against these categories by error pattern:

| Pattern | Category |
|---------|----------|
| `ECONNREFUSED`, `Connection refused`, `ERR_CONNECTION_REFUSED` | Connectivity / Port |
| `ECONNRESET`, `Connection reset`, `socket hang up` | Connectivity / Firewall |
| `ETIMEDOUT`, `timed out`, `ERR_CONNECTION_TIMED_OUT` | Timeout / Routing |
| `ENOTFOUND`, `ERR_NAME_NOT_RESOLVED`, `getaddrinfo`, `EAI_NONAME` | DNS |
| `ERR_PROXY_CONNECTION_FAILED`, `ECONNREFUSED 127.0.0.1:7890` | Proxy |
| `UNABLE_TO_VERIFY_LEAF_SIGNATURE`, `CERT_HAS_EXPIRED`, `self signed` | SSL/TLS |
| `ERR_OSSL_EVP_UNSUPPORTED` | SSL / OpenSSL version mismatch |
| `HPE_INVALID_CONSTANT` | HTTP parse error (often proxy HTML response) |
| `HTTP 403`, `HTTP 407`, `HTTP 502/503/504` | HTTP / Proxy |
| `EACCES`, `EPERM` | Firewall / Permissions |
| `npm ERR! network`, `pip install` timeout | Package Manager |
| `fatal: unable to access`, `git fetch/push` failed | Git / Network |

## Step 3: Run Diagnostics

First detect the OS, then pick the right commands. Run multiple in parallel when possible.

```bash
# Detect OS
uname -s                    # "Linux", "Darwin" (macOS), or "MINGW"* / "MSYS"* (Windows Git Bash)
echo %OS%                   # Windows CMD: "Windows_NT"
```

> **Windows Git Bash limitations**: `nc`, `dig`, `traceroute` are not available. Use `curl`, `nslookup`, `tracert`, `Test-NetConnection` instead.

### 3A: Connectivity Diagnostics

```bash
# Basic connectivity
ping -c 4 <host>          # Linux/macOS
ping -n 4 <host>          # Windows

# Port check (cross-platform — use this instead of nc)
curl -v telnet://<host>:<port> --connect-timeout 5

# Alternative port check
nc -zv <host> <port>                            # Linux/macOS only
powershell.exe -Command "Test-NetConnection -ComputerName <host> -Port <port>"  # Windows

# Gateway check
ip route                   # Linux
route print                # Windows
netstat -rn                # macOS
```

### 3B: DNS Diagnostics

```bash
# DNS resolution (cross-platform)
nslookup <host>

# Additional DNS tools
dig <host>                 # Linux/macOS only
Resolve-DnsName <host>     # Windows PowerShell only

# DNS with specific server (cross-platform)
nslookup <host> 8.8.8.8
dig @8.8.8.8 <host>          # Linux/macOS only

# Check hosts file
cat /etc/hosts             # Linux/macOS/Git Bash
cat /c/Windows/System32/drivers/etc/hosts   # Git Bash on Windows
type C:\Windows\System32\drivers\etc\hosts  # Windows CMD

# DNS cache
ipconfig /displaydns       # Windows
sudo systemd-resolve --statistics  # Linux systemd
```

### 3C: Proxy Diagnostics

```bash
# Check proxy environment variables
echo $HTTP_PROXY $HTTPS_PROXY $ALL_PROXY $NO_PROXY   # Linux/macOS/Git Bash
echo %HTTP_PROXY% %HTTPS_PROXY%                       # Windows CMD
powershell.exe -Command "echo $env:HTTP_PROXY $env:HTTPS_PROXY"  # from Git Bash to PS

# Check if proxy port is listening (cross-platform)
curl -v http://127.0.0.1:7890 --connect-timeout 2
# Common proxy ports: 7890 (Clash HTTP), 7891 (Clash SOCKS), 1080 (SOCKS), 8080, 10809 (V2Ray)

# Test through proxy
curl -x http://127.0.0.1:7890 -v https://www.google.com --connect-timeout 5

# Check proxy config files
cat ~/.curlrc                               # curl proxy
git config --global --get http.proxy        # git proxy
npm config get proxy                        # npm proxy
pip config get global.proxy                 # pip proxy

# Windows system proxy
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer

# User-level env vars (persist across reboots — this is what child processes inherit)
powershell -Command "[System.Environment]::GetEnvironmentVariable('HTTP_PROXY', 'User')"
powershell -Command "[System.Environment]::GetEnvironmentVariable('HTTPS_PROXY', 'User')"
```

### 3H: Proxy Layer Mismatch Detection (Application-Level Proxy Audit)

When one part of an application works (e.g., login/UI) but another fails (e.g., API calls/backend), the root cause may be **different proxy layers within the same application**. This is especially common in multi-process apps (Electron + Go/Rust backend, Docker Desktop, VS Code + extensions).

**Proxy layers and their coverage:**

| Layer | Mechanism | Covers | Misses |
|-------|-----------|--------|--------|
| System proxy (IE/WinINET) | Registry `HKCU\...\Internet Settings` | Chromium, .NET, Edge, IE | Go/Rust binaries, Python stdlib (unless env vars), Node.js (unless env vars) |
| Environment variables | `HTTP_PROXY`/`HTTPS_PROXY`/`ALL_PROXY` | curl, wget, Go net/http, Python urllib/requests | Electron child processes (may not inherit), gRPC clients, apps ignoring env vars |
| Electron `--proxy-server` | Chromium flag | Electron renderer, webview | Spawned child processes (language_server.exe, etc.) |
| TUN mode (virtual NIC) | OS-level routing via virtual adapter | **ALL** applications, **ALL** protocols | Nothing — universal solution |

**Diagnostic commands for layer mismatch:**

```bash
# Step 1: Verify system proxy is set (Windows)
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer

# Step 2: Check user-level env vars (these persist across sessions)
powershell -Command "[System.Environment]::GetEnvironmentVariable('HTTP_PROXY', 'User')"
powershell -Command "[System.Environment]::GetEnvironmentVariable('HTTPS_PROXY', 'User')"

# Step 3: Check process-level env vars (current session only)
echo $HTTP_PROXY $HTTPS_PROXY

# Step 4: Test connectivity per layer
curl -sS --noproxy "*" --connect-timeout 5 https://blocked-site.com     # Direct (no proxy)
curl -sS --proxy http://127.0.0.1:<port> --connect-timeout 5 https://blocked-site.com  # Via proxy

# Step 5: Check if proxy port is actually listening
netstat -ano | grep "<port>" | grep LISTENING

# Step 6: Identify Electron child processes (if applicable)
powershell -Command "Get-WmiObject Win32_Process -Filter \"Name='language_server.exe'\" | Select CommandLine"
# Note: Cannot read another process's env block on Windows
```

**Error patterns indicating proxy layer mismatch:**

| Error Pattern | Meaning | Likely Layer Issue |
|---------------|---------|--------------------|
| `dial tcp [IPv6]:443: connectex: A connection attempt failed` | Direct connection blocked (GFW/firewall) | No proxy at all for this component |
| `Post "https://...": context deadline exceeded` | HTTP/gRPC timeout | HTTP/gRPC not going through proxy |
| `EOF` on HTTPS connections | Connection dropped mid-TLS | Proxy interference or TLS layer issue |
| App login works but features/API fail | Selective connectivity | System proxy works for Chromium, env vars missing for backend |
| Auth succeeded but model listing fails | OAuth token obtained, API blocked | OAuth uses system proxy, API calls need env vars |

**Resolution strategies (ordered by effectiveness):**

1. **Enable TUN mode** (universal, best solution):
   In your proxy app (Karing/Clash Verge/Surge), enable TUN mode. This creates a virtual NIC that routes ALL traffic at the IP layer, regardless of application proxy support. Requires admin privileges. After enabling, restart the affected application.

2. **Set user-level environment variables** (partial solution):
   ```powershell
   [System.Environment]::SetEnvironmentVariable('HTTP_PROXY', 'http://127.0.0.1:<port>', 'User')
   [System.Environment]::SetEnvironmentVariable('HTTPS_PROXY', 'http://127.0.0.1:<port>', 'User')
   [System.Environment]::SetEnvironmentVariable('ALL_PROXY', 'socks5://127.0.0.1:<port>', 'User')
   [System.Environment]::SetEnvironmentVariable('NO_PROXY', 'localhost,127.0.0.1', 'User')
   ```
   Then **restart the application** (not just refresh — full close and reopen). Limitation: env vars only work for apps that read them; they do NOT help gRPC or apps that hardcode connections.

3. **Launch app with proxy wrapper** (partial, per-app solution):
   Create a VBS/bat launcher that sets env vars before launching the target app. This ensures the process tree inherits proxy settings from the start:
   ```vbs
   Set WshShell = CreateObject("WScript.Shell")
   WshShell.Environment("Process").Item("HTTP_PROXY") = "http://127.0.0.1:<port>"
   WshShell.Environment("Process").Item("HTTPS_PROXY") = "http://127.0.0.1:<port>"
   WshShell.Run "app.exe --proxy-server=http://127.0.0.1:<port>"
   ```
   Limitation: Only works for HTTP calls from Go net/http etc.; gRPC still bypasses.

### 3D: SSL/TLS Diagnostics

```bash
# Certificate chain check (openssl works on all platforms)
openssl s_client -connect <host>:443 -showcerts </dev/null

# Certificate expiry
echo | openssl s_client -connect <host>:443 2>/dev/null | openssl x509 -noout -dates

# Full SSL debug (cross-platform)
curl -vvv https://<host> 2>&1 | grep -E "SSL|TLS|certificate|issuer|subject|error"

# Windows certificate store
certutil -store Root | grep -i "<issuer>"
```

### 3E: HTTP Diagnostics

```bash
# Full request debug
curl -vvv -o /dev/null -w "HTTP/%{http_version} %{http_code}\nTime: %{time_total}s\nDNS: %{time_namelookup}s\nConnect: %{time_connect}s\nTLS: %{time_appconnect}s\n" https://<host>/<path>

# Headers only
curl -I https://<host>/<path>

# Follow redirects with detail
curl -L -vvv https://<host>/<path>

# POST with data
curl -X POST -H "Content-Type: application/json" -d '<body>' -vvv https://<host>/<path>
```

### 3F: Performance / Route Diagnostics

```bash
# Traceroute
traceroute <host>          # Linux/macOS
tracert -d <host>          # Windows

# Path analysis (Windows only)
pathping <host>

# MTR (Linux/macOS only, if installed)
mtr -rwzbc 50 <host>

# Latency test
ping -c 20 <host> | tail -1   # Linux/macOS
ping -n 20 <host> 2>&1 | tail -3  # Windows (output is localized, tail grabs summary)
```

### 3G: Package Manager Specific

```bash
# npm
npm config list
npm ping
npm cache ls 2>/dev/null | head -5
npm install --verbose <package> 2>&1 | head -50

# pip
pip config list
pip install --verbose <package>
pip install --index-url https://pypi.tuna.tsinghua.edu.cn/simple <package>  # China mirror

# Docker
docker info 2>&1 | grep -i "registry\|proxy\|mirror"
cat /etc/docker/daemon.json 2>/dev/null
docker pull hello-world

# Git
git config --list | grep -i proxy
GIT_CURL_VERBOSE=1 git ls-remote https://github.com/user/repo.git 2>&1 | head -30

# China mirrors
npm config set registry https://registry.npmmirror.com
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
```

## Step 4: Analyze and Resolve

### Resolution Matrix

| Diagnosis | Root Cause | Resolution |
|-----------|-----------|------------|
| Ping fails for all hosts | No internet | Check cable/WiFi, restart router, `ipconfig /release && ipconfig /renew` |
| Ping fails for one host | Host down / blocked | Try alternative host, check if host is up via `downforeveryoneorjustme.com` |
| DNS resolves wrong IP | DNS poisoning / hosts file | Check `/etc/hosts`, try `nslookup <host> 8.8.8.8`, flush DNS cache |
| DNS fails entirely | DNS server down | Switch to `8.8.8.8` or `1.1.1.1`, check `/etc/resolv.conf` |
| Proxy port not listening | Proxy app not running | Start Clash/V2Ray/SSR, check auto-start config |
| Proxy works but target blocked | GFW / network policy | Use different proxy node, try different protocol |
| App login works but features fail | Proxy layer mismatch | Set env vars, enable TUN mode, or use proxy wrapper launcher |
| `dial tcp [IPv6]:443: connectex: failed` | Direct connection blocked | Enable TUN mode (universal) or set HTTP_PROXY env vars |
| `context deadline exceeded` on HTTPS | HTTP/gRPC bypassing proxy | Enable TUN mode (covers gRPC); env vars only cover HTTP |
| SSL cert expired | Server misconfiguration | Contact server admin, temporary: `NODE_TLS_REJECT_UNAUTHORIZED=0` (dev only!) |
| SSL self-signed | Internal CA | Add CA to trust store: `npm config set strict-ssl false` or import cert |
| HTTP 407 | Proxy auth required | Configure proxy credentials in env or tool config |
| HTTP 403 | IP blocked / auth required | Check API key, verify IP whitelist, try different network |
| HTTP 502/503/504 | Server/CDN issue | Check server status page, retry with exponential backoff |
| Timeout at specific hop | Routing issue / firewall | Try VPN/different route, report to ISP |
| npm install fails | Registry access / proxy | Set registry mirror, configure npm proxy |

### China-Specific Resolutions

For users behind GFW (Great Firewall of China):

1. **Proxy setup**: Ensure Clash/V2Ray is running and proxy env vars are set
   ```bash
   export HTTP_PROXY=http://127.0.0.1:7890
   export HTTPS_PROXY=http://127.0.0.1:7890
   export ALL_PROXY=socks5://127.0.0.1:7891
   ```

2. **npm registry**: `npm config set registry https://registry.npmmirror.com`

3. **pip mirror**: `pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple`
   If SSL trust errors occur: `pip config set global.trusted-host pypi.tuna.tsinghua.edu.cn`

4. **Docker mirror**: Configure mirror in `/etc/docker/daemon.json`
   ```json
   {"registry-mirrors": ["https://mirror.ccs.tencentyun.com"]}
   ```

5. **Git proxy**: `git config --global http.proxy http://127.0.0.1:7890`

6. **Gradle/Maven**: Configure proxy in `~/.gradle/gradle.properties` or `~/.m2/settings.xml`

## Step 5: Verify Fix

After applying resolution:

```bash
# Re-run the failed command
# Verify connectivity
curl -I https://<previously-failing-host>

# Verify DNS
nslookup <host>

# Verify proxy
curl -x http://127.0.0.1:7890 https://www.google.com -o /dev/null -w "%{http_code}"
```

## Error Message Quick Reference

### Node.js Errors
- `ECONNREFUSED`: Target not listening on that port. Check if service is running.
- `ECONNRESET`: Connection dropped. Often firewall or idle timeout.
- `ETIMEDOUT`: No response. Network unreachable, firewall block, or DNS failure.
- `ENOTFOUND`: DNS resolution failed. Check DNS config and hostname.
- `EPIPE`: Writing to closed connection. Remote side closed.
- `EAI_AGAIN`: Temporary DNS failure. Retry or check DNS server.

### Browser Errors
- `ERR_NAME_NOT_RESOLVED`: DNS failure
- `ERR_CONNECTION_REFUSED`: Port not open
- `ERR_CONNECTION_TIMED_OUT`: Routing/firewall issue
- `ERR_SSL_PROTOCOL_ERROR`: TLS handshake failure
- `ERR_CERT_AUTHORITY_INVALID`: Unknown CA
- `ERR_CERT_DATE_INVALID`: Expired certificate
- `ERR_PROXY_CONNECTION_FAILED`: Proxy not running or wrong config
- `ERR_TUNNEL_CONNECTION_FAILED`: HTTPS through proxy failed

### Common Tools
- `npm ERR! code ECONNREFUSED` -> npm can't reach registry
- `npm ERR! code ETARGET` -> package not found (check name/version)
- `fatal: unable to access 'https://github.com/...'` -> git network issue
- `ssh: connect to host ... port 22: Connection refused` -> SSH not available
- `docker: Cannot connect to the Docker daemon` -> Docker not running
- `EAI_NONAME` -> DNS resolution failed (similar to ENOTFOUND)
- `ERR_OSSL_EVP_UNSUPPORTED` -> OpenSSL version mismatch — upgrade Node.js or use `--openssl-legacy-provider`
- `HPE_INVALID_CONSTANT` -> HTTP parse error — often proxy returning HTML error page instead of expected response

## Workflow Summary

```
1. [Collect] Get error message + context + target host
2. [Classify] Match error pattern to category
3. [Diagnose] Run diagnostic commands for that category
4. [Analyze] Interpret diagnostic output
5. [Resolve] Apply fix from resolution matrix
6. [Verify] Re-run failed operation to confirm
```

Always explain what each diagnostic command does and what the output means. Present findings clearly before suggesting fixes.
