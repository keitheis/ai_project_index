# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**ai_project_index** is a framework for creating structured TOML-based codebase indices that reduce AI token consumption. Instead of reading many source files, AI assistants read compact TOML snapshots of architecture and module structure.

Repository: `github.com/keitheis/ai_project_index`

## Repository Structure

This is a small, self-contained project with no build system or tests:

- `activate.sh` — Bash initialization script that sets up `ai_project_index/` in a target project. Supports both `curl | bash` piped execution and local clone usage. Includes validation hints and improved error handling.
- `validate.sh` — TOML validation script for checking syntax and structure of generated index files.
- `templates/ai_project_index.toml` — Template for the main project index file (schema v2.0, uses `{{PROJECT_NAME}}` and `{{ROOT_FOLDERS}}` placeholders)
- `templates/INIT.md` — Template for AI analysis instructions (uses `{{ROOT_FOLDERS}}` placeholder, includes structured thinking and chain-of-thought guidance)

## How It Works

1. User runs `activate.sh` in their project directory
2. Script creates `ai_project_index/` folder with `modules/` subdirectory
3. Script prompts for root folder(s) to analyze, substitutes into templates
4. User then asks their AI assistant to read `INIT.md` and populate the TOML files
5. The resulting TOML files serve as a "map" of the codebase for future AI interactions

## Key Conventions

- Templates use `{{PLACEHOLDER}}` syntax, replaced via `sed` in `activate.sh`
- The TOML format uses schema version 2.0 with `[meta]`, `[[component]]` arrays, `[dependencies]`, `[usage]`, and `[ai_context]` sections
- Module TOML files go in `ai_project_index/modules/{module_name}.toml`
- The framework is language-agnostic — component types (`[[model]]`, `[[service]]`, etc.) adapt to the target project
- Schema includes versioning, timestamps, and complexity indicators for better AI understanding

## Recent Improvements (v2.0)

- **Enhanced TOML Schema**: Added version tracking, timestamps, complexity indicators, and AI context hints
- **Structured Thinking**: INIT.md now includes chain-of-thought reasoning and structured discovery phases
- **Validation Tool**: New `validate.sh` script for checking TOML syntax and structure
- **Better Documentation**: Improved README with validation steps, modern AI practices, and troubleshooting
- **AI Integration**: Added `.cursorrules` for better IDE integration
