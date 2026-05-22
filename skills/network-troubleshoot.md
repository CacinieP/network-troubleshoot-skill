---
name: network-troubleshoot
description: Systematic network troubleshooting for developers. Diagnoses connectivity, DNS, proxy, SSL/TLS, HTTP, firewall, and package manager issues with automated diagnostic commands and resolution steps.
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
| `ENOTFOUND`, `ERR_NAME_NOT_RESOLVED`, `getaddrinfo` | DNS |
| `ERR_PROXY_CONNECTION_FAILED`, `ECONNREFUSED 127.0.0.1:7890` | Proxy |
| `UNABLE_TO_VERIFY_LEAF_SIGNATURE`, `CERT_HAS_EXPIRED`, `self signed` | SSL/TLS |
| `HTTP 403`, `HTTP 407`, `HTTP 502/503/504` | HTTP / Proxy |
| `EACCES`, `EPERM` | Firewall / Permissions |
| `npm ERR! network`, `pip install` timeout | Package Manager |
| `fatal: unable to access`, `git fetch/push` failed | Git / Network |

## Step 3: Run Diagnostics

Execute diagnostic commands based on classification. Run multiple in parallel when possible.

### 3A: Connectivity Diagnostics

```bash
# Basic connectivity
ping -c 4 <host>          # Linux/macOS
ping -n 4 <host>          # Windows

# Port check
curl -v telnet://<host>:<port> --connect-timeout 5
# or
nc -zv <host> <port>      # Linux/macOS
Test-NetConnection -ComputerName <host> -Port <port>  # Windows PowerShell

# Gateway check
ip route                   # Linux
route print                # Windows
netstat -rn                # macOS
```

### 3B: DNS Diagnostics

```bash
# DNS resolution
nslookup <host>
dig <host>                 # Linux/macOS
Resolve-DnsName <host>     # Windows PowerShell

# DNS with specific server
nslookup <host> 8.8.8.8
dig @8.8.8.8 <host>

# Check hosts file
cat /etc/hosts             # Linux/macOS
type C:\Windows\System32\drivers\etc\hosts  # Windows

# DNS cache
ipconfig /displaydns       # Windows
sudo systemd-resolve --statistics  # Linux systemd
```

### 3C: Proxy Diagnostics

```bash
# Check proxy environment variables
echo $HTTP_PROXY $HTTPS_PROXY $ALL_PROXY $NO_PROXY   # Linux/macOS
echo %HTTP_PROXY% %HTTPS_PROXY%                       # Windows CMD
$env:HTTP_PROXY; $env:HTTPS_PROXY                     # Windows PS

# Check if proxy port is listening
curl -v http://127.0.0.1:7890 --connect-timeout 2
# Common proxy ports: 7890 (Clash), 1080 (SOCKS), 8080, 10809 (V2Ray)

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
```

### 3D: SSL/TLS Diagnostics

```bash
# Certificate chain check
openssl s_client -connect <host>:443 -showcerts </dev/null

# Certificate expiry
echo | openssl s_client -connect <host>:443 2>/dev/null | openssl x509 -noout -dates

# Full SSL debug
curl -vvv https://<host> 2>&1 | grep -E "SSL|TLS|certificate|issuer|subject"

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

# Path analysis (Windows)
pathping <host>

# MTR (if available)
mtr -rwzbc 50 <host>

# Latency test
ping -c 20 <host> | tail -1   # Linux/macOS
ping -n 20 <host> | findstr "Average"  # Windows
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
