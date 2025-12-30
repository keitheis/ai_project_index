# ai_project_index

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![TOML](https://img.shields.io/badge/format-TOML-blue.svg)](https://toml.io)

A fast handy framework for saving AI tokens by project index in structured TOML files.

## Table of Contents

- [The Problem](#the-problem)
- [The Solution](#the-solution)
- [Quick Start](#quick-start)
- [Example Output](#example-output)
- [Multiple Root Folders](#multiple-root-folders)
- [Key Concepts](#key-concepts)
- [Maintenance](#maintenance)
- [Best Practices](#best-practices)
- [Validation Tool](#validation-tool)
- [Troubleshooting](#troubleshooting)
- [Why TOML?](#why-toml)
- [Credits](#credits)
- [License](#license)

## The Problem

AI coding assistants struggle with large codebases:
- Single snapshot files consume too many context tokens
- AI needs to read many files to understand architecture
- No standardized way to document codebase structure for AI

## The Solution

**ai_project_index** provides:
- **Split snapshots** — Multiple focused TOML files instead of one large file
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

Use the snapshot concept described in INIT.md to organize the codebase by feature/domain.
```

**What to expect:**
- The AI will ask clarifying questions about your project structure
- It will read files across your codebase to understand the architecture
- For large projects (>10,000 LOC), this may take several interactions
- You can review and refine the generated TOML files afterward

### 3. Append the instruction to your AI markdown instructions.

```
**Important** Read:
  - Project index: `ai_project_index/ai_project_index.toml`
  - Modules: `ai_project_index/modules/*.toml`
```

### 4. Add or ignore `ai_project_index/` (Optional)

You can choose to commit the generated index files to version control or ignore them:

**Option A: Commit to repository** (Recommended for teams)
```bash
git add ai_project_index/
git commit -m "Add AI project index"
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
│   ├── INIT.md                        # Setup instructions for AI
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

[project]
languages = ["Python", "JavaScript"]
frameworks = ["FastAPI", "React"]
build_system = "poetry"

[[module]]
name = "auth"
location = "src/modules/auth/"
description = "User authentication and session management"
file = "ai_project_index/modules/auth.toml"

[[module]]
name = "api"
location = "src/api/"
description = "REST API endpoints and routes"
file = "ai_project_index/modules/api.toml"
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

### Treat as Living Documentation
- Update alongside code changes (see [Maintenance](#maintenance))
- Review and refine periodically
- Remove outdated information promptly
- Keep files concise to save future tokens

## Validation Tool

**ai_project_index** includes a validation tool to ensure your TOML files are correct and up-to-date.

### Quick Validation

```bash
# Download and run validation
curl -fsSL https://raw.githubusercontent.com/keitheis/ai_project_index/main/validate.py -o validate.py
chmod +x validate.py
python3 validate.py
```

Or if you cloned the repository:
```bash
./validate.py -v
```

### What It Checks

- ✅ TOML syntax errors
- ✅ File path existence (entry points, components, modules)
- ✅ Module cross-references (declared vs actual)
- ✅ Required fields presence
- ✅ TODO placeholders detection
- ✅ Orphaned module files

### Example Output

```bash
$ ./validate.py -v

ℹ️  INFO:
  • Validating: ai_project_index/ai_project_index.toml
  • Found 3 module file(s)
  • Cross-reference check: 3/3 modules found

============================================================
✅ VALIDATION PASSED
   No issues found
============================================================
```

### Installation

The validation tool requires Python 3.7+ and `tomli`:

```bash
pip install tomli
```

For Python 3.11+, `tomllib` is built-in (no installation needed).

### Usage Options

```bash
./validate.py              # Validate current project
./validate.py -v           # Verbose output
./validate.py -p /path     # Validate specific project
./validate.py --json       # JSON output for CI/CD
./validate.py -q           # Quiet mode (errors only)
```

See [VALIDATION.md](VALIDATION.md) for detailed documentation, CI/CD integration examples, and troubleshooting.

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

### AI still reads too many files

**Problem**: AI doesn't use the index and reads files directly.

**Solutions**:
1. Ensure the instruction is in your AI's prompt/context:
   ```
   **Important** Read:
     - Project index: `ai_project_index/ai_project_index.toml`
     - Modules: `ai_project_index/modules/*.toml`
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

## Credits

This project builds upon the snapshot concept introduced in [小海嚴寫 Vibe Coding: Snapshot 2.0](https://tzangms.com/vibe-coding-snapshot-2-0/) by tzangms. The idea of creating structured, AI-friendly codebase documentation to reduce token consumption was pioneered in that work.

**ai_project_index** extends this with:
- Formalized TOML structure for better parsing
- Multi-module organization for larger codebases
- Cross-reference tracking for dependencies
- Language-agnostic approach

## License

MIT
