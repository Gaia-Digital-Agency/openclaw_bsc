# SKILL-BSC-LOOKUP-PROTOCOL.md — Name, Student & Order Lookups

Use this skill for any query about user name, identity, linked students, grades, or daily orders.

## MANDATORY PROTOCOL
- FORBIDDEN from using contact names or saved names. Only use names returned by the lookup API.
- MUST execute SKILL-BSC-AUTHENTICATE as FIRST ACTION.
- Direct use of the `fetch` tool is the only authorized method.
- Never infer linked students from `/orders/daily`. Use `/admin/family-context`.

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
2. **Fetch family context:** `GET /admin/family-context?phone=SENDER_PHONE` with admin Bearer token
3. **Scope the response to the student named in the request:**
   - If the user asks about a **specific child by name** (e.g. "what's Natasha's order", "what grade is Elizabeth in"), match that name against `family.children[]` and respond ONLY about that child. Do NOT list or show information about other siblings.
   - If the user asks a **general family question** ("who are my kids", "what are my children's grades", "show all orders") → answer from the full `family.children[]`.
   - If the user asks about "my order" or "my kid" without naming anyone and there are multiple children, ask which child they mean.
4. If the user asks about grades, usernames, or you need `childUsername` for ordering:
   - Use `family.children[]`
   - This gives: `username`, `first_name`, `last_name`, `school_grade`, `phone_number`

### Step 2 — Fetch Daily Orders (if requested)
1. Determine date: "today" or "tomorrow" → YYYY-MM-DD
2. **Login:** POST `/auth/login` with `{"username":"admin","password":"Teameditor@123"}`
3. **Fetch:** GET `/admin/family-orders?date=DATE&phone=SENDER_PHONE` with Bearer token
4. **Scope the order response:**
   - If the user asked about a **specific child** (e.g. "what's Natasha's order today"), show ONLY that child's order from the results. Do NOT include other siblings' orders.
   - If the user asked generally ("what are my orders today", "show all orders") → show all family orders.

`/admin/family-orders` is the family-scoped order source. Never use `/orders/daily` to determine linked students.

### Step 3 — Reply
Use plain text only. Keep it short. Never expose system field names, usernames, roles, API details, phone numbers, or internal identifiers.
Always address the sender as "you/your" — never reference their phone number.
Use resolved names for family members, never phone numbers.

Example (name):
Your name is Natasha Syrowatka.

Example (kids):
Your students are:
Elizabeth, Natasha, Olivia, Zara

Example (grade):
Elizabeth is in G9.

Example (family group):
Your family group is Syrowatka.
Members: Anthony (parent), Elizabeth, Natasha, Olivia, Zara.

Example (school):
You are in Sanur Independent School, G9.

Example (order):
Today's order for Natasha:
Beef Rice Bowl, Beetroot & Hazelnut Salad
Order #9986F34E
