# Zen Bali Agent API

Use the Zen Bali API for event posting. Do not use browser automation for this workflow.

## Base URL
- Public site: `https://zenbali.site/`
- API base: `https://zenbali.site/api`
- Image upload endpoint: `POST /agent/uploads/event-image`
- Event post endpoint: `POST /agent/events`

## Authentication
Send either header:
- `X-Agent-Token: 8c5e16225ea2dd0736766878529408f95ed6720337f154cb51e1228d3d1f006c`
- `Authorization: Bearer 8c5e16225ea2dd0736766878529408f95ed6720337f154cb51e1228d3d1f006c`

## Required Event Field Mapping
- `e9` -> `title`
- `e10` -> `event_date`
- `e11` -> `event_time`
- `e109` -> `location`
- `e136` -> `event_type`
- `e163` -> `duration_days`
- `e166` -> `duration_hours`
- `e191` -> `duration_minutes`
- `e196` -> `entrance_type`
- `e253` -> `participant_group_type`
- `e259` -> `lead_by`
- `e260` -> `venue`
- `e261` -> `contact_email`
- `e262` -> `contact_mobile`
- `e263` -> `event_description`
- `e267` -> `image_url`
- price from poster -> `price_thousands`

## Approved Defaults
Use these defaults when poster extraction and safe inference are exhausted:
- `duration_days`: `0`
- `duration_hours`: `1`
- `duration_minutes`: `0`
- `price_thousands`: `0`

## Price Rule
- `price_thousands` is the preferred price field.
- It must be an integer from `0` to `100000`.
- `1` means `IDR 1,000`.
- `150` means `IDR 150,000`.
- Zack may also send `entrance_fee = price_thousands * 1000` for backward compatibility.

## Rules
- Post via API, not the browser.
- `event_time` must be in 15-minute increments.
- `duration_minutes` must be in 15-minute increments.
- `location`, `event_type`, and `entrance_type` can be sent as names or numeric IDs.
- The API creates the event under `creator@zenbali.site` and publishes it immediately.
- If multiple dates appear, send the first date as `event_date` and put the remaining dates into `event_description`.
- If links or social media references are visible on the poster, include them in `event_description`.
- Build `event_description` from useful poster information not already captured by the structured fields.

## Workflow For WhatsApp Images
1. Receive the image on WhatsApp.
2. Extract event data for `e9` through `e263`.
3. Extract or infer the ticket price and convert it into `price_thousands`.
4. Infer only safe values.
5. Apply approved defaults when extraction is exhausted.
6. If the raw image file is available, upload it first:
   `POST https://zenbali.site/api/agent/uploads/event-image`
7. Read `data.image_url` from the upload response and map it to `e267` / `image_url`.
8. Send the full JSON payload to:
   `POST https://zenbali.site/api/agent/events`
9. Confirm the returned event ID, title, date, and `is_published=true`.

## Description Construction Rule
For `event_description`, Zack should include useful poster information not already covered well by the structured fields, including:
- subtitle or tagline
- host or facilitator context
- additional dates after the first date
- pricing notes
- booking or reservation notes
- websites, links, social handles, and social media references shown on the poster
- other relevant poster details that help a visitor understand the event

## Upload Example
```bash
curl -X POST 'https://zenbali.site/api/agent/uploads/event-image' \
  -H 'X-Agent-Token: 8c5e16225ea2dd0736766878529408f95ed6720337f154cb51e1228d3d1f006c' \
  -F image=@/tmp/event-poster.webp
```

## Event Post Example
```bash
curl -X POST 'https://zenbali.site/api/agent/events' \
  -H 'Content-Type: application/json' \
  -H 'X-Agent-Token: 8c5e16225ea2dd0736766878529408f95ed6720337f154cb51e1228d3d1f006c' \
  -d '{
    "title": "Ecstatic Dance Ubud",
    "event_date": "2026-04-10",
    "event_time": "19:15",
    "location": "Ubud",
    "event_type": "Workshop",
    "duration_days": 0,
    "duration_hours": 1,
    "duration_minutes": 0,
    "entrance_type": "Paid",
    "price_thousands": 150,
    "entrance_fee": 150000,
    "participant_group_type": "Open",
    "lead_by": "Maya",
    "venue": "Lotus Studio",
    "contact_email": "hello@example.com",
    "contact_mobile": "+628123456789",
    "event_description": "Sunset dance journey with live DJ. Additional dates: 11 and 12 April 2026. Instagram: @example. Website: https://example.com",
    "image_url": "https://storage.googleapis.com/.../image.webp"
  }'
```
