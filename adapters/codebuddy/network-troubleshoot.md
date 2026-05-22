---
name: network-troubleshoot
description: 网络故障诊断与修复规则，当检测到网络错误时自动触发系统化诊断流程
type: rule
---

# Network Troubleshooting Rule

When network errors occur, follow this structured diagnostic workflow.

## Triggers

- Errors: ECONNREFUSED, ECONNRESET, ETIMEDOUT, ENOTFOUND, timeout, connection refused, connection reset, SSL, certificate, proxy, DNS
- HTTP status: 403, 407, 502, 503, 504
- Failing commands: npm install, pip install, git push/pull, docker pull, curl, wget
- Keywords: network, connect, timeout, DNS, proxy, VPN, offline

## Classification

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

## Diagnostic Commands

Pick based on classification:

**Connectivity**: `ping <host>`, `curl -v telnet://<host>:<port>`, `nc -zv <host> <port>`
**DNS**: `nslookup <host>`, `nslookup <host> 8.8.8.8`, `dig <host>`
**Proxy**: `echo $HTTP_PROXY $HTTPS_PROXY`, `curl -x http://127.0.0.1:7890 https://www.google.com`
**SSL**: `openssl s_client -connect <host>:443 -showcerts </dev/null`
**HTTP**: `curl -vvv -o /dev/null -w "%{http_code}" https://<host>/<path>`
**Package Managers**: `npm config list`, `pip config list`, `git config --list | grep proxy`

## Resolution Matrix

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

## Verify

Re-run the originally failing command after applying a fix.
