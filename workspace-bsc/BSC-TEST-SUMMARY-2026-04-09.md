# Brian (BSC) Test Results — 2026-04-09

## Overall: 25/26 PASS (96%)

| Category | Pass | Fail | Score |
|----------|------|------|-------|
| STARTER | 6 | 1 | 86% |
| MENU | 7 | 0 | 100% |
| ORDER | 7 | 0 | 100% |
| FAMILY ENDPOINTS | 5 | 0 | 100% |
| **TOTAL** | **25** | **1** | **96%** |

---

## STARTER (6/7)

| # | Question | Result | Brian's Answer |
|---|----------|--------|----------------|
| 1 | Hello Brian | ✅ | "Brian. I am your Blossom School Catering assistant." |
| 2 | Whats your name | ❌ | Lost during gateway restart cycle |
| 3 | Whats my name | ✅ | "Your name is studentName01 familyName." |
| 4 | Whats the date today | ✅ | "Today's date is April 9, 2026." |
| 5 | Whats the date tomorrow | ✅ | "Tomorrow's date is 2026-04-10." |
| 6 | Whats Mondays date | ✅ | "Monday's date is 2026-04-13." |
| 7 | Whats following Mondays date | ✅ | "April 20, 2026." |

---

## MENU (7/7)

| # | Question | Result | Brian's Answer |
|---|----------|--------|----------------|
| 1 | Whats in the menu | ✅ | Full listing: Snack (10 items), Lunch (47 items) |
| 2 | Whats on the lunch menu | ✅ | 47 lunch items listed |
| 3 | Whats on the snack menu | ✅ | 10 snack items listed |
| 4 | Whats on the breakfast menu | ✅ | "No breakfast menu available." |
| 5 | All menu with prices | ✅ | Full menu with IDR prices |
| 6 | List all burgers | ✅ | Filtered burger items listed |
| 7 | Order Chicken on Saturday | ✅ | "No meal service on weekends." (correctly refused) |

---

## ORDER (7/7)

| # | Question | Result | Brian's Answer |
|---|----------|--------|----------------|
| 1 | Do I have any orders today? | ✅ | "No orders for you today." |
| 2 | Do I have any orders tomorrow? | ✅ | "No orders for tomorrow." |
| 3 | Do I have any orders next week? | ✅ | "No orders for you next week." |
| 4 | Can you order Chicken for lunch tomorrow? | ✅ | Placed: Chicken Sate, #D7A2561A, Rp 50,000 |
| 5 | Do I have any orders tomorrow? (verify) | ✅ | Confirmed Chicken Sate order |
| 6 | Can you please delete my order for tomorrow? | ✅ | "Successfully deleted Chicken Sate." |
| 7 | Do I have any orders tomorrow? (verify delete) | ✅ | Confirmed no orders |

---

## FAMILY ENDPOINTS (5/5)

| # | Question | Result | Brian's Answer |
|---|----------|--------|----------------|
| 1 | Can I order on weekends? | ✅ | "No, meal service not available on weekends." |
| 2 | Whats my family group name? | ✅ | "familyName" |
| 3 | Who are in my family group? | ✅ | parentName (parent), studentName01 |
| 4 | What school am I in? | ✅ | "Sanur Independent School." |
| 5 | What grade am I? | ✅ | "Grade G9." |

---

## Notes

- **Model Used**: 100% Google Gemini 2.5 Flash (Anthropic Haiku 4.5 credits depleted, all requests fell back to Gemini)
- **The 1 failure** (Q2 "Whats your name") was lost during a gateway restart — not a logic issue
- **Phone number leaks** appeared in early responses but were fixed after SOUL.md update — later responses used "you/your" correctly
- **Weekend policy** failed in early test but passed after SOUL.md service policy addition
- **Delegation**: All MENU, ORDER, and FAMILY questions correctly delegated to Orders subagent via `sessions_spawn`

## Infrastructure

- **Gateway**: OpenClaw v2026.3.28
- **VM**: gda-ai01 (GCP)
- **WhatsApp**: Connected on +6281138210188
- **BSC API**: 34.158.47.112
- **Database**: PostgreSQL `schoolcatering_db`

## Config Changes Made During Session

1. SOUL.md — Added "no phone numbers in replies", "no system field names", weekend service policy
2. SKILL-BSC-LOOKUP-PROTOCOL.md — Added family group and school reply examples, "use you/your" rule
3. SKILL-BSC-ORDER.md — Added "Ambiguous Dish Name Rule" (fetch menu first, ask user to pick)
4. IDENTITY.md (main) — Specified `sessions_spawn` tool explicitly, graceful error fallback
5. Model config — Changed from Haiku primary to Gemini Flash primary, Sonnet 4 fallback
