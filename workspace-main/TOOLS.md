# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room -> Main area, 180 deg wide angle
- front-door -> Entrance, motion-triggered

### SSH

- home-server -> 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.

---

## Michael — GCS Reference

- GCS bucket available on `aserver`: `gs://gda_a1server_bucket`
- Michael folder reserved in GCS: `gs://gda_a1server_bucket/aiserver_michael/`
- Preferred upload method on `aserver`: metadata token + GCS JSON API, not `gsutil`
- This is infrastructure reference only; Michael should not treat WhatsApp `save to server` as an active default behavior.
