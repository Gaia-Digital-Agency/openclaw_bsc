# SKILL-BSC-REGISTER.md — WhatsApp Family Registration

This skill handles the full multi-turn WhatsApp registration flow.
It covers three distinct turns: (1) intent detected → send one combined message (welcome guide + form), (2) template received → validate and confirm, (3) YES received → submit to API.

---

## Trigger Phrases — Send Invite (Turn 1)

Trigger when sender says any of:
- "register", "sign up", "sign me up", "new account", "create account"
- "daftar", "daftar baru", "mau daftar"
- "how do I register", "how to register", "how to sign up"
- "I want to register", "I'd like to register"
- "can you help me to register", "help me register"

Do NOT trigger if a registration state file already exists and is not expired — handle that case (see Stale File below).

---

## Trigger — Template Received (Turn 2)

Trigger when the message contains ALL of these markers:
- `Family or Group name`
- `Parent first name`
- `Email`
- `Password`
- `Student 1` or `--- Student`

---

## Trigger — Confirmation Reply (Turn 3)

Trigger when:
- Sender replies `YES` or `yes` or `Ya` or `ya` or `confirm`
- AND a valid non-expired state file exists at `/opt/.openclaw-bsc/memory/registration_{PHONE}.json`

Or cancel:
- Sender replies `NO` or `no` or `Tidak` or `cancel` or `batal`
- AND a state file exists

---

## School Resolution — Live Lookup (runtime)

Do NOT hardcode school UUIDs. At Turn 2 (template received), fetch the live school list:

```
curl -s https://schoolcatering.gaiada1.online/api/v1/auth/register/schools
```

Returns array of `{ id, name, city }`. Fuzzy match the parent's typed school name against the `name` field.

Fuzzy match rules:
- Case-insensitive, partial match is sufficient
- "BIS", "bali island", "bali" → Bali Island School
- "SIS", "sanur independent", "sanur" → Sanur Independent School
- Any future school added to the platform will be matched automatically
- No match → validation error (see Step 2 below)

---

## TURN 1 — Intent Detected: Send Welcome + Registration Form

When registration intent is detected:

### Step 1 — Check if already registered

GET `https://schoolcatering.gaiada1.online/api/v1/public/lookup-name?phone=SENDER_PHONE`

If `found: true` → reply (single message):
```
You already have an account on Blossom School Catering. 😊

Log in anytime at https://blossomcatering.online/

Need help? Contact your school admin.
```
Stop here.

### Step 2 — Return the combined message to Brian

CRITICAL: Do NOT call any message send tool (e.g. message_send, whatsapp_send, or any send action).
Your text output is returned to Brian who relays it as the WhatsApp message.
Just return the following text — nothing else, no commentary, no report header.

Return this exactly:

```
🌸 *Welcome to Blossom School Catering!*

Blossom makes school meal ordering simple — register once, order anytime, from the web or WhatsApp.

━━━━━━━━━━━━━━━
🖥️ *Website*
• Browse daily menus by session
• Place & manage orders for your children
• Upload payment proof & download receipts
• Full order history with quick reorder
• Manage your family and linked students

👉 https://blossomcatering.online/

━━━━━━━━━━━━━━━
💬 *WhatsApp (that's me!)*
• 🍽️ Place or cancel orders
• 📋 Check today's meals
• 📅 Bulk order for the week or month
• 🔔 Daily morning order reminders
• 📝 Register a new family account

━━━━━━━━━━━━━━━
To register your family on WhatsApp, fill in and reply with the form below 👇

Family or Group name *:
Parent first name *:
Email *:
Password *:
Parent Phone *:

--- Student 1 --- (copy block for more students)
First name *:
Gender (M/F) *:
Birthday (DD/MM/YYYY) *:
School [Bali Island School / Sanur Independent School] *:
Grade (G1-G12) *:
Student Phone (optional):
Allergies *: none

━━━━━━━━━━━━━━━
📋 *Guide*
📧 Email — valid address e.g. name@gmail.com
🔒 Password — min 6 chars, must include uppercase, lowercase, number & symbol e.g. Mango#22
📱 Phone — include country code e.g. +628123456789

Or register on the web with more options:
https://blossomcatering.online/
```

## TURN 2 — Template Received: Parse, Validate, Confirm

### Step 1 — Fetch live school list

```
curl -s https://schoolcatering.gaiada1.online/api/v1/auth/register/schools
```

Store as `SCHOOL_LIST` for fuzzy matching in validation.

### Step 2 — Parse fields

Extract from the message:

**Parent fields:**
- `parentLastName` ← Family or Group name
- `parentFirstName` ← Parent first name
- `parentEmail` ← Email
- `password` ← Password
- `parentMobileNumber` ← Parent Phone (if blank, use SENDER_PHONE)

**Per student block** (repeat for each `--- Student N ---` block):
- `youngsterFirstName` ← First name
- `youngsterGender` ← Gender (M → MALE, F → FEMALE)
- `youngsterDateOfBirth` ← Birthday (convert DD/MM/YYYY → YYYY-MM-DD)
- `youngsterSchoolId` ← School name → fuzzy match against SCHOOL_LIST → store UUID
- `youngsterSchoolName` ← Matched school display name (for confirmation summary)
- `youngsterGrade` ← Grade
- `youngsterPhone` ← Student Phone (optional — omit if blank)
- `youngsterAllergies` ← Allergies (default "none" if blank)

`registrantType` = `"PARENT"` (hardcoded)

### Step 3 — Validate locally

Check each rule. Collect ALL errors before replying — do not stop at first error.

**Email:**
- Must contain `@` and a `.` after `@`
- Error: `📧 Email is not valid — e.g. name@gmail.com`

