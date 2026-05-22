Network Troubleshooting Instructions for GitHub Copilot

When the user reports a network error or asks for help debugging connectivity issues, follow this systematic approach:

## Step 1: Classify the Error

Match the error to a category:
- ECONNREFUSED / Connection refused → Port/Service issue
- ECONNRESET / Connection reset → Firewall/Middleware issue
- ETIMEDOUT / Timeout → Routing/Network issue
- ENOTFOUND / ERR_NAME_NOT_RESOLVED → DNS issue
- Proxy connection failed → Proxy configuration
- SSL/TLS certificate errors → Certificate issue
- HTTP 403/407/502/503/504 → HTTP/Server issue

## Step 2: Suggest Diagnostic Commands

For connectivity issues, suggest:
```bash
ping <host>
curl -v telnet://<host>:<port>
nc -zv <host> <port>
```

For DNS issues:
```bash
nslookup <host>
nslookup <host> 8.8.8.8
```

For proxy issues:
```bash
echo $HTTP_PROXY $HTTPS_PROXY
curl -x http://127.0.0.1:7890 https://www.google.com
```

For SSL issues:
```bash
openssl s_client -connect <host>:443 -showcerts
curl -vvv https://<host>
```

## Step 3: Apply Resolution

Common fixes:
- npm timeout: `npm config set registry https://registry.npmmirror.com`
- git fails: `git config --global http.proxy http://127.0.0.1:7890`
- DNS failure: Switch to 8.8.8.8, flush DNS cache
- SSL error: Check cert chain, update CA bundle
- Proxy not running: Start Clash/V2Ray

## Step 4: Verify

Re-run the failed command after applying the fix.
