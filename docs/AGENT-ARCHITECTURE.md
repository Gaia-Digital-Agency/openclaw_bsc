# Agent Architecture

Brian is a multi-agent AI system built on OpenClaw.

## Agents

| Agent | ID | Workspace |
|-------|----|-----------|
| **Brian** | main | workspace-main |
| **Orders** | orders | workspace-bsc |

## Delegation

Brian (main) delegates to: orders

## Configuration

- State dir: `/opt/.openclaw-bsc`
- Config: `/opt/.openclaw-bsc/openclaw.json`
- Gateway port: ?
- Model: deepseek/deepseek-chat (fallback: google/gemini-2.5-flash)

## Workspace Structure

Each agent workspace follows:

```
workspace-{agent}/
  IDENTITY.md      -- Name, role
  SOUL.md          -- Voice and output rules
  USER.md          -- Owner context
  TOOLS.md         -- Available tools
  SKILLS.md        -- Skill index
  SKILL-*.md       -- Specific workflows
```
