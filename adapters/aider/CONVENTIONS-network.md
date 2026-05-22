# Network Troubleshooting Conventions

When network errors occur in commands or code, apply systematic diagnosis.

## Error Classification

| Error | Category | Primary Check |
|---|---|---|
| ECONNREFUSED, Connection refused | Connectivity | Service running? Port correct? |
| ECONNRESET, Connection reset | Firewall | Firewall rules, proxy middleware |
| ETIMEDOUT, Timeout | Routing | Network reachable? Route exists? |
| ENOTFOUND, getaddrinfo ENOTFOUND | DNS | DNS server responding? |
| Proxy connection failed | Proxy | Proxy running? Config correct? |
| CERT_HAS_EXPIRED, UNABLE_TO_VERIFY_LEAF_SIGNATURE | SSL/TLS | Certificate chain valid? |
| HTTP 403, 407, 502, 503, 504 | HTTP/Server | Server-side issue or auth |

## Diagnostic Sequence

1. **Connectivity**: `ping <host>`, `nc -zv <host> <port>`, `curl -v telnet://<host>:<port>`
2. **DNS**: `nslookup <host>`, `nslookup <host> 8.8.8.8`
3. **Proxy**: `echo $HTTP_PROXY $HTTPS_PROXY`, `curl -x http://127.0.0.1:7890 https://www.google.com`
4. **SSL**: `openssl s_client -connect <host>:443 -showcerts </dev/null`
5. **HTTP**: `curl -vvv -o /dev/null -w "%{http_code}" https://<host>/<path>`

## Resolution Patterns

| Finding | Fix |
|---|---|
| No internet | Check cable/WiFi, restart router |
| DNS fails, 8.8.8.8 works | Change DNS to 8.8.8.8, flush cache |
| Proxy port not listening | Start Clash/V2Ray/SSR |
| Proxy works but target blocked | Switch proxy node |
| SSL cert expired | Renew cert; dev: `NODE_TLS_REJECT_UNAUTHORIZED=0` |
| SSL self-signed | Import CA to trust store |
| npm timeout | `npm config set registry https://registry.npmmirror.com` |
| pip timeout | `pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple` |
| git fails | `git config --global http.proxy http://127.0.0.1:7890` |
| docker pull fails | Add mirror to `/etc/docker/daemon.json` |

## Setup

Add to `.aider.conf.yml`:
```yaml
read:
  - CONVENTIONS-network.md
```

Always verify fixes by re-running the failing command.
