# SKILL-BSC-REGISTER-STATE.md — Registration State Protocol

This file defines the state schema and read/write/expire protocol used by SKILL-BSC-REGISTER.md.
Brian is stateless between turns — this file system protocol is the only way to persist partial registration data across the confirmation turn.

---

## State File Location

```
/opt/.openclaw-bsc/memory/registration_{SENDER_PHONE}.json
```

Where `{SENDER_PHONE}` is the E.164 sender phone with `+` replaced by nothing.
Example: sender `+628123456789` → `registration_628123456789.json`

---

## State File Schema

```json
{
  "step": "awaiting_confirmation",
  "created_at": "2026-04-21T10:00:00.000Z",
  "expires_at": "2026-04-21T10:30:00.000Z",
  "sender_phone": "+628123456789",
  "payload": {
    "registrantType": "PARENT",
    "parentFirstName": "",
    "parentLastName": "",
    "parentMobileNumber": "",
    "parentEmail": "",
    "password": "__SET__",
    "students": [
      {
        "youngsterFirstName": "",
        "youngsterGender": "MALE",
        "youngsterDateOfBirth": "YYYY-MM-DD",
        "youngsterSchoolId": "",
        "youngsterGrade": "",
        "youngsterPhone": "",
        "youngsterAllergies": "none"
      }
    ]
  }
}
```

### Field notes
- `step` — always `"awaiting_confirmation"` while waiting for YES/NO
- `expires_at` — set to 15 minutes after `created_at`
- `password` — store the actual password value. Never echo it back in replies. Use `"set ✓"` placeholder only in user-facing summary.
- `youngsterPhone` — if blank or omitted by parent, do not store; API will fall back to parentMobileNumber automatically
- `youngsterGender` — always stored as `"MALE"` or `"FEMALE"` (normalised from M/F)
- `youngsterDateOfBirth` — always stored as `YYYY-MM-DD` (converted from DD/MM/YYYY input)

---

## Write Protocol

After parsing and validating the parent's reply:

1. Build the full JSON payload as per schema above
2. Set `created_at` to current UTC ISO timestamp
3. Set `expires_at` to `created_at + 15 minutes`
4. Write file using bash or python3 to `/opt/.openclaw-bsc/memory/registration_{PHONE_DIGITS}.json`
   IMPORTANT: Do NOT use MCP filesystem write — that path is not served by it. Use bash `python3 -c` or similar.
5. Confirm file written before showing confirmation summary to parent

---

## Read Protocol

When parent replies YES to confirmation:

IMPORTANT: Use bash to read/check/delete state files. Do NOT use MCP filesystem — `/opt/.openclaw-bsc/memory/` is not served by it.

1. Read with bash: `cat /opt/.openclaw-bsc/memory/registration_{PHONE_DIGITS}.json`
   (Strip `+` from phone: `+60126012560` → `60126012560`)
2. Check `expires_at` — if past current time, delete file and reply:
   > ⏰ Your registration session has expired. Please send the registration form again to start over.
3. If valid, extract `payload` and proceed to API call

---

## Delete Protocol

Delete the state file in these cases:
- Parent replies YES and API call succeeds
- Parent replies NO (cancel)
- State file is expired when read

Command:
```
rm /opt/.openclaw-bsc/memory/registration_{PHONE}.json
```

---

## Stale File Safety

Before writing a new state file, check if one already exists for the sender phone.
If it exists and is NOT expired:
> 🔄 You already have a registration in progress. Reply YES to confirm it, NO to cancel and start fresh.

If it exists and IS expired: delete it silently and proceed with the new registration.

---

## Rules

- Never log or echo the password in any reply, summary, or memory file other than the state file
- State files are temporary — always delete after use
- Never use state files for any purpose other than registration
