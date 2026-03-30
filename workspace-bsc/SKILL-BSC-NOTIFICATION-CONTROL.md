# SKILL-BSC-NOTIFICATION-CONTROL.md — Blossom School Catering: Daily Notification Control

Use this skill whenever the authorized operator asks Brian to pause, resume, or check the status of the daily order notification job.

## Trigger Phrases
- "pause daily notification"
- "resume daily notification"
- "daily notification status"
- "turn off daily notification"
- "turn on daily notification"

## Control File

Use this exact file:

`/home/azlan/.openclaw/workspace-bsc/daily_notification_control.json`

Expected JSON shape:

```json
{
  "dailyOrderNotifications": "ACTIVE",
  "updatedAt": "2026-03-27T15:00:00+08:00",
  "updatedBy": "Brian"
}
```

Allowed values:
- `ACTIVE`
- `PAUSED`

## Commands

### Pause
If the authorized operator asks to pause daily notification:

1. Write the control file with:
```json
{
  "dailyOrderNotifications": "PAUSED",
  "updatedAt": "{current ISO timestamp}",
  "updatedBy": "Brian"
}
```
2. Reply exactly:
`Brian ♾️ Daily notification paused.`

### Resume
If the authorized operator asks to resume daily notification:

1. Write the control file with:
```json
{
  "dailyOrderNotifications": "ACTIVE",
  "updatedAt": "{current ISO timestamp}",
  "updatedBy": "Brian"
}
```
2. Reply exactly:
`Brian ♾️ Daily notification resumed.`

### Status
If the authorized operator asks for daily notification status:

1. Read the control file.
2. If state is `PAUSED`, reply exactly:
`Brian ♾️ Daily notification is paused.`
3. Otherwise reply exactly:
`Brian ♾️ Daily notification is active.`

## Execution Notes

- Use local file operations or shell commands on `aserver`; do not ask for confirmation.
- If the control file is missing, treat it as `ACTIVE`.
- Do not discuss internal file paths unless explicitly asked.
