# Network Troubleshooting Instructions

When network errors are detected, follow this diagnostic workflow.

## Error Classification

| Error | Category |
|---|---|
| ECONNREFUSED, Connection refused | Connectivity |
| ECONNRESET, Connection reset | Firewall |
| ETIMEDOUT, Timeout | Routing |
| ENOTFOUND, getaddrinfo ENOTFOUND | DNS |
| proxy connection failed | Proxy |
| CERT_HAS_EXPIRED, UNABLE_TO_VERIFY_LEAF_SIGNATURE | SSL/TLS |
| HTTP 403, 407, 502, 503, 504 | HTTP/Server |

## Diagnostic Commands

**Connectivity**: `ping <host>`, `nc -zv <host> <port>`, `curl -v telnet://<host>:<port>`
**DNS**: `nslookup <host>`, `nslookup <host> 8.8.8.8`, `dig <host>`
**Proxy**: `echo $HTTP_PROXY $HTTPS_PROXY`, `curl -x http://127.0.0.1:7890 https://www.google.com`
**SSL**: `openssl s_client -connect <host>:443 -showcerts </dev/null`
**HTTP**: `curl -vvv -o /dev/null -w "%{http_code}" https://<host>/<path>`
**Package Managers**: `npm config list`, `pip config list`, `git config --list | grep proxy`

## Resolution Matrix

| Finding | Fix |
|---|---|
| No internet | Check cable/WiFi, restart router |
| DNS fails | Change DNS to 8.8.8.8, flush cache |
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

## Verify

Always re-run the failing command after applying a fix.
