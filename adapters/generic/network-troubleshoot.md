# Network Troubleshooting

Universal adapter — works with any AI coding agent that reads markdown instructions.
Condensed mirror of the primary skill (`skills/network-troubleshoot/SKILL.md`); when in doubt, follow the primary skill.

## Safety Boundaries

- **Read-only first.** Prefer diagnostics that do not change state. Use the failing host, URL, registry, or service as the default probe target; ask before probing unrelated external services.
- **Never print secrets.** Do not print proxy URLs, credentials, tokens, auth headers, package index URLs, registry hostnames, internal hosts, or raw config values from npm, pip, Git, Docker, shell, OS proxy, VPN, or certificate stores. Report only whether relevant settings appear present, without values.
- **Never bypass TLS on your own initiative.** Do not set `NODE_TLS_REJECT_UNAUTHORIZED=0`, `npm config set strict-ssl false`, `git config --global http.sslVerify false`, or `PYTHONHTTPSVERIFY=0` without explicit user approval. If a bypass seems necessary, present it as a last-resort, development-only option and wait for approval.
- **No unapproved state changes.** Do not change OS networking, DNS, proxy, package manager, Git, Docker, shell, VPN, or trust-store settings without explicit user approval for the exact action.
- **Explain before fixing.** Present findings clearly before suggesting fixes; remediation options are choices for the user, not automatic actions.

## Workflow

1. **Collect**: exact error message, failing command, target host/URL/port, OS/shell, proxy/VPN context, one target or many.
2. **Classify**: match the symptom to a category (table below).
3. **Diagnose**: read-only checks scoped to the failing target.
4. **Explain**: interpret the output before suggesting any fix.
5. **Advise**: present remediation options as choices; wait for user approval before changing state.
6. **Verify**: re-run the original failing command.

## Error Classification

| Error Pattern | Category |
|---|---|
| ECONNREFUSED, Connection refused | Connectivity / Port |
| ECONNRESET, Connection reset | Connectivity / Firewall |
| ETIMEDOUT, timed out | Timeout / Routing |
| ENOTFOUND, ERR_NAME_NOT_RESOLVED | DNS |
| EACCES, EPERM | Firewall / Permissions |
| ERR_PROXY_CONNECTION_FAILED, proxy connection refused | Proxy |
| UNABLE_TO_VERIFY_LEAF_SIGNATURE, CERT_HAS_EXPIRED | SSL/TLS |
| HTTP 403, 407, 502, 503, 504 | HTTP / Proxy |
| npm ERR! network, pip timeout | Package Manager |
| fatal: unable to access, git push failed | Git / Network |
| `dial tcp [IPv6]:443: connectex: A connection attempt failed`, `context deadline exceeded`, app login works but API/features fail | Proxy layer mismatch (see below) |

## Diagnostic Commands

> On Windows Git Bash: `nc`, `dig`, `traceroute` are unavailable. Use `curl`, `nslookup`, `tracert` instead.

### Connectivity
```bash
ping -c 4 <host>          # Linux/macOS
ping -n 4 <host>          # Windows
curl -v telnet://<host>:<port> --connect-timeout 5   # cross-platform port check
nc -zv <host> <port>      # Linux/macOS only
```

### DNS
```bash
nslookup <host>
nslookup <host> 8.8.8.8
dig <host>                 # Linux/macOS only
cat /etc/hosts | grep -v "^#"
cat /c/Windows/System32/drivers/etc/hosts    # Git Bash on Windows
ipconfig /flushdns         # Windows
```

### Proxy
```bash
echo $HTTP_PROXY $HTTPS_PROXY $ALL_PROXY $NO_PROXY
curl -v http://127.0.0.1:7890 --connect-timeout 2     # check proxy port
curl -x http://127.0.0.1:7890 https://www.google.com --connect-timeout 5
git config --global --get http.proxy
npm config get proxy
pip config get global.proxy
```

### SSL/TLS
```bash
openssl s_client -connect <host>:443 -showcerts </dev/null
echo | openssl s_client -connect <host>:443 2>/dev/null | openssl x509 -noout -dates
curl -vvv https://<host> 2>&1 | grep -E "SSL|TLS|certificate|error"
```

### HTTP
```bash
curl -vvv -o /dev/null -w "HTTP %{http_code}\nTime: %{time_total}s\nDNS: %{time_namelookup}s\nConnect: %{time_connect}s\nTLS: %{time_appconnect}s\n" https://<host>/<path>
curl -I https://<host>/<path>
```

### Performance
```bash
traceroute -n <host>       # Linux/macOS
tracert -d <host>          # Windows
pathping <host>            # Windows
mtr -rwzbc 50 <host>       # Linux/macOS, if installed
```

### Package Managers
```bash
npm config list && npm ping
npm cache verify           # check cache integrity (npm >= 5)
pip config list
docker info 2>&1 | grep -i "registry\|proxy"
git config --list | grep -i proxy
```

## Proxy Layer Mismatch (Pattern 9)

When one part of an application works (login/UI) but another fails (API/backend), the root cause is often **different proxy layers within the same application**. Common in multi-process apps (Electron + Go/Rust backend, Docker Desktop, VS Code + extensions).

| Layer | Mechanism | Covers | Misses |
|-------|-----------|--------|--------|
| System proxy (IE/WinINET) | Registry `Internet Settings` | Chromium, .NET, Edge | Go/Rust binaries, Python/Node without env vars |
| Environment variables | `HTTP_PROXY`/`HTTPS_PROXY`/`ALL_PROXY` | curl, Go net/http, Python, Node.js | Electron child processes, gRPC clients |
| Electron `--proxy-server` | Chromium flag | Electron renderer, webview | Spawned child processes |
| TUN mode (virtual NIC) | OS-level routing | **ALL** applications, **ALL** protocols | Nothing — universal solution |

