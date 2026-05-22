---
alwaysApply: false
description: Network troubleshooting — systematic diagnosis and resolution for connectivity, DNS, proxy, SSL, HTTP errors
globs:
---

# Network Troubleshooting

When detecting network errors in commands or code, apply systematic diagnosis.

## Error Classification

- ECONNREFUSED / Connection refused → Service not running, wrong port, firewall rejecting
- ECONNRESET / Connection reset → Firewall reset, server crash, keepalive timeout
- ETIMEDOUT / Timeout → Network unreachable, firewall drop, DNS timeout
- ENOTFOUND / ERR_NAME_NOT_RESOLVED → DNS resolution failure
- Proxy connection failed → Proxy not running or misconfigured
- SSL/TLS certificate errors → Certificate chain, expiry, CA trust
- HTTP 403/407 → Auth or proxy credentials issue
- HTTP 502/503/504 → Server-side issue, retry

## Diagnostic Flow

### Step 1: Identify Category
Match the error message to a category above.

### Step 2: Run Diagnostics

**Connectivity**: `ping <host>`, `nc -zv <host> <port>`, `curl -v telnet://<host>:<port>`
**DNS**: `nslookup <host>`, `nslookup <host> 8.8.8.8`
**Proxy**: `echo $HTTP_PROXY $HTTPS_PROXY`, `curl -x http://127.0.0.1:7890 https://www.google.com`
**SSL**: `openssl s_client -connect <host>:443 -showcerts`
**HTTP**: `curl -vvv https://<host>`

### Step 3: Apply Fix

| Finding | Fix |
|---|---|
| No internet | Check cable/WiFi, restart router |
| DNS fails | Change DNS to 8.8.8.8, flush cache |
| Proxy down | Start Clash/V2Ray, verify port listening |
| npm timeout | `npm config set registry https://registry.npmmirror.com` |
| pip timeout | `pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple` |
| git fails | `git config --global http.proxy http://127.0.0.1:7890` |
| SSL cert error | Check cert chain, update CA bundle |
| docker pull fails | Add mirror to daemon.json |

### Step 4: Verify
Re-run the failing command to confirm the fix works.
