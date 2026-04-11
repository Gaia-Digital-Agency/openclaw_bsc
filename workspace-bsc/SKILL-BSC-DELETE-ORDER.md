# SKILL-BSC-DELETE-ORDER.md — Blossom School Catering: Delete Order

Use this skill whenever anyone asks Brian to delete or cancel a Blossom School Catering order by order number.

## Trigger Phrases
- "delete order"
- "cancel order"
- "remove order"
- Any Brian-directed message that includes an order number and asks for deletion

## Data Privacy Rule
- **Primary Exception:** I am authorized to share today's order details (student first name, order ID, session, and dishes) when a user asks about their own orders.
- Do not disclose sensitive School Catering information for general inquiries about other people.
- If the user asks for extra order details outside of the "today's order" exception (like historical data or parent phone numbers), refuse with:
Due to privacy rules, I am not permitted to share sensitive family contact details.

## Step 0 — Authenticate Sender (MANDATORY FIRST)
Execute `SKILL-BSC-AUTHENTICATE.md` to resolve sender identity and authorization.
This returns: SENDER_PHONE, SENDER_NAME, SENDER_FIRST_NAME, SENDER_USERNAME, SENDER_ROLE, IS_SUPERUSER.

Use SENDER_NAME as `LookupName` for all replies.

**Superuser override:** If IS_SUPERUSER is true, the sender can delete ANY order for any user.

**Parent family auth:** If SENDER_ROLE is PARENT (Parent#1 or Parent#2), the sender can delete orders for their linked children.

## Required Inputs
- ORDER_NUMBER — must be the order UUID / order id used by the API
- SENDER_PHONE — already resolved by SKILL-BSC-AUTHENTICATE
- LOOKUP_NAME — already resolved by SKILL-BSC-AUTHENTICATE (SENDER_NAME)

If the user does not provide an order number, ask only for the order number.

## NEVER Delete Immediately
Brian must always ask for confirmation first.

### Step 1 — Confirm the Delete Request
Reply using this exact confirmation prompt format:

Brian ♾️ {LookupName},

To confirm, do you want to delete order {ORDER_NUMBER} ? Please reply with 'yes' to proceed, or 'no' to cancel. In no response within 60 seconds, this order deletion request will be aborted.

### Step 2 — Wait for Confirmation
- Only proceed if the user replies with exactly `yes`.
- The `yes` must arrive within 60 seconds of the confirmation prompt.
- If the user replies with anything else, do not delete the order.
- If 60 seconds pass without an exact `yes`, abort the request and reply exactly:
Order Deletion aborted due to mo confirmation

## Delete Flow

### Step 3 — Login
curl -s -X POST https://schoolcatering.gaiada1.online/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"Teameditor@123"}'

Extract `accessToken`. If empty or missing, reply:
Brian ♾️ {LookupName},
Order deletion failed ✗ — Login failed

### Step 4 — Delete the Order
Use the admin delete-order capability:

curl -s -X DELETE https://schoolcatering.gaiada1.online/api/v1/orders/ORDER_NUMBER \
  -H "Authorization: Bearer TOKEN_HERE"

If you receive HTTP 401, re-login once and retry once.

## Delete Rules
- Use the admin delete endpoint only after the exact `yes` confirmation arrives in time.
- Do not fabricate order details before deletion.
- Do not promise success before the API responds.
- If the API blocks deletion or returns an error, report the concise reason and stop.
- This endpoint performs a clean operational delete by marking the order `CANCELLED`, setting `deleted_at`, and writing an audit mutation.

## Reply Format

SUCCESS:

Brian ♾️ {LookupName},
Order Number {ORDER_NUMBER} successfully deleted, would you like to make a new order

TIMEOUT / NO CONFIRMATION:

Order Deletion aborted due to mo confirmation

ERROR:

Brian ♾️ {LookupName},
Order deletion failed ✗ — {concise reason}

## Credentials & Endpoint
See TOOLS.md — BSC section.
