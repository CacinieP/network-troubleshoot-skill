# Network Troubleshooting Steering Rule

When network errors are detected in commands or code, follow this systematic diagnostic workflow.

## Triggers

- Error messages containing: ECONNREFUSED, ECONNRESET, ETIMEDOUT, ENOTFOUND, timeout, connection refused, connection reset, SSL, certificate, proxy, DNS
- HTTP status codes: 403, 407, 502, 503, 504
- Failing commands: npm install, pip install, git push/pull, docker pull, curl, wget
- User mentions: network, connect, timeout, DNS, proxy, VPN, offline

## Classification

| Pattern | Category | Primary Check |
|---|---|---|
| ECONNREFUSED, Connection refused | Connectivity | Service running? Port correct? |
| ECONNRESET, Connection reset | Firewall | Firewall rules, proxy middleware |
| ETIMEDOUT, Timeout | Routing | Network reachable? |
| ENOTFOUND, getaddrinfo ENOTFOUND | DNS | DNS server responding? |
| proxy connection failed | Proxy | Proxy running? Config correct? |
| CERT_HAS_EXPIRED, UNABLE_TO_VERIFY_LEAF_SIGNATURE | SSL/TLS | Certificate valid? |
| HTTP 403, 407, 502, 503, 504 | HTTP/Server | Server-side or auth issue |

## Diagnostic Commands

1. **Connectivity**: `ping <host>`, `nc -zv <host> <port>`, `curl -v telnet://<host>:<port>`
2. **DNS**: `nslookup <host>`, `nslookup <host> 8.8.8.8`, `dig <host>`
3. **Proxy**: `echo $HTTP_PROXY $HTTPS_PROXY`, `curl -x http://127.0.0.1:7890 https://www.google.com`
4. **SSL**: `openssl s_client -connect <host>:443 -showcerts </dev/null`
5. **HTTP**: `curl -vvv -o /dev/null -w "%{http_code}" https://<host>/<path>`
6. **Package Managers**: `npm config list`, `pip config list`, `git config --list | grep proxy`

## Resolution Matrix

| Finding | Fix |
|---|---|
| No internet at all | Check cable/WiFi, restart router |
| DNS fails, 8.8.8.8 works | Change DNS to 8.8.8.8, flush cache |
| Proxy port not listening | Start Clash/V2Ray/SSR |
| Proxy works but target blocked | Switch proxy node/protocol |
| SSL cert expired | Renew cert; dev: `NODE_TLS_REJECT_UNAUTHORIZED=0` |
| SSL self-signed | Import CA to trust store |
| HTTP 407 | Set proxy credentials |
| HTTP 502/503/504 | Server issue, retry later |
| npm timeout | `npm config set registry https://registry.npmmirror.com` |
| pip timeout | `pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple` |
| git fails | `git config --global http.proxy http://127.0.0.1:7890` |
| docker pull fails | Add mirror to `/etc/docker/daemon.json` |

## Verification

Always re-run the originally failing command after applying a fix.
