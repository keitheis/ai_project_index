# ai_project_index

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![TOML](https://img.shields.io/badge/format-TOML-blue.svg)](https://toml.io)

A framework for building structured TOML-based codebase indices that make AI coding assistants faster, cheaper, and more accurate.

## Table of Contents

- [Why This Exists](#why-this-exists)
- [How It Works](#how-it-works)
- [Quick Start](#quick-start)
- [Example Output](#example-output)
- [Multiple Root Folders](#multiple-root-folders)
- [Key Concepts](#key-concepts)
- [Integrating with AI Tools](#integrating-with-ai-tools)
- [Maintenance](#maintenance)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)
- [Design Principles](#design-principles)
- [Why TOML?](#why-toml)
- [Credits](#credits)
- [License](#license)

## Why This Exists

AI coding assistants (Cursor, Claude Code, GitHub Copilot, Windsurf, etc.) face three problems with large codebases:

1. **Token cost** — Reading many files to understand architecture burns tokens on every interaction
2. **Hallucination** — Without a reliable map, AI guesses at project structure and gets it wrong
3. **Unsafe changes** — Without knowing architectural boundaries, AI makes changes that break invariants

**ai_project_index** solves all three by creating a **navigational map** of your codebase:

- **Split snapshots** — Multiple focused TOML files instead of one monolithic dump
- **Module-based organization** — Organized by feature/domain, matching how developers think
- **Boundaries & gotchas** — Architectural rules and known pitfalls that prevent bugs
- **Cross-references** — Dependency and usage tracking for safe refactoring
- **Language-agnostic** — Works with any programming language or framework

### The Agentic Workflow

Modern AI tools work in loops: **Orient → Decide → Act → Verify**. The index accelerates the "Orient" step:

```
Without index:  Read 20+ files → build mental model → make changes → hope it's right
With index:     Read 1 TOML file → drill into relevant module → make targeted changes
```

The one-time cost of building the index pays back on every future AI interaction — not just in tokens, but in accuracy and safety.

## How It Works

```
1. Run activate.sh in your project
         ↓
2. Script creates ai_project_index/ with templates
         ↓
3. Ask your AI assistant to read INIT.md and analyze the codebase
         ↓
4. AI populates TOML files as a structured map
         ↓
5. Future AI interactions read the map first, then drill into source files as needed
```

## Quick Start

**Prerequisites**: Navigate to your project directory (`cd your_project/`) using CLI or open the project folder in your IDE.

⚠️ **Token Usage Warning**: The initial analysis may consume **10,000–50,000 tokens** depending on project size. This one-time investment saves tokens and improves accuracy on every future interaction.

### 1. Download and run the activation script

**Option A: Direct download (Quick)**

```bash
curl -fsSL https://raw.githubusercontent.com/keitheis/ai_project_index/main/activate.sh | bash
```

**Option B: Clone and run locally**

```bash
git clone https://github.com/keitheis/ai_project_index.git /tmp/ai_project_index
/tmp/ai_project_index/activate.sh
```

This will:

1. Create:
    - Folder: `(your_project)/ai_project_index/modules/`
    - File:
        - `(your_project)/ai_project_index/ai_project_index.toml`
        - `(your_project)/ai_project_index/INIT.md`
2. Ask which root folder(s) to analyze and update `ai_project_index.toml`.
   - You can specify multiple folders (e.g., `src, lib` or `frontend backend`)

### 2. Run the initial AI analysis

Open your AI assistant (IDE plugin or CLI) and provide this prompt:

```
Read ai_project_index/INIT.md and follow the instructions to:
1. Analyze this project's structure and modules
2. Create/update ai_project_index/ai_project_index.toml with project metadata
3. Create module-specific TOML files in ai_project_index/modules/
4. Remove empty sections and delete INIT.md when done
```

**What to expect:**
- The AI will explore your codebase to understand the architecture
- It will create TOML files documenting structure, boundaries, and gotchas
- For large projects (>10,000 LOC), this may take several interactions
- You can review and refine the generated files afterward

### 3. Add the instruction to your AI configuration

```markdown
## Architecture / Project Index

**Read first:**
- `ai_project_index/ai_project_index.toml` (project overview, boundaries, gotchas)
- Relevant `ai_project_index/modules/*.toml` files (module details)

Use the index to navigate the codebase efficiently. Respect the boundaries defined in the index.
```

Add this to whichever AI instruction file your tool uses:
- **Claude Code**: `CLAUDE.md`
- **Cursor**: `.cursor/rules/*.mdc` or `.cursorrules`
- **GitHub Copilot**: `.github/copilot-instructions.md`
- **General**: `AGENTS.md`

### 4. Commit or ignore `ai_project_index/` (Optional)

**Option A: Commit to repository** (Recommended for teams)
```bash
git add ai_project_index/
git commit -m "Add AI project index"
```
Benefits: Team members and AI assistants get immediate context.

**Option B: Add to .gitignore** (For personal use)
```bash
echo "ai_project_index/" >> .gitignore
```

## Example Output

After setup, your project will have:

```
your_project/
├── ai_project_index/
│   ├── ai_project_index.toml          # Main project index
│   ├── INIT.md                        # (deleted after initial analysis)
│   └── modules/
│       ├── auth.toml                  # Authentication module
│       ├── api.toml                   # API layer
│       └── database.toml              # Database layer
```

### Sample `ai_project_index.toml`

```toml
[meta]
name = "MyProject"
description = "A web application with authentication and REST API"
roots = ["src", "lib"]
last_updated = "2026-02-07"

[meta.tech]
language = "Python 3.12"
framework = "FastAPI"
architecture = "Clean Architecture"

[structure]
source = "src/"
modules = "src/modules/"
tests = "tests/"
config = "config/"

[modules]
auth = "modules/auth.toml"
api = "modules/api.toml"
database = "modules/database.toml"

[entry_points]
main = "src/main.py"
config = "config/settings.py"

[boundaries]
allowed = [
    "modules -> core (one-way)",
    "handlers -> services -> repositories (layered)",
]
forbidden = [
    "core -> modules (core must not import feature modules)",
    "handlers -> database (must go through repository layer)",
    "circular dependencies between modules",
]

[gotchas]
"redis_sessions" = "Sessions use Redis — app fails silently if Redis is down"
"migration_order" = "Run auth migrations before user migrations"
"env_required" = "DATABASE_URL and SECRET_KEY must be set before import"

[change_risk]
high = ["src/core/auth.py", "src/db/migrations/", "config/settings.py"]
moderate = ["src/api/routes/"]
stable = ["src/utils/"]

[commands]
install = "pip install -r requirements.txt"
dev = "uvicorn src.main:app --reload"
test = "pytest tests/"
lint = "ruff check src/"

[dependencies.external]
"fastapi" = "Web framework"
"sqlalchemy" = "ORM and database toolkit"
"pydantic" = "Data validation"
"bcrypt" = "Password hashing"
"pyjwt" = "JWT token handling"

[conventions]
naming = "snake_case for functions, PascalCase for classes"
imports = "absolute imports only"
error_handling = "raise HTTPException, never return raw error strings"
testing = "tests/ mirrors src/ structure"
```

### Sample Module File `modules/auth.toml`

```toml
[meta]
name = "auth"
location = "src/modules/auth/"
description = "JWT-based authentication with role-based access control"

[[model]]
name = "User"
file = "src/modules/auth/models/user.py"
purpose = "User entity with credentials and role assignments"

[[service]]
name = "AuthService"
file = "src/modules/auth/service.py"
purpose = "Login, logout, token generation and validation"

[[middleware]]
name = "AuthMiddleware"
file = "src/modules/auth/middleware.py"
purpose = "Request authentication and role checking"

[dependencies]
core = ["src/core/config.py", "src/core/logger.py"]
modules = ["src/modules/users/models.py"]
external = ["bcrypt", "pyjwt"]

[usage]
imported_by = [
    "src/api/routes/auth.py",
    "src/api/middleware/auth_middleware.py",
]
```

**Token savings**: Instead of reading all files in `src/modules/auth/`, the AI reads one compact TOML file and only loads specific source files when needed.

## Multiple Root Folders

Supports analyzing multiple root folders — useful for:

- **Monorepos**: `packages/frontend`, `packages/backend`
- **Multi-language projects**: `client/`, `server/`
- **Complex architectures**: `src/`, `lib/`, `scripts/`

When running the activation script:
```
Which folder(s) should I analyze?
  Path(s) (default: .): src, lib, scripts
```

The resulting `ai_project_index.toml` will contain:
```toml
[meta]
roots = ["src", "lib", "scripts"]
```

## Key Concepts

### Hierarchical Navigation

The index supports a **zoom-in** workflow:

1. **Level 1**: `ai_project_index.toml` — project overview, boundaries, gotchas
2. **Level 2**: `modules/*.toml` — module details, components, dependencies
3. **Level 3**: Actual source files — only when needed for specific changes

AI reads Level 1 on every interaction, Level 2 when working on a module, and Level 3 only for the specific files being modified.

### The [meta] Section

Every TOML file starts with metadata for quick orientation:

```toml
[meta]
name = "auth"
location = "src/modules/auth/"
description = "JWT-based authentication with role-based access control"
```

### Boundaries

The most valuable section for preventing bugs. Document architectural rules:

```toml
[boundaries]
forbidden = [
    "handlers -> database (must go through repository layer)",
    "circular dependencies between modules",
]
```

### Gotchas

Document surprising behaviors that trip up newcomers (human or AI):

```toml
[gotchas]
"silent_failure" = "Redis connection failures are swallowed — check logs"
"env_order" = "Load .env before importing settings module"
```

### Change Risk

Flag areas where changes have outsized impact:

```toml
[change_risk]
high = ["src/core/auth.py", "config/settings.py"]
stable = ["src/utils/"]
```

### Component Arrays

Use `[[component]]` arrays for multiple items of the same type:

```toml
[[model]]
name = "User"
file = "src/modules/auth/models/user.py"
purpose = "User entity"

[[model]]
name = "Session"
file = "src/modules/auth/models/session.py"
purpose = "Auth session"
```

### Usage Tracking

Track where components are imported for safe refactoring:

```toml
[usage]
imported_by = [
    "src/modules/auth/service.py",
    "src/modules/core/api/routes.py",
]
```

### Dependencies

Document cross-module relationships:

```toml
[dependencies]
core = ["src/core/http.py", "src/core/logger.py"]
modules = ["src/modules/users/models.py"]
external = ["requests", "pydantic"]
```

## Integrating with AI Tools

### Cursor

Add to `.cursor/rules/project-index.mdc`:

```markdown
---
description: Project index for codebase navigation
alwaysApply: true
---

Read `ai_project_index/ai_project_index.toml` before making changes.
Check relevant `ai_project_index/modules/*.toml` for module context.
Respect the boundaries defined in `[boundaries]`.
```

### Claude Code

Add to `CLAUDE.md`:

```markdown
## Project Index
Read `ai_project_index/ai_project_index.toml` for project overview, boundaries, and gotchas.
Read relevant `ai_project_index/modules/*.toml` before modifying any module.
```

### GitHub Copilot

Add to `.github/copilot-instructions.md`:

```markdown
## Project Index
Refer to `ai_project_index/ai_project_index.toml` for architecture and conventions.
Module details are in `ai_project_index/modules/*.toml`.
```

### General (AGENTS.md)

Any tool that reads `AGENTS.md` will pick up the same instructions.

## Maintenance

### Updating the Index

**Option 1: Minimal updates (Recommended)**

```
Review recent changes and update ai_project_index/ only where needed.
Focus on: new modules, deleted/moved files, changed boundaries or gotchas.
```

**Option 2: Full regeneration**

For major restructuring:
```bash
cp -r ai_project_index ai_project_index.backup
# Ask AI to regenerate using the Step 2 prompt from Quick Start
```

### When to Update

Update the index when:
- ✅ Adding new modules or major features
- ✅ Restructuring code organization
- ✅ Changing architectural boundaries
- ✅ Discovering new gotchas
- ✅ Moving files to new locations

**Don't** update for:
- ❌ Minor bug fixes
- ❌ Documentation-only changes
- ❌ Refactoring within a single file
- ❌ Adding comments

### Keeping It Lean

- Remove modules that no longer exist
- Delete empty or placeholder sections
- Focus on boundaries and public interfaces, not implementation details
- Review periodically — if a section hasn't been useful, remove it

## Best Practices

### Start Small, Iterate
- Begin with `ai_project_index.toml` and 2-3 module files
- Add detail as you discover what's actually useful
- Don't try to document everything at once

### Prioritize What Prevents Bugs
- `[boundaries]` and `[gotchas]` are the highest-value sections
- A single documented pitfall can save hours of debugging
- Architectural rules prevent entire classes of errors

### Be Consistent
- Use similar TOML structure across modules
- Maintain consistent naming conventions
- Keep descriptions at the same level of abstraction

### Focus on Architecture
- Document boundaries between modules
- Highlight public APIs and interfaces
- Skip private implementation details
- Think in layers: Core → Modules → Features

### Treat as Living Documentation
- Update alongside code changes
- Review and prune periodically
- Remove outdated information promptly

## Troubleshooting

### The activation script fails

```bash
# Ensure you're in your project directory
pwd  # Should show your project path

# Check execute permissions
chmod +x /tmp/ai_project_index/activate.sh

# Run with bash explicitly
bash /tmp/ai_project_index/activate.sh

# Show help
bash /tmp/ai_project_index/activate.sh --help
```

### AI doesn't understand INIT.md instructions

- Break down the request: Ask AI to analyze one module at a time
- Provide examples: Show the AI a sample TOML structure you want
- Be specific: "Create a TOML file for the authentication module in src/auth/"
- Review and iterate: Check generated files and ask for corrections

### TOML files are too large

- Focus on public APIs and interfaces, not every function
- Group similar components (all models together)
- Split large modules into sub-modules
- Remove implementation details — AI can read the source

### AI still reads too many files

1. Ensure the instruction is in your AI's configuration:
   ```
   Read ai_project_index/ai_project_index.toml before making changes.
   ```

2. Remind explicitly: "Use the project index instead of reading files directly"

3. Check if index is up-to-date with recent changes

### Generated index doesn't match project structure

1. Verify `roots` in `ai_project_index.toml` match your actual folders
2. Re-run activation script with correct root folders
3. Manually edit `ai_project_index.toml` to fix paths

## Design Principles

These principles guided the design of **ai_project_index**:

1. **Zero dependencies** — Pure bash script, works anywhere
2. **Language-agnostic** — Works with Python, TypeScript, Go, Rust, Java, or any language
3. **AI-native** — Designed for how LLMs actually process information (hierarchical, structured, grounded)
4. **Lean by default** — Every token in the index must earn its place
5. **Human-readable** — Developers can read and edit TOML files directly
6. **Composable** — Works alongside CLAUDE.md, .cursorrules, AGENTS.md, etc.

## Why TOML?

- **Human-readable** — Easy to read and write, even for non-developers
- **Structured** — Supports nested sections and arrays
- **Comments** — Include explanatory notes inline
- **Universal** — Parsers available in all languages
- **Diff-friendly** — Clean diffs in version control

## Credits

This project builds upon the snapshot concept introduced in [小海嚴寫 Vibe Coding: Snapshot 2.0](https://tzangms.com/vibe-coding-snapshot-2-0/) by tzangms.

**ai_project_index** extends this with:
- Formalized TOML structure for better parsing and grounding
- Multi-module organization for larger codebases
- Architectural boundaries and gotchas for safer AI changes
- Cross-reference tracking for dependencies
- Language-agnostic approach
- Integration guidance for modern AI coding tools

## License

MIT
