# OpenClaw Cockpit: Quick Reference

## 🛠️ System Maintenance

### Restarting the Gateway
If you have updated any workspace files (e.g., `IDENTITY.md`, `SKILL-*.md`, `TOOLS.md`) and want the agents to immediately recognize the changes, run:

```bash
openclaw gateway restart
```

*   **What it does:** Forces the OpenClaw service to reload its configuration and all agent workspace files.
*   **Why use it:** This is the standard, **safe** way to apply updates.
*   **What stays intact:** Your WhatsApp/channel logins (creds), active sessions (memory), and the contents of your workspace folders are all preserved.

---

### ⚠️ Warning: Reset vs. Restart

**Do NOT use `openclaw reset` for regular updates.**

*   `openclaw reset` is the **"nuclear option"**.
*   It will **disconnect your WhatsApp session**, requiring you to scan the QR code again.
*   Depending on the scope, it may **wipe your agent sessions, memories, and configurations**.
*   Only use `reset` if you are performing a fresh installation or need to completely purge the system's state.

---

## 📈 Monitoring & Health

### Check System Status
To see if your agents and channels are connected and healthy:

```bash
openclaw gateway status
```

### View Live Logs
To see what your agents are thinking and doing in real-time:

```bash
openclaw logs
```
