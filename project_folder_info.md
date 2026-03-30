# Project Folder Information: OpenClaw

This document provides an overview of the `openclaw` project structure and its components.

## Core Overview
OpenClaw is a multi-agent AI system designed to assist a human user named **Roger**. It integrates with various communication channels (primarily WhatsApp) and uses a set of specialized agents to handle different domains.

## Directory Structure

### Root Directory: `~/.openclaw/`
Contains the main configuration and subdirectories for the system.

- `openclaw.json`: The central configuration file defining agents, channels (WhatsApp), browser settings, and gateway auth.
- `update-check.json`: Likely tracks version updates.

### Agents and Workspaces
The system defines four primary agents, each with its own workspace:

1.  **Michael (ID: `main`)**
    - **Role:** General agent, AI operator.
    - **Vibe:** Polished, high-trust, calm under pressure.
    - **Workspace:** `workspace-main/`
2.  **Brian (ID: `bsc`)**
    - **Role:** Specialist (likely related to BSC/Business/Orders based on workspace filenames).
    - **Workspace:** `workspace-bsc/`
3.  **Zack (ID: `zen`)**
    - **Role:** Specialist (likely related to Zen/Uploads/Zenbali API).
    - **Workspace:** `workspace-zen/`
4.  **Casey (ID: `mna`)**
    - **Role:** Specialist (likely related to M&A/Dataroom).
    - **Workspace:** `workspace-mna/`

### Workspace Components
Each workspace (e.g., `workspace-main/`) follows a standard structure:

- `AGENTS.md`: General instructions for the agent (memory usage, behavior in group chats, heartbeats).
- `IDENTITY.md`: Defines the agent's name, role, and operating stance.
- `SOUL.md`: Describes the agent's "personality," core truths, and "vibe."
- `USER.md`: Information about the human user (Roger).
- `TOOLS.md`: Local notes on tools and skills.
- `MEMORY.md`: Long-term curated memory.
- `memory/`: Directory for daily logs (`YYYY-MM-DD.md`) and state files.

### Communication Channels
- **WhatsApp:** The primary channel. Configuration is handled in `openclaw.json` under `channels.whatsapp`.
- `credentials/whatsapp/`: Stores session data and authentication keys for WhatsApp.

### Data and Storage
- `media/`: Symbolic link to `/mnt/support_disk/openclaw-media`, likely for storing images/videos received or processed.
- `memory/`: Stores agent-specific SQLite databases for vector memory or other structured data.

### System Components
- `agents/`: Contains internal agent definitions and session logs.
- `browser/`: Stores user data for the headless browser used by agents.
- `plugins/`: Includes MCP (Model Context Protocol) tools, like `mcp-tools`.

## Key Concepts

### Heartbeats
The `HEARTBEAT.md` file in each workspace allows agents to perform periodic, proactive tasks (e.g., checking for new orders) rather than just reacting to user messages.

### Personas and "Soul"
Agents are treated as "becoming someone" rather than just chatbots. Their `SOUL.md` and `IDENTITY.md` files guide their tone, opinions, and boundaries.
