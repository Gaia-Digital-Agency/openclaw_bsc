# OpenClaw BSC — Brian

Last updated: 2026-04-21

This repository hosts the OpenClaw setup for **Brian**, the WhatsApp AI operator for Blossom School Catering.

## Runtime
- Server path: `/opt/.openclaw-bsc` on `gda-ai01` (34.143.206.68)
- Public WhatsApp agent: **Brian** (id: `main`)
- Internal execution agent: **Orders** (id: `orders`)
- Gateway: `systemctl --user status openclaw-bsc-gateway` (port `18789`)
- Public URL: `https://bsc.gaiada0.online`
- Gateway token: `bsc123abc`
- Active branch: `main`

## Workspaces
- `workspace-main/` — Brian's orchestrator files (IDENTITY, SOUL, AGENTS, USER, TOOLS, HEARTBEAT, MEMORY)
- `workspace-bsc/` — Orders' execution skills (SKILL-BSC-*.md for each workflow)

Orders receives delegations from Brian via `sessions_spawn`. Orders' text output is returned to Brian, who relays it as a single WhatsApp message. Orders does NOT call WhatsApp send tools directly.

## Skills (workspace-bsc)
- `SKILL-BSC-AUTHENTICATE.md` — resolves sender phone → family scope (first step for every BSC op, with one exception for registration YES/NO)
- `SKILL-BSC-ORDER.md` — place/book meal orders
- `SKILL-BSC-DELETE-ORDER.md` — cancel orders
- `SKILL-BSC-LOOKUP-PROTOCOL.md` — lookup students/grades/daily orders
- `SKILL-BSC-ACTIVE-MENU.md` — view menu
- `SKILL-BSC-ORDER-RECOMMENDATION.md` — recommendations
- `SKILL-BSC-NOTIFICATION-CONTROL.md` — morning reminder control
- `SKILL-BSC-REGISTER.md` — WhatsApp family registration (3-turn flow: invite → validate → confirm-and-submit)
- `SKILL-BSC-REGISTER-STATE.md` — state schema + read/write/expire protocol

## Schoolcatering Target
- API base: `https://schoolcatering.gaiada1.online/api/v1`
- Source: `gda-ce01:/var/www/schoolcatering`
- Admin login for Orders: `admin` / `Teameditor@123`
- Registration: `POST /auth/register/youngsters` (public, no auth)
- School list: `GET /auth/register/schools` (public)

## Important Operational Rules
- Skill file changes take effect immediately (files read per-request, no restart needed)
- State files at `/opt/.openclaw-bsc/memory/registration_{PHONE_DIGITS}.json` must be accessed via bash (`cat`, `ls`, `rm`) — MCP filesystem does NOT serve that path
- Orders must never call WhatsApp send tools — it has no sender context, only Brian does
- Platform sends ONE WhatsApp message per agent turn — compose multi-part replies as a single message with dividers

## Monitoring
```bash
# Recent gateway logs
ssh gda-ai01 "journalctl --user -u openclaw-bsc-gateway --since '5 min ago' --no-pager"

# Gateway health
ssh gda-ai01 "curl -s http://127.0.0.1:18789/__openclaw__/health"

# Recent task runs (subagent executions)
ssh gda-ai01 "python3 -c \"import sqlite3; c=sqlite3.connect('/opt/.openclaw-bsc/tasks/runs.sqlite'); [print(r) for r in c.execute('SELECT task_id,status,substr(progress_summary,1,200) FROM task_runs ORDER BY created_at DESC LIMIT 3')]\""
```

## Deployment Flow
```bash
ssh gda-ai01
cd /opt/.openclaw-bsc
git pull --ff-only origin main
# No restart needed — skills reload per-request
```

## Notes
- Runtime state directories (`memory/`, `tasks/`, `agents/*/sessions/`) remain local-only and are git-ignored.
- Primary model: `deepseek/deepseek-chat` with fallback `google/gemini-2.5-flash`.
- Brian only accepts behavior-change instructions from the superuser (`+6281138210188`).

## Operational Toggles

### Brian fully-silent maintenance mode
A single toggle that silences Brian without stopping the gateway, without touching WhatsApp credentials (no re-pair on reactivation), and without losing any in-flight state.

```bash
brian off       # save current state, apply silent settings, restart gateway if running
brian on        # restore from saved snapshot, restart gateway if running
brian status    # show current state
```

Run as user `azlan` (no sudo). Each toggle restarts the gateway when running (~25 s); when the gateway is stopped, the toggle just edits the config and the next start picks it up.

When OFF, three knobs change atomically:

| File | Field | ON | OFF |
|---|---|---|---|
| `openclaw.json` | `channels.whatsapp.accounts.main.allowFrom` | `["*"]` | `["+99999999999"]` |
| `openclaw.json` | `channels.whatsapp.accounts.main.groupPolicy` | `"open"` | `"disabled"` |
| `workspace-bsc/daily_notification_control.json` | `dailyOrderNotifications` | `"ACTIVE"` | `"PAUSED"` |

What this achieves while OFF:
- Gateway service runs normally, port 18789 listening, control UI usable.
- Brian's WhatsApp account stays online (provider connected, paired).
- Direct messages to Brian's number — received but filtered before agent processing, so no reply.
- Group chats containing Brian — ignored (`groupPolicy: disabled`).
- Daily order-notification job — paused (no scheduled outbound).
- Auto-restart timer continues to fire daily at 03:00 UTC; the OFF state survives the restart.

What is NOT touched (so reactivation is zero-cost):
- `credentials/whatsapp/main/` (4.6 MB session keys) — pairing preserved.
- `flows/`, `tasks/`, `agents/*/sessions/`, `memory/` — in-flight conversations preserved.
- Any other openclaw.json fields — only the two named fields above.

### Snapshot pattern (why ON restores cleanly)
On `brian off`, the *current* values of the three fields are captured into `/opt/.openclaw-bsc/.brian-toggle-saved.json` (gitignored runtime state). On `brian on`, those exact values are written back. This means any unrelated tweaks made to `openclaw.json` while Brian is OFF survive the toggle cycle — only the three managed fields are restored.

If the snapshot file is missing, `brian on` aborts with "already ON" — the live config is the source of truth.

### Source files
- Toggle script + installer: `scripts/ops/brian-toggle/`
- Install on a fresh server: `bash scripts/ops/brian-toggle/install.sh` (creates `/usr/local/bin/brian` symlink).

### Caveat — WhatsApp 14-day timeout
WhatsApp's Multi-Device protocol auto-unlinks any paired device that has not synced with WhatsApp servers for ~14 days. `brian off` does NOT pause the WhatsApp connection itself (the provider stays connected and processes inbound, just drops them post-filter), so this timeout is not relevant for typical maintenance windows. Only matters if you stop the gateway entirely for more than 14 days.
