# OpenClaw BSC

Last updated: 2026-04-08

This repository hosts the Blossom School Catering OpenClaw setup for Brian and the internal Orders agent.

## Runtime
- Server path: `/opt/.openclaw-bsc`
- Server: `34.143.206.68`
- Active branch: `main`
- Default public agent: `brian`
- Internal execution agent: `bsc`

## Workspaces
- `workspace-brian`: public-facing Brian behavior, identity, and operator notes
- `workspace-bsc`: internal BSC execution skills and API instructions

## Current Family Support Model
- Brian family lookups now depend on schoolcatering server-side `family_id` scope.
- Brian should use:
  - `GET /admin/family-context?phone=PHONE`
  - `GET /admin/family-orders?phone=PHONE&date=YYYY-MM-DD`
- Do not infer family membership from surnames, `admin/parents`, `admin/children`, or dated orders.
- Primary parent, secondary parent phone, and youngster phone can all resolve into the same family.

## Schoolcatering Target
- API base: `http://34.158.47.112/schoolcatering/api/v1`
- Agent login:
  - username: `admin`
  - password: `Teameditor@123`

## Update Flow
```bash
cd /tmp/openclaw_bsc_main
git pull --ff-only origin main
git push origin main

ssh 34.143.206.68
cd /opt/.openclaw-bsc
git pull --ff-only origin main
```

## Important Notes
- Brian is the public responder.
- Orders (`bsc`) is internal only and should stay invisible to end users.
- Keep branch naming on `main`.
- Runtime state directories remain local-only and should not be committed.
