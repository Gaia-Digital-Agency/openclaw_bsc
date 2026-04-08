# TOOLS.md — BSC API Reference

## BSC — Blossom School Catering

**API Base:** `http://34.158.47.112/schoolcatering/api/v1`
**Site:** `http://34.158.47.112/schoolcatering/`

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

### Key Endpoints
| Action | Method | Path |
|---|---|---|
| Login | POST | `/auth/login` |
| Place order | POST | `/order/quick` |
| Delete order | DELETE | `/orders/:orderId` |
| Public name lookup | GET | `/public/lookup-name?phone=PHONE` |
| List parents (with children) | GET | `/admin/parents` |
| List all children (with grades) | GET | `/admin/children` |
| Get daily orders | GET | `/orders/daily?date=YYYY-MM-DD&phone=PHONE` |
| Get menu | GET | `/menus` or `/menus?session=LUNCH\|SNACK\|BREAKFAST` |

### Parent-Child Resolution (best approach)
Use this 2-step flow to resolve a parent's linked children:

**Step 1:** `GET /admin/parents` (admin token required)
- Find parent by matching `phone_number` to sender phone
- Returns: parent UUID, name, `linked_children_count`, and `youngsters[]` array with child names
- Also returns `parent2_first_name` and `parent2_phone` (second parent)

**Step 2:** `GET /admin/children` (admin token required)
- Filter by matching `parent_ids` to the parent UUID from Step 1
- Returns: `username`, `first_name`, `last_name`, `school_grade`, `phone_number`, `dietary_allergies`

**When to use which:**
- "Who are my kids?" → Step 1 alone (fast, gives names)
- "Order for Elizabeth" → Step 1 + Step 2 (need username from children)
- "What grade is Elizabeth in?" → Step 1 + Step 2 (need grade from children)
- Username format is `lastname_firstname` (e.g. `syrowatka_elizabeth`) — never guess, always look up

**Never** use `/orders/daily` to infer linked children. It only shows children with active orders.

### Daily Order Retrieval
- `GET /orders/daily?date=YYYY-MM-DD&phone=PHONE`
- Returns orders linked to the phone number for the given date
- Use for "what's my order today/tomorrow" only

### Token Handling
- Login returns `accessToken` — use as `Authorization: Bearer <token>`
- If you get 401, re-login once and retry

### Delete Order
- `DELETE /orders/:orderId` (admin token required)
- Brian must require explicit `yes` confirmation before calling
- If no confirmation within 60 seconds, abort

### Quick Order Authorization
- `/order/quick` requires `senderPhone` in the JSON body
- The BSC server enforces parent-child linking dynamically
- No local whitelist — the database is the single source of truth
