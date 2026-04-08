# SKILL-BSC-LOOKUP-PROTOCOL.md — MANDATORY DAILY RETRIEVAL

Use this skill for ANY query about user name, identity, or daily orders in the BSC system.

## MANDATORY PROTOCOL
- You are **FORBIDDEN** from using the names "Roger" or "Azlan" for the operator unless they are explicitly returned by the authentication lookup.
- You **MUST** execute SKILL-BSC-AUTHENTICATE as your **FIRST ACTION**.
- Direct use of the `fetch` tool is the **ONLY** authorized method.

## Trigger Phrases
- "what's my order today"
- "today's order"
- "what's my order tomorrow"
- "tomorrow's order"
- "whats my name"
- "who am I"
- "whats my name in BSC"
- "what is my name in BSC"
- "who are my kids"
- "what students are under my account"
- "what grade is X in"

## Execution Flow

### Step 1 — Authenticate Sender (MANDATORY FIRST STEP)
Execute `SKILL-BSC-AUTHENTICATE.md` to resolve sender identity and authorization.
This returns: SENDER_PHONE, SENDER_NAME, SENDER_FIRST_NAME, SENDER_USERNAME, SENDER_ROLE, IS_SUPERUSER.

Use SENDER_NAME for all greetings. If SENDER_ROLE is PARENT (Parent#1 or Parent#2), the sender can view orders for their linked children.

### Step 1a — Superuser: View Any User's Orders
If IS_SUPERUSER is true:
- The sender can query orders for ANY user, not just their own family.
- If the sender specifies a phone number or username for another user, use that for the daily order lookup.
- If no specific user is mentioned, look up orders for the superuser's own phone.

### Step 1b — Resolve Children (If parent asks about kids/students)
If SENDER_ROLE is PARENT and the user asks about their children, students, or grades:
1. **Login** to get admin token (same as Step 2)
2. **Fetch all children:** `GET /admin/children` with admin Bearer token
3. **Filter** by matching `parent_ids` to the parent's UUID
4. **Return** all matched children with: first_name, last_name, username, school_grade, phone_number

This is also used to resolve first name → childUsername when a parent says "order for Elizabeth":
- Find the child where `first_name` matches and `parent_ids` includes the parent's UUID
- Use that child's `username` field as the `childUsername` for the order API

### Step 2 — Fetch Daily Orders (If requested)
1. **Identify Date:** Determine if the user asked for "today" or "tomorrow". Use the current system date and calculate accordingly (YYYY-MM-DD).
2. **Login** to get an auth token using the `fetch` tool:
   - **URL:** `http://34.158.47.112/schoolcatering/api/v1/auth/login`
   - **Method:** `POST`
   - **Body:** `{"username":"admin","password":"Teameditor@123"}`
3. **Fetch orders** using the `fetch` tool:
   - **URL:** `http://34.158.47.112/schoolcatering/api/v1/orders/daily?date=DATE_CALCULATED&phone=SENDER_PHONE`
   - **Method:** `GET`
   - **Headers:** `{"Authorization": "Bearer TOKEN_HERE"}` (Use the token from Login)

### Step 3 — Reply
Use ONLY plain text. NO Markdown symbols (** bold, etc).

Example (Today):
Brian ♾️ Natasha,
Today's Order
Order ID: #9986F34E
Date: 2026-03-30
Session: LUNCH
Items: Beef Rice Bowl, Beetroot & Hazelnut Salad
Enjoy your meal, Natasha ❤️

Example (Tomorrow):
Brian ♾️ Natasha,
Tomorrow's Order
Order ID: #A123B456
Date: 2026-03-31
Session: LUNCH
Items: Chicken Pasta, Fruit Salad
Enjoy your meal, Natasha ❤️
