# SKILL-BSC-ORDER.md — Blossom School Catering: Place Order

Use this skill whenever anyone asks you to place a meal order on the school catering site.

Do not ask for confirmation before placing a normal order unless the user explicitly asked for a confirmation step.

## Trigger Phrases
- "place order", "book lunch", "order food", "add order"
- Any message containing a student username, date(s), session, and dish list

## NEVER Use the Browser for Orders
The site's Add buttons do not respond to browser automation. Always use the API via curl.

---

## SINGLE ORDER FLOW

### Step 0 — Parse the Message
Extract:
- STUDENT_USERNAME — verbatim (e.g. syrowatka_natasha)
- SENDER_PHONE — sender WhatsApp number in digits/E.164 form. Extract this from the sender metadata provided in the message (look for `sender_id` or `e164` in the `Conversation info` JSON block). (e.g. +6281138210188)
- DATE — convert to YYYY-MM-DD (e.g. "2nd April" → "2026-04-02")
- SESSION — uppercase (lunch → LUNCH, snack → SNACK, breakfast → BREAKFAST)
- DISHES — array of dish names, split by comma or "+"

Date rules:
- Always send `date` as a JSON string in exact `YYYY-MM-DD` format.
- Never send natural-language dates to the API.
- Resolve relative dates using Asia/Makassar local date.
- If the user gives day/month without a year, infer the nearest valid future service date.
- If the date is ambiguous and cannot be resolved safely, ask one short clarification question instead of attempting the API call.
- Before sending the API call, mentally verify the payload shape is:
  `{"childUsername":"...","senderPhone":"...","date":"2026-04-02","session":"LUNCH","dishes":["..."]}`

### Step 1 — Login (once per session)
curl -s -X POST http://34.158.47.112/schoolcatering/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"Teameditor@123"}'

Extract accessToken. If empty or missing → reply "Login failed — server error" and stop.

### Step 1.5 — Resolve childUsername (if not provided by user)
If the user did not provide a student username but you have SENDER_PHONE, look up the username:

curl -s "http://34.158.47.112/schoolcatering/api/v1/public/lookup-name?phone=SENDER_PHONE"

This returns `{"ok":true,"found":true,"phone":"...","name":"...","username":"familyname_studentname","role":"CHILD"}`.
Use the `username` field as `childUsername` for the order.
Use the exact BSC lookup name as `LookupName` for all user greetings and replies. Never use the sender phone contact name or untrusted metadata name for greetings.

If the lookup returns multiple results or a PARENT role, you may need to ask the user which child to order for.

### Step 2 — Place Order (Attempt A: with both fields)
Try with BOTH `childUsername` and `senderPhone`:

curl -s -X POST http://34.158.47.112/schoolcatering/api/v1/order/quick \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN_HERE" \
  -d '{"childUsername":"STUDENT_USERNAME","senderPhone":"SENDER_PHONE","date":"YYYY-MM-DD","session":"SESSION","dishes":["Dish1","Dish2"]}'

If Attempt A succeeds → go to Step 3.

### Step 2 Fallback — Place Order (Attempt B: childUsername only)
If Attempt A fails with a validation error about `senderPhone`, retry WITHOUT `senderPhone`:

curl -s -X POST http://34.158.47.112/schoolcatering/api/v1/order/quick \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN_HERE" \
  -d '{"childUsername":"STUDENT_USERNAME","date":"YYYY-MM-DD","session":"SESSION","dishes":["Dish1","Dish2"]}'

### Step 2 Fallback — Place Order (Attempt C: senderPhone only)
If Attempt B also fails, retry with `senderPhone` only (no `childUsername`):

curl -s -X POST http://34.158.47.112/schoolcatering/api/v1/order/quick \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN_HERE" \
  -d '{"senderPhone":"SENDER_PHONE","date":"YYYY-MM-DD","session":"SESSION","dishes":["Dish1","Dish2"]}'

