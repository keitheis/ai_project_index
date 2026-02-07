# AI Analysis Instructions

Welcome! This file guides you through analyzing this codebase and creating a structured index.

**Delete this file** when you finish the analysis — it is a one-time setup guide.

## Objective

Create a **split snapshot** system using TOML files to document this codebase efficiently.

The goal is twofold:
1. **Reduce token usage** — AI reads compact TOML indices instead of many source files.
2. **Route context efficiently** — AI knows *which* files to read for a given task, without scanning everything.

Think of the index as a **map of the codebase**, not a copy of it.

## Analysis Roots

Analyze starting from: **{{ROOT_FOLDERS}}**

(Multiple root folders can be specified to analyze different parts of the codebase separately)

## Context Budget Awareness

When creating the index, keep this principle in mind:

> **Every line in a TOML file will be loaded into an AI's context window in future sessions.**
> Be concise. Every unnecessary line costs tokens across every future interaction.

Guidelines:
- Prefer **one clear sentence** over a paragraph
- Skip obvious information (e.g., don't document that `main.py` is the main file if the convention is clear)
- Focus on information that **saves the AI from reading source files**
- Remove all template comments and unused sections from your output

## Step-by-Step Process

### 1. Understand the Project Structure

Explore the codebase to understand:
- What programming language(s) are used?
- What framework(s) or libraries are central?
- How is the code organized? (monolith, modules, features, domains)
- What are the main entry points?
- What are the key external dependencies?

**Action:** Read key files like:
- README.md (if exists)
- Package/dependency files (package.json, requirements.txt, go.mod, Cargo.toml, pubspec.yaml, etc.)
- Main entry point files
- Directory structure

### 2. Update ai_project_index.toml

Fill in the main index file. Focus on these sections:

**Required — always fill in:**
- `[meta]` — Project name, language, framework, architecture
- `[structure]` — Folder organization
- `[modules]` — References to module TOML files
- `[entry_points]` — Main files
- `[commands]` — Key development commands

**High value — fill in when applicable:**
- `[context_loading]` — Task-to-file routing table (see below)
- `[boundaries]` — Architectural invariants AI must respect
- `[testing]` — How tests are organized and run
- `[dependencies.external]` — Important third-party libraries

**Fill in as needed:**
- `[conventions]` — Coding patterns you observe
- `[dependencies.policy]` — Dependency rules
- `[notes]` — Migration status, legacy warnings, etc.

**Important:** Remove all unused sections, template comments, and example lines. Keep the output lean.

### 3. Fill in the Context Loading Table

The `[context_loading]` section is a key innovation. It tells future AI sessions **which files to read** for different types of tasks.

Analyze the codebase and create entries like:

```toml
[context_loading]
on_bug_fix = [
    "ai_project_index/modules/{affected_module}.toml",
    "tests/",
]
on_new_feature = [
    "ai_project_index/ai_project_index.toml",
    "docs/architecture.md",
]
on_refactor = [
    "ai_project_index/ai_project_index.toml",
    "ai_project_index/modules/",
]
always_read = [
    "ai_project_index/ai_project_index.toml",
]
```

Think about: *If an AI needs to fix a bug in module X, what's the minimum context it needs?*

### 4. Fill in the Boundaries Section

Document architectural constraints that AI must not violate:

```toml
[boundaries]
invariants = [
    "Database access ONLY through repository layer",
    "All external API calls go through src/clients/",
]
protected_files = [
    "migrations/ — Never auto-generate",
]
```

Look for:
- Layer boundaries (e.g., controllers never access DB directly)
- Protected areas (e.g., generated code, migration files)
- Public API contracts that must not break

### 5. Identify Modules/Features

Look for logical groupings in the codebase:
- Features (e.g., authentication, user management, payments)
- Domains (e.g., orders, inventory, shipping)
- Layers (e.g., core utilities, data access, API routes)

Each significant module should get its own TOML file.

**Granularity guideline:** A module TOML file should be **10–40 lines**. If it would be longer, split into sub-modules. If shorter than 10 lines, consider merging with a related module.

### 6. Create Module Files

For each module, create `ai_project_index/modules/{module_name}.toml`:

```toml
[meta]
name = "module_name"
location = "path/to/module"
description = "What this module does (one sentence)"

[[model]]
name = "ComponentName"
file = "relative/path/to/file.ext"
purpose = "Brief description"
exports = ["export1", "export2"]

[[service]]
# ... similar structure for services, controllers, utilities, etc.

[dependencies]
core = ["shared/utils", "shared/types"]
modules = ["other_module/something"]
external = ["library_name"]

[usage]
imported_by = ["path/to/file1", "path/to/file2"]
```

**Component types to use** (adapt to the project):
- `[[model]]` — Data structures, entities, domain objects
- `[[service]]` — Business logic, operations, use cases
- `[[repository]]` — Data access layer
- `[[controller]]` / `[[handler]]` — API endpoints, route handlers
- `[[component]]` — UI components, widgets
- `[[utility]]` — Helper functions, shared utilities
- `[[middleware]]` — Request/response interceptors
- `[[config]]` — Configuration modules

Use whatever types make sense. The framework is language-agnostic.

### 7. Track Dependencies and Usage

For each module, document:
- **Dependencies** (`[dependencies]`) — What it imports/uses
- **Usage** (`[usage]`) — What files import it

This enables:
- Safe refactoring (know impact of changes)
- Architectural analysis (detect coupling)
- Quick navigation (find related code)

### 8. Quality Check

Before finishing, verify:
- [ ] All template comments and examples removed from output files
- [ ] No empty sections — remove sections that don't apply
- [ ] Descriptions are concise (one sentence each)
- [ ] Module TOML files are 10–40 lines each
- [ ] `[context_loading]` has useful task-to-file mappings
- [ ] `[boundaries]` captures real architectural constraints
- [ ] File paths are correct and relative to project root

## Best Practices

1. **Start small** — Document high-level structure first, add details iteratively
2. **Be consistent** — Use similar structure across module files
3. **Keep it current** — This snapshot reflects a point in time
4. **Be concise** — Every line costs future tokens
5. **Think in layers** — Core → Modules → Features
6. **Optimize for routing** — Help future AI find the right files fast

## Expected Output

After analysis, you should have:

```
ai_project_index/
├── ai_project_index.toml       # Main index (completed, no template comments)
└── modules/
    ├── core.toml               # Shared infrastructure
    ├── auth.toml               # Authentication module
    ├── users.toml              # User management
    └── ...                     # Other modules
```

## Ready?

Begin by exploring the codebase, then update `ai_project_index/ai_project_index.toml`.
Create module files as you identify logical groupings.
**Delete this INIT.md file when done.**
