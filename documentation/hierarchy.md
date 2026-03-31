# OpenClaw Workspace Hierarchy

This document defines the logical hierarchy of execution and influence for the markdown files within an OpenClaw agent's workspace. When an agent receives a message or task, it processes its configuration files in the following order of priority:

## 1. IDENTITY.md & SOUL.md (The Core Directives)
*   **Priority:** Absolute / Highest.
*   **Function:** These are the immutable laws of the agent. They define the agent's name, role (e.g., M&A Specialist vs. Catering Assistant), and fundamental boundaries.
*   **Constraint:** If a user request contradicts these files, the agent must refuse it. These act as the ultimate guardrails for the agent's persona and purpose.

## 2. MEMORY.md & USER.md (Context & Rules of Engagement)
*   **Priority:** High-Priority Context.
*   **Function:** These files contain the negotiated rules for *how* the agent interacts with the user (e.g., "keep responses concise," "always use the ♾️ emoji") and who the authorized user is (e.g., Roger).
*   **Influence:** They heavily dictate the style, tone, and formatting of the output, but they cannot override the fundamental identity established in Level 1.

## 3. TOOLS.md & SKILL-*.md (Capabilities & Execution)
*   **Priority:** Functional / Action-Oriented.
*   **Function:** These define *what* the agent can actually do (its actions). They provide the step-by-step instructions for completing permitted tasks (e.g., looking up an order, digesting a dataroom).
*   **Logic:** The agent will only "read" or execute a specific skill file if the request has already passed the filters of its Identity and Memory.

## 4. AGENTS.md (Routing & Group Dynamics)
*   **Priority:** Behavioral Modifier.
*   **Function:** This governs how the agent behaves in the presence of *other agents* or within a WhatsApp group chat.
*   **Purpose:** It dictates when the agent should speak, when it should stay silent, and how it should interact with its peers (Brian, Zack, Casey, Michael).

## 5. HEARTBEAT.md (Asynchronous / Background Tasks)
*   **Priority:** Out-of-Band.
*   **Function:** This file is read by the system on a timer (cron) to trigger proactive, background actions.
*   **Note:** It does not influence the direct conversational flow between the user and the agent; it operates entirely in the background.

---

### Workspace Isolation Rule
Agents operate in strict isolation. An agent (e.g., Casey in `workspace-mna`) **cannot** read or influence the files in another agent's workspace (e.g., Brian in `workspace-bsc`). The only point of convergence is the central `openclaw.json` router.
