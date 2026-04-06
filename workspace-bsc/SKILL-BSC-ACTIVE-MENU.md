# SKILL-BSC-ACTIVE-MENU.md — Active Menu Lookup

Use this skill when Brian asks Orders what dishes are currently available for breakfast, snack, or lunch.

## Trigger Phrases
- "what's for lunch"
- "whats for lunch"
- "what's for snacks"
- "whats for snacks"
- "what's for breakfast"
- "whats for breakfast"
- "what can I order for lunch"
- "what can I order for snacks"
- "what can I order for breakfast"

## Execution Rule
- Use the `fetch` tool.
- Do not use browser automation.
- This is a public endpoint. No login is required.

## Session Mapping
- breakfast -> `BREAKFAST`
- snack / snacks -> `SNACK`
- lunch -> `LUNCH`

## API Call
- **URL:** `http://34.158.47.112/schoolcatering/api/v1/public/menu?session=SESSION`
- **Method:** `GET`

Replace `SESSION` with the mapped session value.

## Expected Result
The API returns:
- `serviceDate`
- `session`
- `items[]`
- `sessionSettings[]`

Read `items[]` and extract the currently active dish names for the requested session.

## Return Format To Brian
Return clean execution output Brian can relay. Keep it concise.

When dishes exist:

```text
LookupName: {verified BSC lookup name if available, otherwise blank}
Session: {SESSION}
AvailableDishes:
- Dish 1
- Dish 2
- Dish 3
```

If no dishes are active:

```text
LookupName: {verified BSC lookup name if available, otherwise blank}
Session: {SESSION}
AvailableDishes: none
```

## Notes
- If the current workflow already requires sender verification, execute `SKILL-BSC-AUTHENTICATE.md` first to resolve sender identity.
- Do not expose raw JSON unless Brian explicitly asks for execution detail.
- The purpose of this skill is to tell Brian which dishes are actively available to order for the requested session.
