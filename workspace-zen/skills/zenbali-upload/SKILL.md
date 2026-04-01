---
name: zenbali-upload
description: "Upload a Zenbali event from a WhatsApp image. Use when asked to post, upload, or create a Zenbali event from an image. Extracts event details from the image and posts via API."
---

# Zenbali Event Upload Skill

## CRITICAL: How to Upload the Image

**You MUST use the `exec` tool to run curl. Do NOT use the `fetch` tool for image upload.**

The `fetch` tool cannot send files as multipart/form-data. Using it will always return `{"error":"File too large"}` from the server, regardless of image size.

### Step 1 — Get the local file path

The message context includes a line like:
```
[media attached: /home/azlan/.openclaw/media/inbound/abc123.jpg (image/jpeg)]
```
Copy that path exactly. That is your `<FILE_PATH>`.

### Step 2 — Upload with exec+curl

Call the **`exec` tool** with this command (replace `<FILE_PATH>`):

```
curl -s -X POST 'http://34.124.244.233/zenbali/api/agent/uploads/event-image' -H 'X-Agent-Token: 8c5e16225ea2dd0736766878529408f95ed6720337f154cb51e1228d3d1f006c' -F 'image=@<FILE_PATH>'
```

Example with real path:
```
curl -s -X POST 'http://34.124.244.233/zenbali/api/agent/uploads/event-image' -H 'X-Agent-Token: 8c5e16225ea2dd0736766878529408f95ed6720337f154cb51e1228d3d1f006c' -F 'image=@/home/azlan/.openclaw/media/inbound/abc123.jpg'
```

A successful upload returns HTTP 201:
```json
{"success":true,"data":{"image_url":"https://storage.googleapis.com/.../image.jpg"}}
```

Copy the `data.image_url` value — you will use it as `image_url` in the event payload.

### Step 3 — Post event with exec+curl

Build the JSON payload and post it:

```
curl -s -X POST 'http://34.124.244.233/zenbali/api/agent/events' -H 'Content-Type: application/json' -H 'X-Agent-Token: 8c5e16225ea2dd0736766878529408f95ed6720337f154cb51e1228d3d1f006c' -d '{"title":"Event Title","event_date":"2026-04-10","event_time":"09:00","location":"Ubud","event_type":"Wellness","duration_days":0,"duration_hours":1,"duration_minutes":0,"entrance_type":"Pay at Site","price_thousands":0,"participant_group_type":"Open","lead_by":"Guide","venue":"Ubud","contact_email":"azlan@net1io.com","contact_mobile":"+628176917122","event_description":"...","image_url":"https://storage.googleapis.com/.../image.jpg"}'
```

## Event Field Extraction

Extract these fields from the poster image:

| Field | Notes |
|-------|-------|
| `title` | Event name (mandatory) |
| `event_date` | First date shown, format YYYY-MM-DD |
| `event_time` | HH:MM in 15-min increments |
| `location` | City/region |
| `event_type` | e.g. Wellness, Workshop |
| `entrance_type` | Paid / Free / Pay at Site |
| `price_thousands` | Integer IDR/1000 (e.g. 150 = IDR 150,000) |
| `lead_by` | Facilitator name |
| `venue` | Specific place name |
| `event_description` | Subtitle, extra dates, links, social handles |

**FORBIDDEN: Do NOT use `e9`, `e10`, `e263` or any `eN` key names.**

## Defaults (apply only when field cannot be extracted)

- `event_time`: `09:00`
- `location`: `Ubud`
- `event_type`: `Wellness`
- `duration_days/hours/minutes`: `0/1/0`
- `entrance_type`: `Pay at Site`
- `participant_group_type`: `Open`
- `lead_by`: `Guide`
- `venue`: `Ubud`
- `contact_email`: `azlan@net1io.com`
- `contact_mobile`: `+628176917122`
- `price_thousands`: `0`

## Success Reply Format

```
Post Successfully
Event Title: <title>
Event Date: <event_date>
Event ID/UUID: <id>
```
