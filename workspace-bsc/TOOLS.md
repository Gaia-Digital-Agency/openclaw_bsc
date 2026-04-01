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

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.

---

## BSC — Blossom School Catering

**API Base:** `http://34.158.47.112/schoolcatering/api/v1`
**Site:** `http://34.158.47.112/schoolcatering/`
**Quick Order Page:** `http://34.158.47.112/schoolcatering/tools/quick-order`

### Agent Account (for placing orders via API)
- **Username:** `admin`
- **Password:** `Teameditor@123`
- **Role:** `ADMIN`
- Note: Admin role can place orders for ANY registered student by username — no family scoping.

### How to Handle Orders
- Use `SKILL-BSC-ORDER.md` for placing orders — call the API via curl, NOT the browser.
- Use `SKILL-BSC-DELETE-ORDER.md` for deleting orders.
- Use `SKILL-BSC-LOOKUP-PROTOCOL.md` for checking today's orders or the user's name.
- The browser Add buttons are not automation-friendly. The API works perfectly.

### Key Endpoints
| Action | Method | Path |
|---|---|---|
| Login | POST | `/auth/login` |
| Place order (all-in-one) | POST | `/order/quick` |
| Delete order | DELETE | `/orders/:orderId` |
| Get daily orders | GET | `/orders/daily?date=YYYY-MM-DD&phone=PHONE` |
| Public name lookup | GET | `/public/lookup-name?phone=PHONE` |

### Daily Order Retrieval
- Endpoint: `GET /orders/daily`
- Query Parameters:
  - `date`: `YYYY-MM-DD`
  - `phone`: E.164 format (e.g., `+62...`)
- Returns: Array of orders linked to the phone number for the given date.
- Note: Brian uses this to answer "What's my order today?" and "What's my order tomorrow?".

### Token Handling
- Login returns `accessToken` — use as `Authorization: Bearer <token>`
- Tokens expire — if you get 401, re-login and retry once

### Admin Delete Order Capability
- Admin can delete orders for operational management.
- API route: `DELETE /orders/:orderId`
- For admin users, the backend performs a clean cancellation by updating the order to `status = CANCELLED`, setting `deleted_at`, and inserting an `ORDER_CANCELLED` audit row in `order_mutations`.
- Brian must require an explicit `yes` confirmation from the user before calling this endpoint.
- If the `yes` confirmation does not arrive within 60 seconds, Brian must abort and say exactly: `Order Deletion aborted due to mo confirmation`

### Quick Order Sender Authorization
- `/order/quick` requires Brian to send `senderPhone` in the JSON body for WhatsApp-driven orders.
- The BSC server handles all authorization dynamically — no hardcoded list needed.
- Registered parents can order only for their own linked students.
- The server will reject any `senderPhone` not registered in BSC or not linked to the target student.
- Brian does not maintain any local whitelist — the BSC database is the single source of truth.
