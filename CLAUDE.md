# AI Agent Guide

This file provides guidance to AI coding assistants (Claude Code, Cursor, Copilot, Gemini, etc.) when working with this repository.

## Project Overview

**ai_project_index** is a framework for creating structured TOML-based codebase indices that reduce AI token consumption and improve context routing. Instead of reading many source files, AI assistants read compact TOML snapshots of architecture and module structure.

Repository: `github.com/keitheis/ai_project_index`

## Repository Structure

```
activate.sh                        # Bash initialization script (supports curl|bash and local execution)
templates/
├── ai_project_index.toml          # Template: main project index
├── INIT.md                        # Template: AI analysis instructions (one-time setup guide)
└── module.toml                    # Template: per-module index
CLAUDE.md / AGENTS.md / GEMINI.md  # This file (kept in sync)
README.md                          # User-facing documentation
.cursor/rules/                     # Cursor IDE development rules
```

This is a small, self-contained project with **no build system, no tests, and no dependencies**. Do not introduce any.

## How It Works

1. User runs `activate.sh` in their project directory
2. Script creates `ai_project_index/` folder with `modules/` subdirectory
3. Script prompts for root folder(s) to analyze, substitutes into templates
4. User asks their AI assistant to read `INIT.md` and populate the TOML files
5. The resulting TOML files serve as a navigational map for future AI interactions
6. `INIT.md` is deleted after setup — it's a one-time guide

## Key Concepts

### Context Loading (New)
The `[context_loading]` section in `ai_project_index.toml` acts as a routing table — it tells AI agents which files to read for different task types (bug fixes, new features, refactors). This minimizes context while maximizing relevance.

### Boundaries (New)
The `[boundaries]` section documents architectural invariants that AI must not violate, regardless of the task. This prevents AI from making structurally harmful changes.

### Context Budget
Every line in TOML index files costs tokens in every future AI session. Templates and instructions emphasize conciseness — prefer one clear sentence over a paragraph.

## Key Conventions

- Templates use `{{PLACEHOLDER}}` syntax (double curly braces, UPPER_SNAKE_CASE), replaced via `sed` in `activate.sh`
- Current placeholders: `{{PROJECT_NAME}}`, `{{ROOT_FOLDERS}}`, `{{MODULE_NAME}}`
- The TOML format uses `[meta]`, `[[component]]` arrays, `[dependencies]`, `[usage]`, `[context_loading]`, `[boundaries]`, and `[testing]` sections
- Module TOML files go in `ai_project_index/modules/{module_name}.toml`
- The framework is language-agnostic — component types (`[[model]]`, `[[service]]`, etc.) adapt to the target project

## Development Rules

- `activate.sh` must support both `curl | bash` piped execution and local clone usage — always preserve both code paths
- `sed` commands must be BSD-compatible (macOS baseline) — use pipe delimiters `s|pattern|replacement|g`
- When reading user input in piped mode, read from `/dev/tty`
- CLAUDE.md, AGENTS.md, and GEMINI.md share identical content — update all three together
- Version is tracked in the `VERSION` variable at the top of `activate.sh`

## Common Tasks

### Adding a new section to the TOML template
1. Add the section with comments/examples to `templates/ai_project_index.toml`
2. Update `templates/INIT.md` to guide AI through filling it in
3. Update `README.md` Key Concepts section
4. Update `.cursor/rules/templates.mdc` section list

### Modifying activate.sh
1. Test both execution modes: local (`./activate.sh`) and piped (`cat activate.sh | bash`)
2. Ensure `sed` commands work on macOS (BSD sed)
3. Maintain the existing color output helpers
