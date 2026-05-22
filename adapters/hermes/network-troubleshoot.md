# Network Troubleshooting Agent Instructions

When the user reports a network error or connectivity issue, follow this structured diagnostic workflow.

## Step 1: Collect Symptoms

Extract from error output or user input:
- **Error**: exact message (ECONNREFUSED, ETIMEDOUT, ENOTFOUND, CERT_HAS_EXPIRED, etc.)
- **Target**: host, port, URL that is failing
- **Trigger**: what command caused it (npm install, git push, curl, docker pull)
- **Scope**: all hosts or specific one
- **Env**: OS, proxy/VPN usage

## Step 2: Classify

| Pattern | Category |
|---|---|
| ECONNREFUSED, Connection refused | Connectivity |
| ECONNRESET, Connection reset | Firewall |
| ETIMEDOUT, timed out | Routing/Timeout |
| ENOTFOUND, getaddrinfo ENOTFOUND | DNS |
| proxy connection failed | Proxy |
| CERT_HAS_EXPIRED, UNABLE_TO_VERIFY_LEAF_SIGNATURE | SSL/TLS |
| HTTP 403, 407, 502, 503, 504 | HTTP/Server |
| npm ERR! network, pip install timeout | Package Manager |
| fatal: unable to access (git) | Git |

## Step 3: Run Diagnostics

Pick commands based on classification:

**Connectivity**: `ping <host>`, `curl -v telnet://<host>:<port>`, `nc -zv <host> <port>`
**DNS**: `nslookup <host>`, `nslookup <host> 8.8.8.8`, `dig <host>`
**Proxy**: `echo $HTTP_PROXY $HTTPS_PROXY`, `curl -x http://127.0.0.1:7890 https://www.google.com`
**SSL**: `openssl s_client -connect <host>:443 -showcerts </dev/null`
**HTTP**: `curl -vvv -o /dev/null -w "%{http_code}" https://<host>/<path>`
**Package Managers**: `npm config list`, `pip config list`, `git config --list | grep proxy`

## Step 4: Resolve

| Finding | Fix |
|---|---|
| No internet at all | Check cable/WiFi, restart router |
| DNS fails with default, works with 8.8.8.8 | Change DNS server, flush cache |
| Proxy port not listening | Start Clash/V2Ray/SSR |
| Proxy works but target blocked | Switch proxy node/protocol |
| SSL cert expired | Renew cert; dev: `NODE_TLS_REJECT_UNAUTHORIZED=0` |
| SSL self-signed | Import CA to trust store |
| HTTP 407 | Set proxy credentials |
| HTTP 502/503/504 | Server issue, retry |
| npm timeout | `npm config set registry https://registry.npmmirror.com` |
| pip timeout | `pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple` |
| git fails | `git config --global http.proxy http://127.0.0.1:7890` |
| docker pull fails | Add mirror to `/etc/docker/daemon.json` |

## Step 5: Verify

Re-run the originally failing command to confirm the fix works.
