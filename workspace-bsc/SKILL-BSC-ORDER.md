# SKILL-BSC-ORDER.md — Blossom School Catering: Place Order

Use this skill whenever anyone asks you to place a meal order on the school catering site.

Do not ask for confirmation before placing a normal order unless the user explicitly asked for a confirmation step.

## Trigger Phrases
- "place order", "book lunch", "order food", "add order"
- Any message containing a student username, date(s), session, and dish list

## NEVER Use the Browser for Orders
The site's Add buttons do not respond to browser automation. Always use the API via curl.

## SINGLE ORDER FLOW

### Step 0 — Authenticate & Parse the Message

Authentication (MANDATORY FIRST):
Execute `SKILL-BSC-AUTHENTICATE.md` to resolve sender identity and authorization.
This returns: `SENDER_PHONE`, `SENDER_NAME`, `SENDER_FIRST_NAME`, `SENDER_USERNAME`, `SENDER_ROLE`, `IS_SUPERUSER`, `LINKED_STUDENTS`.

Use `SENDER_NAME` as `LookupName` for all replies. Use `SENDER_FIRST_NAME` for casual greetings.

Superuser override:
- If `IS_SUPERUSER` is true, the sender can place orders for any student regardless of family linking. The sender may specify any `childUsername` directly.

Parent family auth:
- If `SENDER_ROLE` is `PARENT`, the sender can place orders for their linked children.
- Use `LINKED_STUDENTS` from `SKILL-BSC-AUTHENTICATE` as the source of truth for which children are linked.
- If the parent has multiple linked children and the request is ambiguous, ask which child.
- Never infer the child list from `/orders/daily`.

Parse:
- `STUDENT_USERNAME` — verbatim if the user provided it directly
- `SENDER_PHONE` — already resolved by `SKILL-BSC-AUTHENTICATE`
- `DATE` — convert to `YYYY-MM-DD`
- `SESSION` — uppercase
- `DISHES` — array of dish names

Date rules:
- Always send `date` as a JSON string in exact `YYYY-MM-DD` format.
- Never send natural-language dates to the API.
- Resolve relative dates using Asia/Makassar local date.
- If the user gives day/month without a year, infer the nearest valid future service date.
- If the date is ambiguous and cannot be resolved safely, ask one short clarification question instead of attempting the API call.
- Before sending the API call, mentally verify the payload shape is:
  `{"childUsername":"...","senderPhone":"...","date":"2026-04-02","session":"LUNCH","dishes":["..."]}`

### Step 1 — Login (once per session)
```sh
curl -s -X POST http://34.158.47.112/schoolcatering/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"Teameditor@123"}'
```

Extract `accessToken`. If empty or missing, reply `Login failed — server error` and stop.

### Step 1.5 — Resolve childUsername
If the user did not provide a student username, use the authentication result:
- If `SENDER_ROLE` is `CHILD`, use `SENDER_USERNAME` as `childUsername`.
- If `SENDER_ROLE` is `PARENT` and exactly one linked student exists, use that student's username.
- If `SENDER_ROLE` is `PARENT` and multiple linked students exist, ask which child to order for.
- If `IS_SUPERUSER` is true and no `childUsername` is specified, ask which student to order for.

LookupName and greetings are already resolved by `SKILL-BSC-AUTHENTICATE`. Do not re-lookup.

### Step 2 — Place Order (Attempt A: with both fields)
Try with both `childUsername` and `senderPhone`:

```sh
curl -s -X POST http://34.158.47.112/schoolcatering/api/v1/order/quick \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN_HERE" \
  -d '{"childUsername":"STUDENT_USERNAME","senderPhone":"SENDER_PHONE","date":"YYYY-MM-DD","session":"SESSION","dishes":["Dish1","Dish2"]}'
```

If Attempt A succeeds, go to Step 3.

### Step 2 Fallback — Place Order (Attempt B: childUsername only)
If Attempt A fails with a validation error about `senderPhone`, retry without `senderPhone`.

### Step 2 Fallback — Place Order (Attempt C: senderPhone only)
If Attempt B also fails, retry with `senderPhone` only.

Required payload fields:
- `childUsername`
- `senderPhone`
- `date`
- `session`
- `dishes`

Never send these wrong keys to `/order/quick`:
- `orderDate`
- `studentUsername`
- any nested object for `date`

If you receive HTTP 401 on Step 2, re-login once and retry.
If the API returns a validation error about `date`, correct it to exact `YYYY-MM-DD` and retry once.

### Step 3 — Reply
See reply format below.

## BULK / MULTI-DATE ORDER FLOW

When the message contains orders for multiple dates:
- Execute `SKILL-BSC-AUTHENTICATE.md` first.
- Use `LINKED_STUDENTS` for parent-child disambiguation.
- Login once.
- Loop through each date with the same `childUsername` + `senderPhone` payload shape.

## REPLY FORMAT — Single Order

Success:

```text
Brian ♾️ {LookupName},

Yes, I have successfully placed the order:

Order placed : ✅
Order ID     : #{ref}
Date         : {serviceDate}
Session      : {session title-cased}
Items        : {items joined by ", "}
Total        : {totalPriceFormatted}

Enjoy your meal, {studentName}! 🍽️
```

Error:

```text
Brian ♾️ {LookupName},
Order failed ✗ — {concise reason}
```

## REPLY FORMAT — Bulk Order

```text
Brian ♾️ {LookupName},

Here is the order summary for {studentFirstName}:

• {date} — ✅ {dishes} — {totalPriceFormatted}
• {date} — ⏭️ Weekend, skipped
• {date} — ✗ {short error reason}

Total orders placed: {count}
Total amount: {sum of all successful order prices}

Enjoy your meals, {studentFirstName}! 🍽️
```

## Sender Authorization Rule
- Try sending both `childUsername` and `senderPhone` in the `/order/quick` JSON body.
- If the API rejects one field, fall back to the other.
- The BSC server enforces all authorization dynamically.
- Registered parents can order only for students returned by `/admin/family-students?phone=SENDER_PHONE`.
- Superuser exception: `+6281138210188` can order for any student.

## Order Placement Confirmation Rule
- Normal order placement does not require a confirmation turn.
- Delete-order flow requires confirmation, but standard order placement does not.

## ERROR CODES
- `Dishes not found for session...` → dish names not on the menu
- `ORDER_ALREADY_EXISTS_FOR_DATE` → order already exists
- `ORDER_WEEKEND_SERVICE_BLOCKED` → weekend date
- `ORDER_BLACKOUT_BLOCKED` → blackout date
- `SESSION_CUTOFF_PASSED` → cutoff passed
- `Student with username ... not found` → student username not registered
- `No linked parent for billing` → student has no linked parent

## Credentials & Endpoints
See `TOOLS.md`.
Login: `admin / Teameditor@123`
