# TOOLS.md — BSC API Reference

## BSC — Blossom School Catering

**API Base:** `https://schoolcatering.gaiada1.online/api/v1`
**Site:** `https://schoolcatering.gaiada1.online/`
**Current branch standard:** `main`

### Agent Account
- **Username:** `admin`
- **Password:** `Teameditor@123`
- **Role:** `ADMIN` (can place orders for any student)

### How to Handle Orders
- ALWAYS execute `SKILL-BSC-AUTHENTICATE.md` FIRST for any BSC operation.
- Use `SKILL-BSC-ORDER.md` for placing orders via API (never browser).
- Use `SKILL-BSC-DELETE-ORDER.md` for deleting orders.
- Use `SKILL-BSC-LOOKUP-PROTOCOL.md` for name, student, or order lookups.
- Use `SKILL-BSC-ACTIVE-MENU.md` for menu queries.
- Use `SKILL-BSC-ORDER-RECOMMENDATION.md` for favourite dishes and order recommendations.

### Key Endpoints
| Action | Method | Path |
|---|---|---|
| Login | POST | `/auth/login` |
| Place order | POST | `/order/quick` |
| Delete order | DELETE | `/orders/:orderId` |
| Public name lookup | GET | `/public/lookup-name?phone=PHONE` |
| Get family context by phone | GET | `/admin/family-context?phone=PHONE` |
| Get family orders by phone/date | GET | `/admin/family-orders?phone=PHONE&date=YYYY-MM-DD` |
| Get daily orders | GET | `/orders/daily?date=YYYY-MM-DD&phone=PHONE` |
| Get menu | GET | `/menus` or `/menus?session=LUNCH\|SNACK\|BREAKFAST` |

### Family Resolution (best approach)
Use this server-side flow to resolve a sender's family:

**Step 1:** `GET /admin/family-context?phone=PHONE` (admin token required)
- Returns the sender plus family-scoped `parents[]` and `children[]`
- Backed by the schoolcatering `family_id` model
- Supports primary parent, secondary parent phone, and youngster numbers
- Real-world verified on live server on 2026-04-08

**When to use which:**
- "Who are my kids?" → `family-context`
- "Order for Elizabeth" → `family-context` (need username from `children[]`)
- "What grade is Elizabeth in?" → `family-context`
- Username format is `lastname_firstname` (e.g. `syrowatka_elizabeth`) — never guess, always look up

**Never** use `/orders/daily` to infer family membership. It only shows dated orders.

### Family Order Retrieval
- `GET /admin/family-orders?phone=PHONE&date=YYYY-MM-DD`
- Returns the family-scoped orders Brian is allowed to reveal for that sender
- Use for "what's my order today/tomorrow" and "what did my sibling/child order"

### Family Repair
- `POST /admin/families/merge`
- Admin-only repair endpoint when two existing family groups must become one
- Use only for explicit admin correction, not normal Brian lookup flow

### Token Handling
- Login returns `accessToken` — use as `Authorization: Bearer <token>`
- If you get 401, re-login once and retry

### Delete Order
- `DELETE /orders/:orderId` (admin token required)
- Brian must require explicit `yes` confirmation before calling
- If no confirmation within 60 seconds, abort

### Quick Order Authorization
- `/order/quick` requires `senderPhone` in the JSON body
- Brian must first confirm the requested child belongs to the sender's `family_id`
- No local whitelist — the database is the single source of truth
