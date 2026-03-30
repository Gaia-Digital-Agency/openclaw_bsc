# SKILL-BSC-LOOKUP-PROTOCOL.md — MANDATORY DAILY RETRIEVAL

Use this skill for ANY query about user name, identity, or daily orders in the BSC system.

## MANDATORY PROTOCOL
- You are **FORBIDDEN** from using the names "Roger" or "Azlan" for the operator unless they are explicitly returned by the API call in Step 1.
- You **MUST** execute the identity lookup in Step 1 as your **FIRST ACTION**.
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

## Execution Flow

### Step 1 — Identity Lookup (MANDATORY FIRST STEP)
Extract the `SENDER_PHONE` from the sender metadata provided in the message (look for `sender_id` or `e164` in the `Conversation info` JSON block).

Call the public lookup endpoint with the `SENDER_PHONE` using the `fetch` tool:
- **URL:** `http://34.158.47.112/schoolcatering/api/v1/public/lookup-name?phone=SENDER_PHONE`
- **Method:** `GET`

**Instructions:**
- Use the exact name returned by this API to address the user.
- If the API returns a `studentName`, use that. If it returns a `Parent0D` label, use that.
- If no results are found, reply: "I could not find your identity in the system."

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
