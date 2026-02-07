# ai_project_index

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![TOML](https://img.shields.io/badge/format-TOML-blue.svg)](https://toml.io)

A fast handy framework for saving AI tokens and routing context efficiently using structured TOML project indices.

## Table of Contents

- [The Problem](#the-problem)
- [The Solution](#the-solution)
- [Quick Start](#quick-start)
- [Example Output](#example-output)
- [Multiple Root Folders](#multiple-root-folders)
- [Key Concepts](#key-concepts)
- [Integration with AI Tools](#integration-with-ai-tools)
- [Maintenance](#maintenance)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)
- [Why TOML?](#why-toml)
- [Credits](#credits)
- [License](#license)

## The Problem

AI coding assistants struggle with large codebases:
- **Token waste** — AI reads many files to understand architecture, burning tokens on every interaction
- **Context pollution** — Loading irrelevant files reduces AI reasoning quality
- **No routing** — AI has no way to know *which* files are relevant to a given task
- **No guardrails** — AI doesn't know architectural boundaries it should not cross

## The Solution

**ai_project_index** provides:
- **Split snapshots** — Multiple focused TOML files instead of one large file
- **Context routing** — A `[context_loading]` table that maps task types to relevant files
- **Architectural boundaries** — A `[boundaries]` section documenting invariants AI must respect
- **Module-based organization** — Organized by feature/domain
- **Cross-references** — Track dependencies and usage for safe refactoring
- **Language-agnostic** — Works with any programming language

## Quick Start

**Prerequisites**: Navigate to your project directory (`cd your_project/`) using CLI or open the project folder in your IDE.

⚠️ **Token Usage Warning**: The initial project analysis may consume **10,000-50,000 tokens** (or more) depending on your AI provider and project size. For projects with >10,000 lines of code, expect significant token usage during first-time setup. However, this one-time investment saves tokens on every future AI interaction.

### 1. Download and run the activation script

**Option A: Direct download (Quick)**

```bash
curl -fsSL https://raw.githubusercontent.com/keitheis/ai_project_index/main/activate.sh | bash
```

**Option B: Clone and run locally**

```bash
# Clone the repository
git clone https://github.com/keitheis/ai_project_index.git /tmp/ai_project_index

# Run the activation script from your project directory
/tmp/ai_project_index/activate.sh
```

This will:

1. Create:
    - Folder: `(your_project)/ai_project_index/modules/`
    - File:
        - `(your_project)/ai_project_index/ai_project_index.toml`
        - `(your_project)/ai_project_index/INIT.md`
2. Ask which root folder(s) it should analyze and update `ai_project_index.toml`.
   - You can specify multiple folders (e.g., `src, lib` or `frontend backend`)
   - This is useful for monorepos or projects with multiple source directories

### 2. Run the initial AI analysis

Open your AI assistant (IDE plugin or CLI) and provide this prompt:

```
Read ai_project_index/INIT.md and follow the instructions to:
1. Analyze this project's structure and modules
2. Create/update ai_project_index/ai_project_index.toml with project metadata
3. Create module-specific TOML files in ai_project_index/modules/
4. Fill in the context_loading and boundaries sections
5. Delete ai_project_index/INIT.md when done

Use the snapshot concept described in INIT.md to organize the codebase by feature/domain.
```

**What to expect:**
- The AI will ask clarifying questions about your project structure
- It will read files across your codebase to understand the architecture
- For large projects (>10,000 LOC), this may take several interactions
- You can review and refine the generated TOML files afterward

### 3. Append the instruction to your AI markdown instructions.

Add this to your `CLAUDE.md`, `AGENTS.md`, `.github/copilot-instructions.md`, or equivalent:

```markdown
## Architecture/Modules/Project Index

**Read first:**
- `ai_project_index/ai_project_index.toml` (project overview and context routing)
- Relevant `ai_project_index/modules/*.toml` files (module details)

Use the `[context_loading]` section to determine which files to read for the current task.
Respect the `[boundaries]` section — do not violate architectural invariants.
```

### 4. Add or ignore `ai_project_index/` (Optional)

You can choose to commit the generated index files to version control or ignore them:

**Option A: Commit to repository** (Recommended for teams)
```bash
git add ai_project_index/
git commit -m "Add AI Architecture/Modules/Project Index"

```
Benefits: Team members and AI assistants get immediate context about the project structure.

**Option B: Add to .gitignore** (For personal use)
```bash
echo "ai_project_index/" >> .gitignore
```
Benefits: Keep the repository clean if indices are auto-generated or personal preference.

## Example Output

After setup, your project will have a structure like this:

```
your_project/
├── ai_project_index/
│   ├── ai_project_index.toml          # Main project index
│   └── modules/
│       ├── auth.toml                  # Authentication module
│       ├── api.toml                   # API layer
│       └── database.toml              # Database layer
```

### Sample `ai_project_index.toml`

```toml
[meta]
name = "MyProject"
version = "1.0.0"
roots = ["src", "lib"]
description = "A web application with authentication and API"
language = "Python"
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

[commands]
dev = "uvicorn src.main:app --reload"
test = "pytest -x"
lint = "ruff check src/"

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

[boundaries]
invariants = [
    "Database access ONLY through repository layer",
    "All external API calls go through src/clients/",
]
protected_files = [
    "migrations/ — Never auto-generate; user handles migrations",
]

[testing]
framework = "pytest"
run_command = "pytest -x"
conventions = [
    "Use fixtures from conftest.py",
    "Mock external services in tests",
]

[dependencies.external]
"fastapi" = "Web framework"
"sqlalchemy" = "ORM"
"pydantic" = "Data validation"
```

### Sample Module File `modules/auth.toml`

```toml
[meta]
name = "auth"
location = "src/modules/auth/"
description = "User authentication and authorization"

[[model]]
name = "User"
file = "src/modules/auth/models/user.py"
purpose = "User entity with credentials"

[[service]]
name = "AuthService"
file = "src/modules/auth/service.py"
purpose = "Handles login, logout, token generation"

[dependencies]
external = ["bcrypt", "pyjwt"]
modules = ["src/modules/users/"]

[usage]
imported_by = [
    "src/api/routes/auth.py",
    "src/api/middleware/auth_middleware.py"
]
```

**Token Savings**: Instead of reading all files in `src/modules/auth/`, the AI reads one 20-line TOML file and only loads specific files when needed.

## Multiple Root Folders

**ai_project_index** supports analyzing multiple root folders in a single project. This is particularly useful for:

- **Monorepos**: Projects with multiple packages (e.g., `packages/frontend`, `packages/backend`)
- **Multi-language projects**: Separate source trees (e.g., `client/`, `server/`)
- **Complex architectures**: Different modules in different locations (e.g., `src/`, `lib/`, `scripts/`)

When running the activation script, you can specify multiple folders:
```
Which folder(s) should I analyze?
  Path(s) (default: .): src, lib, scripts
```

Or with spaces:
```
  Path(s) (default: .): frontend backend shared
```

The resulting `ai_project_index.toml` will contain:
```toml
[meta]
roots = ["src", "lib", "scripts"]
```

## Key Concepts

### Context Loading

The `[context_loading]` section is a **routing table** for AI context. Instead of loading the entire index for every task, AI reads this section first to determine which files are relevant:

```toml
[context_loading]
on_bug_fix = ["ai_project_index/modules/{affected_module}.toml", "tests/"]
on_new_feature = ["ai_project_index/ai_project_index.toml", "docs/architecture.md"]
on_refactor = ["ai_project_index/ai_project_index.toml", "ai_project_index/modules/"]
always_read = ["ai_project_index/ai_project_index.toml"]
```

This is the single most impactful section for reducing ongoing token usage — it prevents AI from reading the entire codebase for every interaction.

### Architectural Boundaries

The `[boundaries]` section documents constraints that AI must not violate:

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

This prevents AI agents from making structurally harmful changes, even when they have the technical ability to do so.

### Testing Strategy

The `[testing]` section helps AI write tests that match your project's patterns:

```toml
[testing]
framework = "pytest"
run_command = "pytest -x"
conventions = [
    "Use fixtures from conftest.py",
    "Mock external services in tests",
]
```

### The [meta] Section

Every TOML file starts with metadata:

```toml
[meta]
name = "auth"
location = "src/modules/auth/"
description = "User authentication and authorization"
```

### Component Arrays

Use `[[component]]` arrays for multiple items:

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

Track where components are used for safe refactoring:

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

## Integration with AI Tools

**ai_project_index** works with any AI coding assistant. Here's how to integrate with popular tools:

### Claude Code
Add to your `CLAUDE.md`:
```markdown
## Project Index
Read `ai_project_index/ai_project_index.toml` first. Use `[context_loading]` to determine relevant files. Respect `[boundaries]`.
```

### Cursor
Add a `.cursor/rules/` rule or reference the index in your project rules. Cursor agents will automatically read referenced files.

### GitHub Copilot
Add to `.github/copilot-instructions.md`:
```markdown
Read ai_project_index/ai_project_index.toml for project structure. Module details are in ai_project_index/modules/.
```

### Other Tools (Windsurf, Cline, Aider, etc.)
Most AI coding tools support instruction files. Add the index reference to whichever instruction mechanism your tool uses.

## Maintenance

### Updating the Index

After making changes to your codebase, update the index to keep it in sync:

**Option 1: Minimal updates (Recommended)**

Ask your AI assistant:
```
Review recent changes and do minimal updates to ai_project_index/ only if necessary.
Focus on:
- New modules or files added
- Deleted or moved files
- Changed dependencies
```

**Option 2: Full regeneration**

For major refactoring or structural changes, regenerate from scratch:
```bash
# Back up current index
cp -r ai_project_index ai_project_index.backup

# Ask AI to regenerate (use the Step 2 prompt from Quick Start)
```

### When to Update

Update the index when:
- ✅ Adding new modules or major features
- ✅ Restructuring code organization
- ✅ Changing key dependencies
- ✅ Moving files to new locations

**Don't** update for:
- ❌ Minor bug fixes
- ❌ Documentation-only changes
- ❌ Adding comments
- ❌ Refactoring within a single file

### Keeping It Lean

To save future tokens:
- Remove outdated or deleted modules from TOML files
- Avoid documenting implementation details that change frequently
- Focus on architectural boundaries and public interfaces
- Review and prune unnecessary entries periodically
- Module TOML files should be **10–40 lines** each — split or merge if outside this range

## Best Practices

### Start Small, Iterate
- Begin with high-level module organization
- Add detail gradually as needed
- Don't try to document everything at once

### Be Consistent
- Use similar TOML structure across modules
- Maintain consistent naming conventions
- Keep descriptions at the same level of abstraction

### Focus on Architecture
- Document boundaries between modules
- Highlight public APIs and interfaces
- Skip private implementation details
- Think in layers: Core → Modules → Features

### Optimize for Context Routing
- Fill in `[context_loading]` to minimize per-task token usage
- Document `[boundaries]` to prevent structural mistakes
- Keep descriptions concise — every line costs tokens in every future session

### Treat as Living Documentation
- Update alongside code changes (see [Maintenance](#maintenance))
- Review and refine periodically
- Remove outdated information promptly
- Keep files concise to save future tokens

## Troubleshooting

### The activation script fails

**Problem**: `activate.sh` exits with an error or doesn't create files.

**Solutions**:
```bash
# Ensure you're in your project directory
pwd  # Should show your project path

# Check if activate.sh has execute permissions
chmod +x /tmp/ai_project_index/activate.sh

# Run with bash explicitly
bash /tmp/ai_project_index/activate.sh
```

### AI doesn't understand INIT.md instructions

**Problem**: AI creates incorrect or incomplete TOML files.

**Solutions**:
- Break down the request: Ask AI to analyze one module at a time
- Provide examples: Show the AI a sample TOML structure you want
- Be specific: "Create a TOML file for the authentication module in src/auth/"
- Review and iterate: Check generated files and ask for corrections

### TOML files are too large

**Problem**: Module TOML files contain hundreds of lines.

**Solutions**:
- Focus on public APIs and interfaces, not private implementation details
- Document file purposes, not every function
- Group similar components (e.g., all models together, not individually)
- Split large modules into smaller sub-modules
- Target 10–40 lines per module file

### AI still reads too many files

**Problem**: AI doesn't use the index and reads files directly.

**Solutions**:
1. Ensure the instruction is in your AI's prompt/context:
   ```
   **Important** Read:
     - Project index: `ai_project_index/ai_project_index.toml`
     - Modules: `ai_project_index/modules/*.toml`
   Use [context_loading] to route to relevant files.
   ```

2. Remind the AI explicitly: "Use the project index in ai_project_index/ instead of reading files directly"

3. Check if index is up-to-date with recent changes

### Generated index doesn't match my project structure

**Problem**: TOML files reference wrong paths or missing directories.

**Solutions**:
1. Verify the `roots` setting in `ai_project_index.toml`:
   ```toml
   [meta]
   roots = ["src", "lib"]  # Make sure these match your actual folders
   ```

2. Re-run activation script and specify correct root folders

3. Manually edit `ai_project_index.toml` to fix paths

## Why TOML?

- **Human-readable** — Easy to read and write
- **Structured** — Supports nested sections and arrays
- **Comments** — Include explanatory notes
- **Universal** — Parsers available in all languages
- **Token-efficient** — Less syntactic overhead than JSON or YAML

## Credits

This project builds upon the snapshot concept introduced in [小海嚴寫 Vibe Coding: Snapshot 2.0](https://tzangms.com/vibe-coding-snapshot-2-0/) by tzangms. The idea of creating structured, AI-friendly codebase documentation to reduce token consumption was pioneered in that work.

**ai_project_index** extends this with:
- Formalized TOML structure for better parsing
- Multi-module organization for larger codebases
- Cross-reference tracking for dependencies
- Context routing via `[context_loading]` for task-specific context loading
- Architectural boundaries via `[boundaries]` for AI guardrails
- Testing conventions via `[testing]` for consistent test generation
- Language-agnostic approach

## License

MIT
