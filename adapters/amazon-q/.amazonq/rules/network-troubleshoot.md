# Network Troubleshooting

When network errors occur, apply systematic diagnosis.

## Error Classification

- ECONNREFUSED / Connection refused → Service not running, wrong port, firewall
- ECONNRESET / Connection reset → Firewall reset, server crash
- ETIMEDOUT / Timeout → Network unreachable, firewall drop
- ENOTFOUND / DNS resolution failure → DNS server issue
- Proxy connection failed → Proxy not running or misconfigured
- SSL/TLS errors → Certificate chain, expiry, CA trust
- HTTP 403/407 → Auth or proxy credentials
- HTTP 502/503/504 → Server-side issue

## Diagnostic Flow

1. Classify error by matching to category above
2. Run diagnostics:
   - Connectivity: `ping <host>`, `nc -zv <host> <port>`
   - DNS: `nslookup <host>`, `nslookup <host> 8.8.8.8`
   - Proxy: `echo $HTTP_PROXY $HTTPS_PROXY`, `curl -x http://127.0.0.1:7890 url`
   - SSL: `openssl s_client -connect <host>:443 -showcerts`
   - HTTP: `curl -vvv https://<host>`
3. Apply fix:
   - No internet → Check cable/WiFi, restart router
   - DNS fail → Change DNS to 8.8.8.8, flush cache
   - Proxy down → Start Clash/V2Ray, verify port
   - npm fail → `npm config set registry https://registry.npmmirror.com`
   - pip fail → `pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple`
   - git fail → `git config --global http.proxy http://127.0.0.1:7890`
   - SSL fail → Check cert chain, update CA bundle
   - docker fail → Configure daemon.json with mirror
4. Verify by re-running the failing command
