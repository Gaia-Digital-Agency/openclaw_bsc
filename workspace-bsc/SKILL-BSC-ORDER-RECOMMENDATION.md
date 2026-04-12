# SKILL-BSC-ORDER-RECOMMENDATION.md — Favourite Dishes & Order Recommendations

Use this skill when asked about favourite dishes, most ordered items, or dish recommendations based on order history.

## Trigger Phrases
- "what's my favourite dish", "what do I usually order"
- "what does X usually order", "what's X's favourite"
- "most ordered dishes", "recommend something", "what should I order"
- "what dishes does my kid like"

## MANDATORY PROTOCOL
- MUST execute SKILL-BSC-AUTHENTICATE as FIRST ACTION.
- Direct use of the `fetch` tool is the only authorized method.
- Scope the response to the specific student named in the request (see SKILL-BSC-LOOKUP-PROTOCOL Step 1b scoping rules).

## Execution Flow

### Step 1 — Authenticate & Resolve Student
Execute `SKILL-BSC-AUTHENTICATE.md` to resolve sender identity.

If SENDER_ROLE is PARENT:
1. **Login** to get admin token
2. **Fetch family context:** `GET /admin/family-context?phone=SENDER_PHONE` with admin Bearer token
3. If the user names a specific child, match against `family.children[]` to get `child_name` (format: "Firstname Lastname")
4. If no child named and multiple children exist, ask which child

If SENDER_ROLE is YOUNGSTER:
- Use the sender's own resolved name as the target student

### Step 2 — Fetch All Orders
`GET /admin/orders` with admin Bearer token.

Response contains `outstanding[]` and `completed[]` arrays. Combine both arrays for the full order history.

**Important:** This endpoint returns orders for ALL students, not filtered by child. You MUST filter client-side.

### Step 3 — Filter & Tally
1. Filter orders where `child_name` matches the target student (exact match)
2. Collect all `dishes[].item_name` from matched orders
3. Count frequency of each unique dish name
4. Sort by frequency descending
5. Take the top 5 unique dishes

### Step 4 — Reply

Use plain text only. Keep it short and friendly. Never expose order IDs, system fields, or internal identifiers.

Example (specific child):
Natasha's top 5 most ordered dishes:
1. Beef Rice Bowl (4 times)
2. Passion Fruit Refresher (4 times)
3. Crumbed Dory (3 times)
4. Spaghetti Bolognese (3 times)
5. Fresh Lemonade (2 times)

Example (youngster asking about themselves):
Your top 5 most ordered dishes:
1. Beef Rice Bowl (4 times)
2. Passion Fruit Refresher (4 times)
3. Crumbed Dory (3 times)
4. Spaghetti Bolognese (3 times)
5. Fresh Lemonade (2 times)

If the student has fewer than 5 unique dishes, show all of them.
If the student has no order history, reply: "No past orders found for {studentName} yet."

## Rules
- Never expose raw API fields, order IDs, prices, or internal data in the recommendation response.
- Drinks and snacks count as dishes — include them in the tally.
- If the user asks "recommend something", present the top dishes as suggestions based on past orders.
- Respect student-specific scoping: only show the named student's data, not siblings.
