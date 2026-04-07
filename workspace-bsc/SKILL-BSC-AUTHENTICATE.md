# SKILL-BSC-AUTHENTICATE.md — Sender Identity & Authorization

This skill is the single entry point for sender identity resolution and authorization.
All other SKILL-BSC-* skills must call this skill's protocol first before any operational action.

## Purpose

Resolve sender identity from sender phone number and, for parent numbers, resolve the full linked student roster from the BSC API.

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

- URL: `http://34.158.47.112/schoolcatering/api/v1/public/lookup-name?phone=SENDER_PHONE`
- Method: `GET`

Extract:
- `SENDER_NAME`
- `SENDER_USERNAME`
- `SENDER_ROLE`
- `SENDER_FIRST_NAME`

## Step 4 — Parent Family Lookup

If `SENDER_ROLE` is `PARENT`, or if you need to know which students are linked to this parent phone:

1. Login:
   - URL: `http://34.158.47.112/schoolcatering/api/v1/auth/login`
   - Method: `POST`
   - Body: `{"username":"admin","password":"Teameditor@123"}`
2. Call:
   - URL: `http://34.158.47.112/schoolcatering/api/v1/admin/family-students?phone=SENDER_PHONE`
   - Method: `GET`
   - Headers: `{"Authorization":"Bearer TOKEN_HERE"}`

The family-students response is the source of truth for parent-to-student linking.
Never infer a parent's linked students from `/orders/daily`.

Store:
- `LINKED_STUDENTS_COUNT`
- `LINKED_STUDENTS` — array of `{name, firstName, username, phone}`

If the family lookup returns `found: true`, treat that roster as authoritative even when only some children have orders for a specific date.

## Step 5 — Return Authentication Result

Return:

```text
SENDER_PHONE: +62...
SENDER_NAME: Anthony Syrowatka
SENDER_FIRST_NAME: Anthony
SENDER_USERNAME: syrowatka_dewi
SENDER_ROLE: PARENT | CHILD
IS_SUPERUSER: true | false
LINKED_STUDENTS_COUNT: 0..n
LINKED_STUDENTS: [{name, firstName, username, phone}, ...]
```

## Failure Handling

- If public lookup returns `found: false` and sender is not the superuser:
  Reply: `I could not find your identity in the BSC system.`
- If family lookup fails for a parent, do not invent student names. Continue only with the identity you actually resolved.

## Rules

- Never use the sender's phone contact name for greetings.
- Always use the exact name returned by the API lookup.
- For parent family membership, always use `/admin/family-students`.
- Never infer family membership from `/orders/daily`.
