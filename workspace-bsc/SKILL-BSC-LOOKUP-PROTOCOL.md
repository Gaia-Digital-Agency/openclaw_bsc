# SKILL-BSC-LOOKUP-PROTOCOL.md — MANDATORY DAILY RETRIEVAL

Use this skill for any query about user name, identity, linked students, or daily orders in the BSC system.

## MANDATORY PROTOCOL
- You are FORBIDDEN from using the names "Roger" or "Azlan" for the operator unless they are explicitly returned by the authentication lookup.
- You MUST execute SKILL-BSC-AUTHENTICATE as your FIRST ACTION.
- Direct use of the `fetch` tool is the only authorized method.
- Use the family lookup from authentication as the source of truth for parent-linked students.
- Do not infer linked students from `/orders/daily`.

## Trigger Phrases
- "what's my order today"
- "today's order"
- "what's my order tomorrow"
- "tomorrow's order"
- "whats my name"
- "who am I"
- "whats my name in BSC"
- "what is my name in BSC"
- "which students are under my account"
- "who are my children in BSC"

## Execution Flow

### Step 1 — Authenticate Sender (MANDATORY FIRST STEP)
Execute `SKILL-BSC-AUTHENTICATE.md` to resolve sender identity and authorization.
This returns: `SENDER_PHONE`, `SENDER_NAME`, `SENDER_FIRST_NAME`, `SENDER_USERNAME`, `SENDER_ROLE`, `IS_SUPERUSER`, `LINKED_STUDENTS_COUNT`, `LINKED_STUDENTS`.

Use `SENDER_NAME` for all greetings.
If `SENDER_ROLE` is `PARENT`, use `LINKED_STUDENTS` as the authoritative linked-student roster.

### Step 1a — Superuser: View Any User's Orders
If `IS_SUPERUSER` is true:
- The sender can query orders for any user, not just their own family.
- If the sender specifies a phone number or username for another user, use that for the daily order lookup.
- If no specific user is mentioned, look up orders for the superuser's own phone.

### Step 2 — Parent Family Response
If the sender is a parent and asks which students are linked to their account:
- Answer from `LINKED_STUDENTS`.
- Never answer from `/orders/daily`.

Example:

```text
Brian ♾️ Anthony,
The students linked to your BSC account are:
Elizabeth Syrowatka
Natasha Syrowatka
Zara Syrowatka
Olivia Syrowatka
```

### Step 3 — Fetch Daily Orders (If requested)
1. Identify Date: Determine if the user asked for "today" or "tomorrow". Use the current system date and calculate accordingly (`YYYY-MM-DD`).
2. Login to get an auth token using the `fetch` tool:
   - URL: `http://34.158.47.112/schoolcatering/api/v1/auth/login`
   - Method: `POST`
   - Body: `{"username":"admin","password":"Teameditor@123"}`
3. Fetch orders using the `fetch` tool:
   - URL: `http://34.158.47.112/schoolcatering/api/v1/orders/daily?date=DATE_CALCULATED&phone=SENDER_PHONE`
   - Method: `GET`
   - Headers: `{"Authorization": "Bearer TOKEN_HERE"}`

`/orders/daily` is for dated orders only. It is not the source of truth for the full family roster.

### Step 4 — Reply
Use only plain text.

If the sender asks about linked students, list `LINKED_STUDENTS`.
If the sender asks about today's or tomorrow's orders, answer only from the `/orders/daily` response for that specific date.
Never say a parent has only those students under the account unless that conclusion comes from `/admin/family-students`.
