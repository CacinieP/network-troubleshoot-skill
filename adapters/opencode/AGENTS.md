# Network Troubleshooting

When network errors occur in commands or code, apply systematic diagnosis.

## Error Classification

| Error | Category | Check |
|---|---|---|
| ECONNREFUSED, Connection refused | Connectivity | Service running? Port correct? |
| ECONNRESET, Connection reset | Firewall | Firewall rules, proxy middleware |
| ETIMEDOUT, Timeout | Routing | Network reachable? |
| ENOTFOUND, getaddrinfo ENOTFOUND | DNS | DNS server responding? |
| proxy connection failed | Proxy | Proxy running? Config correct? |
| CERT_HAS_EXPIRED, UNABLE_TO_VERIFY_LEAF_SIGNATURE | SSL/TLS | Certificate valid? |
| HTTP 403, 407, 502, 503, 504 | HTTP/Server | Server-side or auth issue |

## Diagnostic Flow

### Step 1: Classify
Match the error to a category above.

### Step 2: Run Diagnostics

**Connectivity**: `ping <host>`, `nc -zv <host> <port>`, `curl -v telnet://<host>:<port>`
**DNS**: `nslookup <host>`, `nslookup <host> 8.8.8.8`, `dig <host>`
**Proxy**: `echo $HTTP_PROXY $HTTPS_PROXY`, `curl -x http://127.0.0.1:7890 https://www.google.com`
**SSL**: `openssl s_client -connect <host>:443 -showcerts </dev/null`
**HTTP**: `curl -vvv -o /dev/null -w "%{http_code}" https://<host>/<path>`
**Package Managers**: `npm config list`, `pip config list`, `git config --list | grep proxy`

### Step 3: Apply Fix

| Finding | Fix |
|---|---|
| No internet | Check cable/WiFi, restart router |
| DNS fails, 8.8.8.8 works | Change DNS, flush cache |
| Proxy port not listening | Start Clash/V2Ray/SSR |
| Proxy works, target blocked | Switch proxy node |
| SSL cert expired | Renew cert; dev: `NODE_TLS_REJECT_UNAUTHORIZED=0` |
| SSL self-signed | Import CA to trust store |
| HTTP 407 | Set proxy credentials |
| HTTP 502/503/504 | Server issue, retry |
| npm timeout | `npm config set registry https://registry.npmmirror.com` |
| pip timeout | `pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple` |
| git fails | `git config --global http.proxy http://127.0.0.1:7890` |
| docker pull fails | Add mirror to daemon.json |

### Step 4: Verify
Re-run the failing command to confirm the fix works.

## China Developer Quick Setup

```bash
export HTTP_PROXY=http://127.0.0.1:7890
export HTTPS_PROXY=http://127.0.0.1:7890
export ALL_PROXY=socks5://127.0.0.1:7891
npm config set registry https://registry.npmmirror.com
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
git config --global http.proxy http://127.0.0.1:7890
```