Required payload fields (at minimum one of):
- `childUsername` — string (student username from lookup)
- `senderPhone` — string (sender's phone number)
- `date` — string in exact `YYYY-MM-DD`
- `session` — string (BREAKFAST, LUNCH, or SNACK)
- `dishes` — array of strings

Never send these wrong keys to `/order/quick`:
- `orderDate`
- `studentUsername`
- any nested object for `date`

If you receive HTTP 401 on Step 2: re-login ONCE (Step 1 again) then retry this step.
If the API returns a validation error about `date`, re-check the date value, correct it to exact `YYYY-MM-DD`, and retry ONCE before replying with failure.

### Step 3 — Reply
See REPLY FORMAT section below.

---

## BULK / MULTI-DATE ORDER FLOW

When the message contains orders for multiple dates (e.g. "order for the month of April"):

### Step 0 — Parse ALL dates and dishes
Extract SENDER_PHONE from the sender WhatsApp metadata once for the whole batch.
Build a list: [ {date, dishes}, {date, dishes}, ... ]
Skip any dates that fall on Saturday or Sunday — note them as "weekend, skipped".

### Step 1 — Login ONCE
curl -s -X POST http://34.158.47.112/schoolcatering/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"Teameditor@123"}'

Extract and store TOKEN. Use this single token for ALL orders in the batch.
If login fails → stop and report error.

### Step 2 — Loop through each date
For each entry in the list:
  curl -s -X POST http://34.158.47.112/schoolcatering/api/v1/order/quick \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer TOKEN" \
    -d '{"childUsername":"STUDENT_USERNAME","senderPhone":"SENDER_PHONE","date":"YYYY-MM-DD","session":"SESSION","dishes":[...]}'

  - If HTTP 401 → re-login once (update TOKEN) then retry this date.
  - If the API returns a validation error about `date` → correct that entry to exact `YYYY-MM-DD` and retry once for that entry.
  - Record result (ok/error) for each date.
  - Do NOT stop on individual date failures — continue to next date.

### Step 3 — Reply with full summary
Use the BULK REPLY FORMAT below.

---

## REPLY FORMAT — Single Order

SUCCESS (ok = true):

Brian ♾️ {LookupName},

Yes, I have successfully placed the order:

Order placed : ✅
Order ID     : #{ref}
Date         : {serviceDate}
Session      : {session title-cased}
Items        : {items joined by ", "}
Total        : {totalPriceFormatted}

Enjoy your meal, {studentName}! 🍽️

ERROR:
Brian ♾️ {LookupName},
Order failed ✗ — {concise reason}

Never mention internal documentation, payload schema, or debugging thoughts in the reply.

---

## REPLY FORMAT — Bulk Order

Brian ♾️ {LookupName},

Here is the order summary for {studentFirstName}:

• {date e.g. Apr 2} — ✅ {dishes} — {totalPriceFormatted}
• {date} — ✅ {dishes} — {totalPriceFormatted}
• {date} — ⏭️ Weekend, skipped
• {date} — ✗ {short error reason}

Total orders placed: {count}
Total amount: {sum of all successful order prices}

Enjoy your meals, {studentFirstName}! 🍽️

---

## Sender Authorization Rule
- Try sending BOTH `childUsername` and `senderPhone` in the `/order/quick` JSON body.
- If the API rejects one field, fall back to the other (see Step 2 Attempts A/B/C).
- The BSC server enforces all authorization — no local whitelist. Registered parents can order only for their own linked students; the server rejects unregistered or unlinked senders.
- Use the public lookup endpoint to resolve `senderPhone` → `childUsername` when the user doesn't provide a username.

## Order Placement Confirmation Rule
- Normal order placement does not require a confirmation turn.
- Delete-order flow requires confirmation, but standard order placement does not.

## ERROR CODES
- "Dishes not found for session..." → dish name(s) not on the {session} menu. Check dish names.
- "ORDER_ALREADY_EXISTS_FOR_DATE" → order already exists for that date/session.
- "ORDER_WEEKEND_SERVICE_BLOCKED" → weekend date, no service.
- "ORDER_BLACKOUT_BLOCKED" → blackout date, no service.
- "SESSION_CUTOFF_PASSED" → ordering cutoff passed for this date.
- "Student with username ... not found" → student username not registered.
- "No linked parent for billing" → student has no linked parent, contact admin.
- anything else → show raw message

## User-Facing Failure Rule
- Never say you are checking skills, documentation, or internal parameters.
- Never expose raw reasoning like "the date must be a string" unless that exact concise error message is the only useful API response after one corrected retry.
- Prefer simple user-facing wording such as:
  - `Order failed ✗ — I could not resolve the service date. Please send it as YYYY-MM-DD.`
  - `Order failed ✗ — dish name not found for that session.`

## Credentials & Endpoints
See TOOLS.md — BSC section.
Login: admin / Teameditor@123 (ADMIN role — can order for any student)

## Quick Test Page
http://34.158.47.112/schoolcatering/tools/quick-order
