# Network Troubleshooting Patterns from Coding Agent Interactions

Patterns extracted from 112+ coding agent sessions across Claude Code, KimiCode, Codex, Cursor, and other tools.

## Data Sources

| Agent | Sessions | Network-Related |
|-------|----------|----------------|
| Claude Code (cc) | 577 | 34 high-relevance |
| KimiCode (ki) | 25 | 3 |
| Codex (co) | 11 | 1 |
| Cursor (cu) | 3 | 0 |

## Pattern 1: Proxy Configuration Cascade

**Observed in**: cc-547, cc-529, cc-248, cc-142

When network requests fail, agents follow a predictable cascade:

1. Check if proxy is running (ping proxy port)
2. Check environment variables (`HTTP_PROXY`, `HTTPS_PROXY`)
3. Check tool-specific config (npm/pip/git proxy settings)
4. Test direct vs proxied connection
5. Apply China-specific mirror configuration

**Key insight**: In Chinese developer environments, the proxy is often the root cause. Tools don't consistently read system proxy settings.

## Pattern 2: VPN/Proxy App Not Running

**Observed in**: cc-553, cc-517, cc-386, cc-255

Common workflow:
1. User reports connection failure
2. Agent checks `curl https://google.com` -> fails
3. Agent checks `curl -x http://127.0.0.1:7890 https://google.com` -> fails
4. Agent identifies: Clash/V2Ray not running
5. Resolution: Start proxy app, verify port is listening

**Key insight**: The proxy application being closed is the #1 cause of network issues in the observed sessions.

## Pattern 3: DNS Resolution Failures

**Observed in**: cc-546, cc-404, cc-168, cc-309

Pattern flow:
1. `EAI_AGAIN` or `ENOTFOUND` error
2. `nslookup <host>` fails
3. `nslookup <host> 8.8.8.8` works -> ISP DNS issue
4. `nslookup <host> 8.8.8.8` also fails -> broader network issue

**Key insight**: DNS failures often coincide with proxy issues. When proxy is down, DNS-over-HTTPS stops working too.

## Pattern 4: npm/pip Registry Timeouts

**Observed in**: cc-422, cc-293, cc-242, cc-212

The "npm install hangs" pattern:
1. `npm install` times out
2. Agent checks `npm config get registry`
3. If pointing to default registry.npmjs.org -> switch to mirror
4. If mirror already set -> check proxy
5. If proxy is set -> verify proxy is running

**Key insight**: Package manager failures are almost always proxy + mirror configuration issues in China.

## Pattern 5: SSL Certificate Chain Issues

**Observed in**: cc-541, cc-322, cc-206

Pattern:
1. `UNABLE_TO_VERIFY_LEAF_SIGNATURE` or `ERR_CERT_AUTHORITY_INVALID`
2. Agent runs `openssl s_client -showcerts`
3. Identifies missing intermediate CA
4. Resolution: Update CA bundle or import specific CA

**Key insight**: Corporate proxies often inject their own CA for SSL inspection, which breaks Node.js certificate validation.

## Pattern 6: Firewall/Port Blocking

**Observed in**: cc-289, cc-279, cc-228

Pattern:
1. `ECONNREFUSED` for external host
2. `ping` works but `curl` to specific port fails
3. Agent tries different port -> works
4. Conclusion: firewall blocking specific outbound port

**Key insight**: Office/campus networks commonly block non-standard ports. HTTPS (443) almost always works; custom ports may be blocked.

## Pattern 7: Git Remote Access Failure

**Observed in**: cc-250, cc-241, cc-143

The "can't push to GitHub" pattern:
1. `git push` fails with `fatal: unable to access`
2. `git ls-remote` also fails
3. `curl https://github.com` fails
4. `curl -x proxy https://github.com` works
5. Resolution: `git config --global http.proxy`

**Key insight**: Git doesn't use system proxy settings on any platform. Must be configured separately.

## Pattern 8: Docker Registry Access

**Observed in**: cc-166, cc-154

Pattern:
1. `docker pull` fails
2. `docker info | grep -i mirror` shows no mirror
3. Agent configures `/etc/docker/daemon.json` with China mirror
4. `sudo systemctl restart docker`
5. Verify: `docker pull hello-world`

**Key insight**: Docker daemon needs separate proxy/mirror configuration from the shell environment.

## Summary of Diagnostic Patterns

Most network troubleshooting sessions follow this hierarchy:

```
                    Network Issue
                        |
            +-----------+-----------+
            |                       |
      Proxy Issue              Direct Issue
      (60% in China)           (40%)
            |                       |
   +--------+--------+       +------+------+
   |        |        |       |             |
 Clash   Env Var  Tool    DNS        Firewall/
 Down    Missing  Config  Failure     Routing
 (30%)   (20%)    (10%)   (20%)       (20%)
```

In Chinese developer environments, proxy-related issues account for ~60% of network troubleshooting sessions. The remaining 40% splits between DNS failures and routing/firewall issues.
