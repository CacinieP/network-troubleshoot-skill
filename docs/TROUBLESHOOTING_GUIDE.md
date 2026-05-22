# Network Troubleshooting Reference Guide

Complete reference for diagnosing and resolving network issues in development environments.

## Table of Contents

1. [Diagnostic Commands](#diagnostic-commands)
2. [Error Pattern Catalog](#error-pattern-catalog)
3. [Resolution Playbooks](#resolution-playbooks)
4. [Platform-Specific Guides](#platform-specific-guides)
5. [Tool-Specific Configuration](#tool-specific-configuration)

---

## Diagnostic Commands

### Quick Health Check

```bash
# Internet connectivity
ping -c 1 8.8.8.8              # Can we reach the internet at all?
ping -c 1 google.com           # Does DNS + routing work?
curl -I https://httpbin.org/status/200  # Does HTTPS work?

# Local network
ip addr show                    # Linux: What's our IP?
ipconfig /all                   # Windows: Full network config
ifconfig                        # macOS: Network interfaces

# Default gateway
ip route show default           # Linux
route -n get default            # macOS
route print 0.*                 # Windows
```

### DNS Debugging

```bash
# Step 1: Check if DNS resolves
nslookup example.com
dig example.com

# Step 2: Try alternative DNS server
nslookup example.com 8.8.8.8
dig @1.1.1.1 example.com

# Step 3: Check local hosts file
cat /etc/hosts | grep -v "^#" | grep -v "^$"

# Step 4: Flush DNS cache
sudo systemd-resolve --flush-caches    # Linux (systemd)
sudo dscacheutil -flushcache           # macOS
ipconfig /flushdns                     # Windows

# Step 5: Check DNS config
cat /etc/resolv.conf                   # Linux
scutil --dns                           # macOS
ipconfig /all | findstr "DNS"          # Windows
```

### Port and Connectivity

```bash
# TCP port check
nc -zv host port 2>&1                # Linux/macOS
Test-NetConnection host -Port port    # Windows PS
curl -v telnet://host:port            # Universal

# Listening ports (what's running locally)
ss -tlnp                              # Linux
lsof -i -P -n | grep LISTEN          # macOS
netstat -ano | findstr LISTENING      # Windows

# Established connections
ss -tnp | grep :port                  # Linux
netstat -ano | findstr :port          # Windows
```

### SSL/TLS Debugging

```bash
# Check certificate chain
openssl s_client -connect host:443 -showcerts </dev/null 2>&1 | \
  openssl x509 -noout -subject -issuer -dates

# Check full TLS handshake
openssl s_client -connect host:443 -tls1_2 </dev/null

# Verify certificate against CA bundle
openssl verify -CAfile /etc/ssl/certs/ca-certificates.crt cert.pem

# Check TLS version support
nmap --script ssl-enum-ciphers -p 443 host  # if nmap available
```

### Route and Performance

```bash
# Traceroute
traceroute -n host                    # Linux/macOS (no DNS lookup)
tracert -d host                       # Windows

# Packet loss test
ping -c 100 host | grep "packet loss"
mtr -rwzbc 100 host                   # Continuous traceroute

# Bandwidth test (if iperf3 available)
iperf3 -c speedtest.server -p 5201

# DNS resolution timing
dig +stats example.com | grep "Query time"
```

---

## Error Pattern Catalog

### Node.js / JavaScript

| Error | Meaning | Common Cause |
|-------|---------|--------------|
| `ECONNREFUSED` | Connection actively rejected | Service not running, wrong port, firewall |
| `ECONNRESET` | Connection forcibly closed | Server crash, firewall reset, keepalive timeout |
| `ETIMEDOUT` | Connection attempt timed out | Network unreachable, firewall drop, routing loop |
| `ENOTFOUND` | DNS lookup failed | Typo in hostname, DNS server down, DNS hijacking |
| `EPIPE` | Write to broken pipe | Remote closed connection before write completed |
| `EAI_AGAIN` | Temporary DNS failure | DNS server overloaded, network flapping |
| `EAI_NONAME` | Permanent DNS failure | Hostname does not exist |
| `HPE_INVALID_CONSTANT` | HTTP parse error | Proxy returning non-HTTP response |
| `UNABLE_TO_VERIFY_LEAF_SIGNATURE` | SSL cert chain incomplete | Missing intermediate CA |
| `CERT_HAS_EXPIRED` | Certificate expired | Server cert past validity date |
| `ERR_OSSL_EVP_UNSUPPORTED` | Crypto algorithm mismatch | Node.js 17+ OpenSSL 3.0 incompatibility |

### HTTP Status Codes (Network-Relevant)

| Code | Meaning | Network Implication |
|------|---------|---------------------|
| 403 | Forbidden | IP blocked, auth required, CORS |
| 407 | Proxy Auth Required | Corporate proxy needs credentials |
| 408 | Request Timeout | Server gave up waiting |
| 429 | Too Many Requests | Rate limiting (not a network issue) |
| 502 | Bad Gateway | Upstream server unreachable |
| 503 | Service Unavailable | Server overloaded or maintaining |
| 504 | Gateway Timeout | Upstream server too slow |

### curl Exit Codes

| Code | Meaning |
|------|---------|
| 6 | Could not resolve host |
| 7 | Failed to connect to host |
| 28 | Operation timeout |
| 35 | SSL connect error |
| 51 | SSL certificate problem |
| 52 | Empty reply from server |
| 56 | Failure in receiving network data |

---

## Resolution Playbooks

### Playbook 1: "No Internet"

```
1. ping 8.8.8.8
   FAIL --> Physical connection issue
   │        Check cable, WiFi toggle, network adapter
   │        ipconfig /renew (Windows) / dhclient (Linux)
   │
   SUCCESS --> DNS issue
            nslookup google.com
            FAIL --> Change DNS to 8.8.8.8
                     Check /etc/resolv.conf
                     Flush DNS cache
            SUCCESS --> Proxy/firewall issue
                     Check proxy settings
                     Try without proxy
```

### Playbook 2: "npm install Fails"

```
1. npm ping
   FAIL --> npm registry unreachable
   │        Check: npm config get registry
   │        Try: npm config set registry https://registry.npmmirror.com
   │        Check proxy: npm config get proxy
   │
   SUCCESS --> Package-specific issue
            Check package name and version
            Clear cache: npm cache clean --force
            Delete node_modules and package-lock.json, retry
```

### Playbook 3: "Git Push/Pull Fails"

```
1. git ls-remote https://github.com/user/repo.git
   FAIL with "unable to access"
   │        Check: git config --global http.proxy
   │        Try: git config --global --unset http.proxy
   │        Or: git config --global http.proxy http://127.0.0.1:7890
   │
   FAIL with "SSL certificate problem"
   │        Try: GIT_SSL_NO_VERIFY=1 git ls-remote ...
   │        Fix: Update CA certificates
   │              Windows: Update git for Windows
   │              Linux: sudo update-ca-certificates
```

### Playbook 4: "Docker Pull Fails"

```
1. docker pull hello-world
   FAIL --> Docker daemon or registry issue
   │        Check: systemctl status docker (Linux)
   │        Check: docker info | grep -i mirror
   │        Configure mirror in /etc/docker/daemon.json
   │        China mirror: https://mirror.ccs.tencentyun.com
   │
   SUCCESS --> Image-specific issue
            Check image name and tag
            Try: docker pull --platform linux/amd64 image
```

### Playbook 5: "SSL/TLS Certificate Error"

```
1. openssl s_client -connect host:443 </dev/null
   "verify error" --> Certificate chain issue
   │        Check: Is it a self-signed cert?
   │        Check: Is intermediate CA missing?
   │        Check: Is system clock correct? (expired certs)
   │
   "no peer certificate" --> TLS version mismatch
   │        Try: openssl s_client -connect host:443 -tls1_2
   │        Check server TLS configuration

   Quick fixes (dev only):
   - Node.js: NODE_TLS_REJECT_UNAUTHORIZED=0
   - npm: npm config set strict-ssl false
   - git: git config --global http.sslVerify false
   - Python: export PYTHONHTTPSVERIFY=0
```

---

## Platform-Specific Guides

### Windows

```powershell
# Full network reset
netsh winsock reset
netsh int ip reset
ipconfig /flushdns
# Then reboot

# Check firewall rules
netsh advfirewall firewall show rule name=all dir=out | findstr "Block"

# Test specific port
Test-NetConnection -ComputerName google.com -Port 443 -InformationLevel Detailed

# Check proxy (system)
Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"

# Network adapter reset
Disable-NetAdapter -Name "Wi-Fi" -Confirm:$false
Enable-NetAdapter -Name "Wi-Fi"
```

### Linux

```bash
# Network manager restart
sudo systemctl restart NetworkManager
# or
sudo systemctl restart networking

# Firewall check
sudo iptables -L -n | grep DROP
sudo ufw status

# DNS resolver restart
sudo systemctl restart systemd-resolved

# Network interface reset
sudo ip link set eth0 down && sudo ip link set eth0 up
sudo dhclient eth0
```

### macOS

```bash
# Network interface reset
sudo ifconfig en0 down && sudo ifconfig en0 up

# DNS cache flush
sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder

# Network setup list
networksetup -listallnetworkservices
networksetup -getinfo Wi-Fi

# Proxy settings
networksetup -getwebproxy Wi-Fi
networksetup -getsecurewebproxy Wi-Fi
```

---

## Tool-Specific Configuration

### npm

```bash
# Registry mirror (China)
npm config set registry https://registry.npmmirror.com

# Proxy
npm config set proxy http://127.0.0.1:7890
npm config set https-proxy http://127.0.0.1:7890

# SSL
npm config set strict-ssl false  # Dev only!

# Cache
npm cache clean --force

# Debug
npm install --loglevel verbose
```

### pip

```bash
# Mirror (China)
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
pip config set global.trusted-host pypi.tuna.tsinghua.edu.cn

# Proxy
pip config set global.proxy http://127.0.0.1:7890

# SSL
pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org package
```

### Git

```bash
# Proxy
git config --global http.proxy http://127.0.0.1:7890
git config --global https.proxy http://127.0.0.1:7890

# Remove proxy
git config --global --unset http.proxy
git config --global --unset https.proxy

# SSL
git config --global http.sslVerify false  # Dev only!
git config --global http.sslCAInfo /path/to/ca.crt

# Debug
GIT_CURL_VERBOSE=1 GIT_TRACE=1 git ls-remote
```

### Docker

```json
// /etc/docker/daemon.json
{
  "registry-mirrors": [
    "https://mirror.ccs.tencentyun.com",
    "https://docker.mirrors.ustc.edu.cn"
  ],
  "proxies": {
    "http-proxy": "http://127.0.0.1:7890",
    "https-proxy": "http://127.0.0.1:7890"
  }
}
```

### Gradle

```properties
# ~/.gradle/gradle.properties
systemProp.http.proxyHost=127.0.0.1
systemProp.http.proxyPort=7890
systemProp.https.proxyHost=127.0.0.1
systemProp.https.proxyPort=7890
```

### Maven

```xml
<!-- ~/.m2/settings.xml -->
<settings>
  <proxies>
    <proxy>
      <id>clash</id>
      <active>true</active>
      <protocol>http</protocol>
      <host>127.0.0.1</host>
      <port>7890</port>
    </proxy>
  </proxies>
  <mirrors>
    <mirror>
      <id>aliyun</id>
      <mirrorOf>*</mirrorOf>
      <url>https://maven.aliyun.com/repository/public</url>
    </mirror>
  </mirrors>
</settings>
```
