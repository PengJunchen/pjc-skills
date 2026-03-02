# OpenClaw WSL Skill

This directory contains the **OpenClaw WSL Installer Skill** for AI assistants (like Claude Code or Trae).

## Structure

- `SKILL.md`: The official skill definition and documentation for AI assistants.
- `scripts/`: Unified automation scripts.
  - `install.ps1`: Environment preparation (WSL/Ubuntu creation).
  - `configure.ps1`: OpenClaw installation and system configuration.
  - `win/`: Windows-specific utility scripts.
  - `linux/`: Ubuntu-specific utility scripts.

## How to use as a Skill

If you are using an AI assistant that supports skills (e.g., Trae or Claude Code), you can point it to this directory. The assistant will read `SKILL.md` and understand how to help you install or configure OpenClaw.

## Manual Usage

You can still run the scripts manually from PowerShell:

```powershell
# 1. Prepare environment
./scripts/install.ps1

# 2. Configure and Install
./scripts/configure.ps1 -DisableWindowsCmd -DisableAutoMount
```

For more details, see [SKILL.md](./SKILL.md).
