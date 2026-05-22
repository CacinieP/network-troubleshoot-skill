# Network Troubleshooting

Universal adapter — works with any AI coding agent that reads markdown instructions.

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
pip config list
docker info 2>&1 | grep -i "registry\|proxy"
git config --list | grep -i proxy
```

## Resolution Matrix

| Diagnosis | Resolution |
|---|---|
| No internet (all hosts fail) | Check cable/WiFi, restart router, `ipconfig /renew` |
| DNS fails with default server | Switch to 8.8.8.8 or 1.1.1.1, flush DNS cache |
| DNS fails with all servers | Check /etc/resolv.conf, network interface |
| Proxy port not listening | Start Clash/V2Ray, check auto-start |
| Proxy works but target blocked | Try different proxy node/protocol |
| SSL cert expired | Renew cert; dev only: `NODE_TLS_REJECT_UNAUTHORIZED=0` |
| SSL self-signed/unknown CA | Import CA to trust store |
| HTTP 407 Proxy Auth | Configure proxy credentials |
| HTTP 403 Forbidden | Check API key, IP whitelist, CORS |
| HTTP 502/503/504 | Server-side issue, retry with backoff |
| npm timeout | `npm config set registry https://registry.npmmirror.com` |
| pip timeout | `pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple` |
| pip SSL trust error | `pip config set global.trusted-host pypi.tuna.tsinghua.edu.cn` |
| git push fails | `git config --global http.proxy http://127.0.0.1:7890` |
| docker pull fails | Add mirror to `/etc/docker/daemon.json`: `{"registry-mirrors": ["https://mirror.ccs.tencentyun.com"]}` |
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