**Error patterns indicating layer mismatch:**

| Error Pattern | Meaning | Likely Layer Issue |
|---------------|---------|--------------------|
| `dial tcp [IPv6]:443: connectex: A connection attempt failed` | Direct connection blocked (GFW/firewall) | No proxy at all for this component |
| `Post "https://...": context deadline exceeded` | HTTP/gRPC timeout | HTTP/gRPC not going through proxy |
| `EOF` on HTTPS connections | Connection dropped mid-TLS | Proxy interference or TLS layer issue |
| App login works but features/API fail | Selective connectivity | System proxy works for Chromium, env vars missing for backend |
| Auth succeeded but model listing fails | OAuth token obtained, API blocked | OAuth uses system proxy, API calls need env vars |

**Diagnostics:** check each layer in order — system proxy (Windows: `reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable`), user-level env vars (`powershell -Command "[System.Environment]::GetEnvironmentVariable('HTTP_PROXY', 'User')"`), proxy port listening (`netstat -ano | grep "<port>" | grep LISTENING`), then per-layer connectivity (`curl --noproxy "*" <url>` vs `curl --proxy http://127.0.0.1:<port> <url>`).

**Resolution (ordered by effectiveness):**

1. **Enable TUN mode** (universal, best): enable TUN in the proxy app (Karing/Clash Verge/Surge). Creates a virtual NIC that routes ALL traffic at the IP layer regardless of application proxy support. Requires admin privileges; restart the affected application after enabling.
2. **Set user-level environment variables** (partial): set `HTTP_PROXY`/`HTTPS_PROXY`/`ALL_PROXY`/`NO_PROXY` at user level, then fully close and reopen the app. Limitation: only works for apps that read env vars; does NOT help gRPC or apps that hardcode connections.
3. **Launch app with proxy wrapper** (partial, per-app): a VBS/bat launcher that sets env vars before launching the app. Limitation: gRPC still bypasses.

## Resolution Matrix

| Diagnosis | Resolution |
|---|---|
| No internet (all hosts fail) | Check cable/WiFi, restart router, `ipconfig /renew` |
| DNS fails with default server | Switch to 8.8.8.8 or 1.1.1.1, flush DNS cache |
| DNS fails with all servers | Check /etc/resolv.conf, network interface |
| Proxy port not listening | Start Clash/V2Ray, check auto-start |
| Proxy works but target blocked | Try different proxy node/protocol |
| App login works but features fail | Proxy layer mismatch — enable TUN mode, set user-level env vars, or use a proxy wrapper launcher (see above) |
| SSL cert expired | Renew cert; `NODE_TLS_REJECT_UNAUTHORIZED=0` only as dev-only last resort with explicit user approval |
| SSL self-signed/unknown CA | Import CA to trust store |
| HTTP 407 Proxy Auth | Configure proxy credentials (ask user for them) |
| HTTP 403 Forbidden | Check API key, IP whitelist, CORS |
| HTTP 502/503/504 | Server-side issue, retry with backoff |
| npm timeout | `npm config set registry https://registry.npmmirror.com` |
| pip timeout | `pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple` |
| pip SSL trust error | `pip config set global.trusted-host pypi.tuna.tsinghua.edu.cn` |
| git push fails | `git config --global http.proxy http://127.0.0.1:7890` |
| docker pull fails | Prefer proxy-based pulling: configure `proxies` in `/etc/docker/daemon.json` (`http-proxy`/`https-proxy`) or enable TUN mode. Public China registry mirrors were largely shut down or restricted to provider intranets in 2024; only use a mirror documented by your own cloud provider |
| Gradle/Maven fails | Configure proxy in `~/.gradle/gradle.properties` or `~/.m2/settings.xml` |

## China Developer Quick Setup

```bash
export HTTP_PROXY=http://127.0.0.1:7890
export HTTPS_PROXY=http://127.0.0.1:7890
export ALL_PROXY=socks5://127.0.0.1:7891
npm config set registry https://registry.npmmirror.com
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
pip config set global.trusted-host pypi.tuna.tsinghua.edu.cn
git config --global http.proxy http://127.0.0.1:7890
```

## Verification

After applying fix, re-run the failed command and verify:
```bash
curl -I https://<previously-failing-host>
nslookup <host>
curl -x http://127.0.0.1:7890 https://www.google.com -o /dev/null -w "%{http_code}"
```

## Error Quick Reference

- `ECONNREFUSED`: Target not listening on that port
- `ECONNRESET`: Connection dropped — firewall or idle timeout
- `ETIMEDOUT`: No response — network unreachable or firewall block
- `ENOTFOUND` / `EAI_NONAME`: DNS resolution failed
- `EPIPE`: Writing to closed connection
- `ERR_PROXY_CONNECTION_FAILED`: Proxy not running or wrong config
- `CERT_HAS_EXPIRED`: Server certificate expired
- `UNABLE_TO_VERIFY_LEAF_SIGNATURE`: Unknown CA in certificate chain
- `ERR_OSSL_EVP_UNSUPPORTED`: OpenSSL version mismatch — upgrade Node.js
- `HPE_INVALID_CONSTANT`: HTTP parse error — often proxy returning HTML error page
- `dial tcp [IPv6]:443: connectex: ...`: Direct connection blocked — proxy layer mismatch, enable TUN mode
