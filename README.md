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
