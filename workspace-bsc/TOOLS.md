# TOOLS.md - Local Notes

Skills define how tools work. This file is for your specifics.

## BSC — Blossom School Catering

API Base: `http://34.158.47.112/schoolcatering/api/v1`
Site: `http://34.158.47.112/schoolcatering/`
Quick Order Page: `http://34.158.47.112/schoolcatering/tools/quick-order`

### Agent Account
- Username: `admin`
- Password: `Teameditor@123`
- Role: `ADMIN`

### How to Handle Orders
- ALWAYS execute `SKILL-BSC-AUTHENTICATE.md` first for any BSC operation.
- Use `SKILL-BSC-ORDER.md` for placing orders.
- Use `SKILL-BSC-DELETE-ORDER.md` for deleting orders.
- Use `SKILL-BSC-LOOKUP-PROTOCOL.md` for checking the user's name, linked students, or daily orders.
- Use `SKILL-BSC-ACTIVE-MENU.md` for menu queries.
- The browser Add buttons are not automation-friendly. Use the API.

### Key Endpoints
| Action | Method | Path |
|---|---|---|
| Login | POST | `/auth/login` |
| Place order | POST | `/order/quick` |
| Delete order | DELETE | `/orders/:orderId` |
| Get family students by parent phone | GET | `/admin/family-students?phone=PHONE` |
| Get daily orders by phone/date | GET | `/orders/daily?date=YYYY-MM-DD&phone=PHONE` |
| Public name lookup | GET | `/public/lookup-name?phone=PHONE` |
| Public active menu lookup | GET | `/public/menu?session=SESSION` |

### Daily Order Retrieval
- Use `/orders/daily` only for dated order retrieval.
- Do not use `/orders/daily` to infer the full linked student roster.

### Token Handling
- Login returns `accessToken`.
- Use it as `Authorization: Bearer <token>`.
- If you get 401, re-login and retry once.

### Admin Delete Order Capability
- Admin can delete orders for operational management.
- Brian must require an explicit `yes` confirmation before calling `DELETE /orders/:orderId`.

### Quick Order Sender Authorization
- `/order/quick` requires Brian to send `senderPhone` in the JSON body for WhatsApp-driven orders.
- Parent-family resolution must use `GET /admin/family-students?phone=PHONE`.
- The BSC server handles authorization dynamically.
- Registered parents can order only for their linked students.
