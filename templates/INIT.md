# AI Analysis Instructions

Welcome! This file guides you through analyzing this codebase and creating a structured index.

## Objective

Create a **split snapshot** system using TOML files to document this codebase efficiently.
This reduces token usage by allowing AI assistants to read only relevant parts of the architecture.

## Guiding Principle: Navigation, not behavior

The index answers **what a module does** and **where each concern lives** — never
**how** the code works step by step. The source code is the single source of
truth for HOW.

A good entry survives refactors. Before writing any note, apply this litmus test:

> "Would a refactor that doesn't change the architecture force me to edit this?"

If yes, it's too low-level — don't transcribe the steps. Instead **point to the
file/module that owns the behavior** (and, if detail is genuinely needed, a
co-located `CLAUDE.md` next to that code). Keep only durable, non-obvious
constraints: external gotchas, invariants, forbidden dependencies.

Prefer **pointers over recipes**. Recipes rot when the code changes; pointers don't.

## Analysis Roots

Analyze starting from: **{{ROOT_FOLDERS}}**

(Multiple root folders can be specified to analyze different parts of the codebase separately)

## Step-by-Step Process

### 1. Understand the Project Structure

First, explore the codebase to understand:
- What programming language(s) are used?
- What framework(s) or libraries are central?
- How is the code organized? (monolith, modules, features, domains)
- What are the main entry points?
- What are the key external dependencies?

**Action:** Read key files like:
- README.md (if exists)
- Package/dependency files (package.json, requirements.txt, go.mod, Cargo.toml, pubspec.yaml, etc.)
- Main entry point files
- Directory structure (`ls -R` or similar)

### 2. Update ai_project_index.toml

Fill in the main index file with:
- `[meta]` - Project name, language, framework, architecture
- `[structure]` - Folder organization
- `[entry_points]` - Main files
- `[commands]` - Key development commands
- `[dependencies.external]` - Important third-party libraries
- `[conventions]` - Coding patterns you observe

**Important:** Keep descriptions concise. Focus on "what" and "why", not implementation details.

### 3. Identify Modules/Features

Look for logical groupings in the codebase:
- Features (e.g., authentication, user management, payments)
- Domains (e.g., orders, inventory, shipping)
- Layers (e.g., core utilities, data access, API routes)

Each significant module should get its own TOML file.

### 4. Create Module Files

For each module, create `ai_project_index/modules/{module_name}.toml` with:

```toml
[meta]
name = "module_name"
location = "path/to/module"
description = "What this module does"

# Document key components using arrays:

[[model]]
name = "ComponentName"
file = "relative/path/to/file.ext"
purpose = "Brief description"
exports = ["export1", "export2"]  # What this file exports

[[service]]
# ... similar structure for services, controllers, utilities, etc.

[dependencies]
core = ["shared/utils", "shared/types"]
modules = ["other_module/something"]
external = ["library_name"]

[usage]
imported_by = ["path/to/file1", "path/to/file2"]  # For refactoring safety
```

### 5. Component Types to Document

Use appropriate component types based on the architecture:

**Common types:**
- `[[model]]` - Data structures, entities, domain objects
- `[[service]]` - Business logic, operations, use cases
- `[[repository]]` - Data access layer
- `[[controller]]` / `[[handler]]` - API endpoints, route handlers
- `[[component]]` - UI components, widgets
- `[[utility]]` - Helper functions, shared utilities
- `[[middleware]]` - Request/response interceptors
- `[[config]]` - Configuration modules

**Flexibility:** Use whatever component types make sense for this project.
The framework is language-agnostic - adapt to the actual architecture.

### 6. Track Dependencies and Usage

For each module, document:
- **Dependencies** (`[dependencies]`) - What it imports/uses
- **Usage** (`[usage]`) - What files import it

This enables:
- Safe refactoring (know impact of changes)
- Architectural analysis (detect coupling)
- Quick navigation (find related code)

### 7. Focus on AI Value

When documenting, ask yourself:
- **Would this help an AI understand the codebase faster?**
- **Does this reduce the need to read multiple files?**
- **Is this information stable (doesn't change often)?**

**Include:**
- Component purposes and responsibilities
- Relationships between modules
- Architectural constraints
- Key patterns and conventions

**Exclude:**
- Implementation details (AI can read the source)
- Step-by-step recipes or call sequences (they rot when the code changes — point to the owning file instead)
- Frequently changing data
- Obvious information

## Best Practices

1. **Start small** - Document high-level structure first, add details iteratively
2. **Be consistent** - Use similar structure for similar modules
3. **Keep it current** - Update when architecture changes
4. **Be concise** - Prioritize clarity over completeness
5. **Think in layers** - Core → Modules → Features

## Snapshot Concept

The "snapshot" is a **compressed view** of the codebase architecture:
- Not full source code dumps
- Not auto-generated exhaustive lists
- **Curated, high-level documentation** of structure and patterns

Think of it as a **map** of the codebase, not a **copy** of it.

## Expected Output

After analysis, you should have:

```
ai_project_index/
├── ai_project_index.toml       # Main index (completed)
└── modules/
    ├── core.toml               # Shared infrastructure
    ├── auth.toml               # Authentication module
    ├── users.toml              # User management
    └── ...                     # Other modules
```

## Questions?

If you're unsure:
- **Start with the obvious** - Document what's clear first
- **Ask the user** - Clarify ambiguous architecture decisions
- **Iterate** - Initial version doesn't need to be perfect

## Ready?

Begin by reading `ai_project_index/ai_project_index.toml` and updating it with your findings.
Then create module files as you identify logical groupings.

Good luck!