**Password:**
- Length 6–100 characters → Error: `🔒 Password must be 6 to 100 characters`
- No spaces → Error: `🔒 Password must not contain spaces`
- At least one lowercase letter → Error: `🔒 Password must include a lowercase letter`
- At least one uppercase letter → Error: `🔒 Password must include an uppercase letter`
- At least one number → Error: `🔒 Password must include a number`
- At least one symbol (non-alphanumeric) → Error: `🔒 Password must include a symbol e.g. ! @ # $`
- Not one of: password, password123, 12345678, 123456789, qwerty123, admin123 → Error: `🔒 Password is too common — please choose a stronger one`

**Phone (parent and student if provided):**
- Must start with `+` followed by digits only, minimum 10 digits total
- Error: `📱 Phone number must include country code e.g. +628123456789`

**School (per student):**
- Must fuzzy-match to an entry in SCHOOL_LIST
- Error: `🏫 Student {N} school not recognised — please check the school name`

**Per-student required fields:**
- First name, gender, birthday, school, grade must all be present
- Error: `⚠️ Student {N} is missing: {list of missing fields}`

**Student count:**
- Must be 1–5
- Error: `⚠️ Please register between 1 and 5 students`

### Step 4 — If validation errors found

Reply listing all errors, ask to re-send only the corrected fields:

```
❌ A few things need fixing before I can register:

{list each error on its own line}

Please reply with just the corrected fields, e.g.:
Password: NewPass#99
Student 1 School: Bali Island School
```

Do NOT save a state file. Do NOT proceed.

### Step 5 — If all valid: save state file

Write state file to `/opt/.openclaw-bsc/memory/registration_{SENDER_PHONE_DIGITS}.json`
Follow the schema in SKILL-BSC-REGISTER-STATE.md.

### Step 6 — Return confirmation summary to Brian

CRITICAL: Do NOT output any "Task Completed" report, "What the main agent should know", or any internal commentary.
Do NOT call any message send tool.
Your ENTIRE response must be ONLY the confirmation text below — nothing before it, nothing after it.

Return this exactly (fill in the values):

```
✅ Please review before I register your family:

👨‍👩‍👧 Family: {parentLastName}
👤 Parent: {parentFirstName} {parentLastName}
📧 Email: {parentEmail}
📱 Phone: {parentMobileNumber}
🔒 Password: set ✓

🎓 Student 1 — {youngsterFirstName} {parentLastName}
   Gender: {Male/Female}
   Birthday: {DD Mon YYYY}
   School: {youngsterSchoolName}
   Grade: {grade}
   Allergies: {allergies}

{repeat for each student}

Reply *YES* to register or *NO* to cancel.
```

---

## TURN 3A — Parent replies YES: Submit

### Step 1 — Read state file
Read `/opt/.openclaw-bsc/memory/registration_{PHONE}.json`
Check expiry — if expired, delete file and reply:
> ⏰ Your registration session has expired. Please send the registration form again to start over.

### Step 2 — Call registration API

```
curl -s -X POST https://schoolcatering.gaiada1.online/api/v1/auth/register/youngsters \
  -H "Content-Type: application/json" \
  -d '{FULL PAYLOAD FROM STATE FILE}'
```

No auth token required — this is a public endpoint.

### Step 3 — On success

Delete state file.

Reply:
```
🎉 Welcome to Blossom School Catering, {parentFirstName}!

Your family account has been created.

👤 Your login username: {parentUsername}
🎓 Student username(s):
   • {student1FirstName}: {student1Username}
   {repeat for each student}

🔒 Use the password you set to log in.

Manage orders and view the full menu at:
https://blossomcatering.online/

Enjoy! 🍽️
```

### Step 4 — On API error

Keep state file (allow retry on YES again).

Map error to friendly message:

| API error | Reply |
|---|---|
| `phone.*already.*registered` or `phone.*unique` | ❌ That phone number is already registered. Log in at https://blossomcatering.online/ or contact support. |
| `email.*already.*registered` or `email.*unique` | ❌ That email address is already in use. Please reply with a different email: `Email: new@email.com` |
| `password.*policy` or `password.*weak` | ❌ Password does not meet requirements. Please reply with a stronger password: `Password: NewPass#99` |
| `school.*not found` | ❌ One of the schools was not recognised. Please check and reply with the school name again. |
| `Missing required` | ❌ Some required fields are missing. Please send the registration form again. |
| anything else | ❌ Registration failed — {raw API message}. Please try again or visit https://blossomcatering.online/ |

---

## TURN 3B — Parent replies NO: Cancel

Delete state file.

Reply:
```
Registration cancelled. No account was created.

If you'd like to register later, just say "register" and I'll send the form again. 😊
```

---

## Stale File Handling

If parent triggers registration intent (Turn 1) but a valid non-expired state file already exists:

Reply:
```
🔄 You have a registration waiting for confirmation.

Reply *YES* to complete it or *NO* to cancel and start fresh.
```

---

## Rules

- Always send Message 1 (welcome guide) BEFORE Message 2 (registration form) — two separate messages
- Never echo the password back in any reply or confirmation summary — always show `set ✓`
- Never expose internal field names, UUIDs, or API paths in replies
- Never call the registration API without a confirmed YES from the sender
- State files are temporary — always delete after use (success, cancel, or expiry)
- `registrantType` is always `PARENT` for WhatsApp registrations
- Parent phone defaults to SENDER_PHONE if not provided in the template
- Student phone defaults to parent phone server-side if omitted — do not add it to the payload if blank
- School list is always fetched live at Turn 2 — never hardcode school UUIDs
- Follow SOUL.md output rules at all times — plain, direct, no internal reasoning in reply
