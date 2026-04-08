# SKILL-BSC-LOOKUP-PROTOCOL.md — Name, Student & Order Lookups

Use this skill for any query about user name, identity, linked students, grades, or daily orders.

## MANDATORY PROTOCOL
- FORBIDDEN from using "Roger" or "Azlan" unless returned by the lookup API.
- MUST execute SKILL-BSC-AUTHENTICATE as FIRST ACTION.
- Direct use of the `fetch` tool is the only authorized method.
- Never infer linked students from `/orders/daily`. Use `/admin/parents` + `/admin/children`.

## Trigger Phrases
- "what's my name", "who am I"
- "who are my kids", "what students are under my account"
- "what grade is X in"
- "what's my order today", "what's my order tomorrow"

## Execution Flow

### Step 1 — Authenticate Sender (MANDATORY FIRST)
Execute `SKILL-BSC-AUTHENTICATE.md` to resolve sender identity.
Returns: SENDER_PHONE, SENDER_NAME, SENDER_FIRST_NAME, SENDER_USERNAME, SENDER_ROLE, IS_SUPERUSER.

Use SENDER_NAME for all greetings.

### Step 1a — Superuser
If IS_SUPERUSER is true, the sender can query orders/students for any user.

### Step 1b — Resolve Children (parent asks about kids/students/grades)
If SENDER_ROLE is PARENT:

1. **Login** to get admin token
2. **Fetch parents:** `GET /admin/parents` with admin Bearer token
3. **Find parent** by matching `phone_number` to SENDER_PHONE → get parent UUID and `youngsters[]`
4. If the user just asks "who are my kids" → answer from `youngsters[]` (fast, one call)
5. If the user asks about grades, usernames, or you need `childUsername` for ordering:
   - **Fetch children:** `GET /admin/children` with admin Bearer token
   - **Filter** by matching `parent_ids` to the parent UUID
   - This gives: `username`, `first_name`, `last_name`, `school_grade`, `phone_number`

### Step 2 — Fetch Daily Orders (if requested)
1. Determine date: "today" or "tomorrow" → YYYY-MM-DD
2. **Login:** POST `/auth/login` with `{"username":"admin","password":"Teameditor@123"}`
3. **Fetch:** GET `/orders/daily?date=DATE&phone=SENDER_PHONE` with Bearer token

`/orders/daily` is for dated orders ONLY. Never use it to determine linked students.

### Step 3 — Reply
Use plain text only.

Example (name):
Brian ♾️ Your name is Natasha Syrowatka.

Example (kids):
Brian ♾️ Anthony, the students linked to your account are:
Elizabeth Syrowatka
Natasha Syrowatka
Olivia Syrowatka
Zara Syrowatka

Example (grade):
Brian ♾️ Elizabeth is in G9 at Bali Island School.

Example (order):
Brian ♾️ Natasha,
Today's Order
Order ID: #9986F34E
Date: 2026-03-30
Session: LUNCH
Items: Beef Rice Bowl, Beetroot & Hazelnut Salad
Enjoy your meal, Natasha!
