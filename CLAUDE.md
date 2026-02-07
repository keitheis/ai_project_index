# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**ai_project_index** is a framework for creating structured TOML-based codebase indices. These indices serve as navigational maps for AI coding assistants — reducing token usage, preventing hallucination, and enabling safer changes through documented boundaries and gotchas.

Repository: `github.com/keitheis/ai_project_index`

## Repository Structure

This is a small, self-contained project with no build system, no tests, and no dependencies:

- `activate.sh` — Bash initialization script that sets up `ai_project_index/` in a target project. Supports both `curl | bash` piped execution and local clone usage. Run with `--help` for usage info.
- `templates/ai_project_index.toml` — Template for the main project index file (uses `{{PROJECT_NAME}}` and `{{ROOT_FOLDERS}}` placeholders)
- `templates/INIT.md` — Template for AI analysis instructions (uses `{{ROOT_FOLDERS}}` placeholder)

## How It Works

1. User runs `activate.sh` in their project directory
2. Script creates `ai_project_index/` folder with `modules/` subdirectory
3. Script prompts for root folder(s) to analyze, substitutes placeholders into templates
4. User asks their AI assistant to read `INIT.md` and populate the TOML files
5. The resulting TOML files serve as a hierarchical map: `ai_project_index.toml` → `modules/*.toml` → source files

## Key Conventions

- Templates use `{{PLACEHOLDER}}` syntax, replaced via `sed` in `activate.sh`
- The TOML format uses `[meta]`, `[meta.tech]`, `[boundaries]`, `[gotchas]`, `[change_risk]`, `[[component]]` arrays, `[dependencies]`, and `[usage]` sections
- Module TOML files go in `ai_project_index/modules/{module_name}.toml`
- The framework is language-agnostic — component types (`[[model]]`, `[[service]]`, etc.) adapt to the target project

## Design Principles

- **Lean by default** — every token in the index must earn its place
- **Boundaries over details** — architectural rules prevent bugs
- **Hierarchical navigation** — orient at project level, drill into modules as needed
