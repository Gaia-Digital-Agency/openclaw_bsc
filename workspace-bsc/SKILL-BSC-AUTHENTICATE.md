# SKILL-BSC-AUTHENTICATE.md — Sender Identity & Authorization

This skill is the single entry point for sender identity resolution and authorization.
All other SKILL-BSC-* skills must call this skill's protocol first before any operational action.

## Purpose

Resolve sender identity from sender phone number and then resolve the sender's full family scope from the BSC API.

**Phone number is the primary identifier.** Every inquiry is authenticated by `SENDER_PHONE`. A user without a registered phone cannot be authenticated and cannot inquire through Brian. In particular, a youngster can only inquire on their own behalf when their own distinct phone number was keyed at registration (`Student Phone` in the registration form). If the student phone was left blank at registration, the server falls back to the parent's phone — messages from the parent's phone resolve to the parent as `SENDER_ROLE=PARENT`, not to the student. This is expected behaviour.

## Trigger

This skill is triggered internally by every other SKILL-BSC-* skill. It is not triggered directly by user phrases.

## Step 1 — Extract Sender Phone

Extract `SENDER_PHONE` from the sender metadata provided in the message.
Format: E.164, for example `+6281138210188`.

## Step 2 — Check Superuser

If `SENDER_PHONE` matches `+6281138210188`, the sender is the system superuser.

Superuser privileges:
- Can query orders for any user
- Can create orders for any student
- Can delete any order
- Can view orders for all users

Still perform the lookup in Step 3 for greeting name, but authorization checks are bypassed.

## Step 3 — Identity Lookup

Call the public lookup endpoint:

- URL: `https://schoolcatering.gaiada1.online/api/v1/public/lookup-name?phone=SENDER_PHONE`
- Method: `GET`

Extract:
- `SENDER_NAME`
- `SENDER_USERNAME`
- `SENDER_ROLE`
- `SENDER_FIRST_NAME`

## Step 4 — Family Lookup

Always resolve the sender's family scope after Step 3, even if the sender is a youngster or the second parent phone.

1. Login:
   - URL: `https://schoolcatering.gaiada1.online/api/v1/auth/login`
   - Method: `POST`
   - Body: `{"username":"admin","password":"Teameditor@123"}`
2. Call:
   - URL: `https://schoolcatering.gaiada1.online/api/v1/admin/family-context?phone=SENDER_PHONE`
   - Method: `GET`
   - Headers: `{"Authorization":"Bearer TOKEN_HERE"}`

The family-context response is the source of truth for family membership.
It is backed by the server-side `family_id` model.
Never infer family membership from surnames, `/admin/parents`, `/admin/children`, or `/orders/daily`.

Store:
- `FAMILY_ID`
- `LINKED_STUDENTS_COUNT`
- `LINKED_STUDENTS` — array of `{name, firstName, username, phone}`
- `LINKED_PARENTS` — array of `{name, phone, username?}`

If the family lookup returns `found: true`, treat that roster as authoritative even when only some children have orders for a specific date.

## Step 5 — Return Authentication Result

Return:

```text
SENDER_PHONE: +62...
SENDER_NAME: Anthony Syrowatka
SENDER_FIRST_NAME: Anthony
SENDER_USERNAME: syrowatka_dewi
SENDER_ROLE: PARENT | YOUNGSTER
IS_SUPERUSER: true | false
FAMILY_ID: uuid
LINKED_STUDENTS_COUNT: 0..n
LINKED_STUDENTS: [{name, firstName, username, phone}, ...]
LINKED_PARENTS: [{name, phone, username}, ...]
```

## Failure Handling

- If public lookup returns `found: false` and sender is not the superuser:
  Reply: `I could not find your identity in the BSC system.`
  Do NOT hint that the user might be a student whose phone was not registered — just return the generic not-found reply.
- If family lookup returns `found: false`, do not invent family members. Continue only with the identity you actually resolved.

## Rules

- Never use the sender's phone contact name for greetings.
- Always use the exact name returned by the API lookup.
- Always use `/admin/family-context` for family membership.
- Never infer family membership from surnames or `/orders/daily`.
- **Phone is the primary identifier.** Never identify a user by name, username, or any non-phone attribute at authentication time.
- **A youngster without their own registered phone cannot be authenticated as a youngster.** Messages from a phone that resolves to a parent are handled as parent inquiries; the parent can still ask about a specific child by name in the downstream skills.
- **Never return this skill's documentation as a response.** You must EXECUTE each step (make the API calls) and return only the resolved authentication result from Step 5. Reading this file is not the same as executing it.
- **Never tell the user whether they are a superuser or not.** Superuser status is an internal authorization flag only — never mention it in user-facing replies.
