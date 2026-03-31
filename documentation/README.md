# OpenClaw: Multi-Agent AI System

This document provides a comprehensive overview of the `openclaw` project structure, its components, and its current operating state.

## Core Overview

OpenClaw is an advanced multi-agent AI framework designed to act as a collaborative, multi-domain system assisting a human user (Roger). It seamlessly integrates with various communication channels—primarily WhatsApp—to execute tasks, respond to queries, and proactively monitor external conditions through specialized agents.

## System Architecture & Directory Structure

The repository is built around distinct agents, workspaces, delivery queues, and system endpoints.

### 1. Agents and Workspaces

The system orchestrates four primary agents, each operating within its own dedicated workspace subdirectory:

*   **Michael (`workspace-main/` & `workspace-default/`)**
    *   **Role:** General Agent & AI Operator.
    *   **Vibe:** Polished, high-trust, calm under pressure.
    *   **Key Files:** Contains foundational setup like `BOOTSTRAP.md` and core agent runtime data.
*   **Brian (`workspace-bsc/`)**
    *   **Role:** Specialist for BSC / Business Operations / Orders.
    *   **Key Skills:** `SKILL-BSC-ORDER.md`, `SKILL-BSC-DELETE-ORDER.md`, `SKILL-BSC-LOOKUP-PROTOCOL.md`, `SKILL-BSC-NOTIFICATION-CONTROL.md`.
*   **Casey (`workspace-mna/`)**
    *   **Role:** Specialist for Mergers & Acquisitions (M&A) and Dataroom operations.
    *   **Key Skills:** `SKILL-CASEY-MNA.md`, `SKILL-CASEY-DATAROOM.md`, `SKILL-CASEY-COMMUNICATION.md`.
*   **Zack (`workspace-zen/`)**
    *   **Role:** Specialist for the Zenbali API and media uploads.
    *   **Key Skills:** `SKILL_ZEN_UPLOAD.md`, `ZENBALI_API.md`.

### 2. Standard Workspace Components

Each workspace contains markdown files that dictate the behavior, context, and capabilities of its respective agent:

*   `IDENTITY.md`: Defines the agent's name, role, operating stance, and core purpose.
*   `SOUL.md`: Describes the agent's "personality," core truths, "vibe," and boundaries. Agents are treated as *becoming someone* rather than just chatbots.
*   `AGENTS.md`: General instructions for the agent regarding memory usage, group chat behavior, and interactions with other agents.
*   `USER.md`: Information, preferences, and context about the human user (Roger).
*   `TOOLS.md` & `SKILL-*.md`: Definitions of specific, callable tools and specialized skills unique to the agent's domain.
*   `HEARTBEAT.md`: Allows agents to perform periodic, proactive tasks (e.g., polling an API for new orders) rather than just reacting to user messages.
*   `MEMORY.md`: Long-term, curated memory context.
*   `memory/`: Subdirectory for daily logs (e.g., `YYYY-MM-DD.md`) and persistent state files.

### 3. Core System Directories

*   **`agents/`**: Contains internal agent runtime definitions, model configurations (`models.json`), and chat session histories.
*   **`browser/`**: Stores cache and user data for the headless browser used by agents for web automation.
*   **`canvas/`**: Holds HTML endpoints/UI components (e.g., `index.html`).
*   **`completions/`**: Shell auto-completion scripts for the `openclaw` CLI (`bash`, `zsh`, `fish`, `ps1`).
*   **`credentials/`, `devices/`, `identity/`**: Stores critical authentication data, WhatsApp session keys, and device pairing states. (Note: These directories are ignored by Git for security).
*   **`delivery-queue/`**: Manages asynchronous message delivery, capturing pending and `failed/` outgoing messages.
*   **`logs/`**: Centralized application and system logs.
*   **`plugins/`**: External integrations, including MCP (Model Context Protocol) tools and Claude-specific plugins.
*   **`subagents/`**: Manages transient execution data (`runs.json`) for tasks delegated to specialized sub-agents.
*   **`workspace_bak/` & `json_bak/`**: Local backup archives for older workspace states and `openclaw.json` configurations.

### 4. Root Configuration & Utilities

*   **`openclaw.json`**: The central configuration file. Defines agent routing, WhatsApp channel settings, headless browser flags, and gateway authentication.
*   **`schema.json`**: JSON schema validation for configuration files or API structures.
*   **`exec-approvals.json`**: State tracking for commands that require explicit user approval before execution.
*   **`sync-google-auth.sh`**: Utility script to synchronize Google authentication profiles across agents.
*   **`.gitignore`**: Strictly configured to prevent the accidental commit of API keys, WhatsApp session files, memory databases, and ephemeral logs.

## Key Concepts

*   **Multi-Agent Routing:** When a message arrives via WhatsApp (the primary channel), OpenClaw evaluates the request and routes it to the most capable specialist agent (Michael, Brian, Casey, or Zack) based on their configured `IDENTITY` and `SKILLS`.
*   **Proactive Heartbeats:** Unlike passive chatbots, OpenClaw agents use a heartbeat system to asynchronously check systems, evaluate conditions, and notify the user when action is required.
*   **Persistent Memory:** Each agent maintains localized and global memory stores (via SQLite and Markdown files), allowing them to retain deep context about the user's ongoing projects, preferences, and prior conversations.
