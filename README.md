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
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)
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
1. Use structured thinking and chain-of-thought reasoning
2. Analyze this project's structure and modules systematically
3. Create/update ai_project_index/ai_project_index.toml with project metadata
4. Create module-specific TOML files in ai_project_index/modules/
5. Follow the validation checklist in INIT.md

Use the snapshot concept described in INIT.md to organize the codebase by feature/domain.
```

**What to expect:**
- The AI will use structured thinking to understand your project
- It will ask clarifying questions about your project structure if needed
- It will read files across your codebase to understand the architecture
- For large projects (>10,000 LOC), this may take several interactions
- You can review and refine the generated TOML files afterward

**Modern AI Features:**
- Chain-of-thought reasoning for better analysis
- Structured discovery and documentation phases
- Validation checklists for quality assurance
- Token-efficient documentation strategies

### 3. Validate the generated index (Optional but recommended)

After AI analysis, validate the TOML files:

```bash
# If you cloned the repo locally
/tmp/ai_project_index/validate.sh ai_project_index

# Or if validate.sh is in your PATH
validate.sh ai_project_index
```

This checks:
- TOML syntax validity
- Required sections presence
- Basic structure correctness

### 4. Append the instruction to your AI markdown instructions

Add to your AI assistant's instructions (e.g., `.cursorrules`, `CLAUDE.md`, or IDE settings):

```markdown
## Architecture/Modules/Project Index

**Read first:**
- `ai_project_index/ai_project_index.toml` (project overview)
- Relevant `ai_project_index/modules/*.toml` files (module details)

Use the index to navigate the codebase efficiently.
When making architectural changes, update the index to keep it in sync.
```

### 5. Add or ignore `ai_project_index/` (Optional)

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
schema_version = "2.0"
created_at = "2026-02-07T00:00:00Z"
updated_at = "2026-02-07T00:00:00Z"
roots = ["src", "lib"]
description = "A web application with authentication and API"
complexity = "medium"

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
- Update updated_at timestamp in ai_project_index.toml
```

**Option 2: Full regeneration**

For major refactoring or structural changes, regenerate from scratch:
```bash
# Back up current index
cp -r ai_project_index ai_project_index.backup

# Ask AI to regenerate (use the Step 2 prompt from Quick Start)
```

**Option 3: Validation after updates**

Always validate after updates:
```bash
validate.sh ai_project_index
```

This ensures TOML syntax is correct and structure is valid.

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
- Use structured thinking: Discovery → Architecture → Documentation → Validation

### Be Consistent
- Use similar TOML structure across modules
- Maintain consistent naming conventions
- Keep descriptions at the same level of abstraction
- Follow the schema version (currently 2.0)

### Focus on Architecture
- Document boundaries between modules
- Highlight public APIs and interfaces
- Skip private implementation details
- Think in layers: Core → Modules → Features
- Use chain-of-thought reasoning when documenting

### Treat as Living Documentation
- Update alongside code changes (see [Maintenance](#maintenance))
- Review and refine periodically
- Remove outdated information promptly
- Keep files concise to save future tokens
- Update `updated_at` timestamp when making changes
- Validate after updates using `validate.sh`

### Token Efficiency
- Document only what helps AI navigate faster
- If reading TOML saves reading 2+ source files → Include it
- If it's faster to read source → Skip it
- Focus on stable architectural knowledge, not implementation details

### AI Integration
- Add index instructions to your AI assistant's context
- Use the index proactively in AI conversations
- Reference specific modules when discussing features
- Update index when AI suggests architectural changes

## Validation

After generating or updating your index, validate it:

```bash
# Using the validation script
validate.sh ai_project_index

# Or if you have Python 3.11+ with tomllib
python3 -c "import tomllib; tomllib.load(open('ai_project_index/ai_project_index.toml', 'rb'))"
```

The validation script checks:
- ✅ TOML syntax validity
- ✅ Required `[meta]` sections
- ✅ Basic structure correctness
- ✅ File references

**Note**: For full validation, install a TOML parser:
- Python 3.11+: Built-in `tomllib`
- Python 3.10 and below: `pip install tomli`

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

4. Run validation to check for issues:
   ```bash
   validate.sh ai_project_index
   ```

### TOML validation fails

**Problem**: Validation script reports syntax errors.

**Solutions**:
1. Check TOML syntax using an online validator or Python:
   ```bash
   python3 -c "import tomllib; tomllib.load(open('ai_project_index/ai_project_index.toml', 'rb'))"
   ```

2. Common issues:
   - Missing quotes around strings with special characters
   - Incorrect array syntax
   - Missing closing brackets
   - Invalid date format in timestamps (use ISO 8601)

3. Fix syntax errors and re-validate

## Why TOML?

- **Human-readable** — Easy to read and write
- **Structured** — Supports nested sections and arrays
- **Comments** — Include explanatory notes
- **Universal** — Parsers available in all languages
- **AI-friendly** — Clear structure helps AI understand relationships
- **Version-controlled** — Diff-friendly format for tracking changes

## Schema Version

Current schema version: **2.0**

Schema 2.0 includes:
- Version tracking (`schema_version`, `version`)
- Timestamps (`created_at`, `updated_at`)
- Complexity indicators (`complexity`)
- Enhanced AI context hints (`[ai_context]`)
- Additional command types (`type_check`, `generate`)

When updating from older schemas, ensure compatibility or migrate accordingly.

## Credits

This project builds upon the snapshot concept introduced in [小海嚴寫 Vibe Coding: Snapshot 2.0](https://tzangms.com/vibe-coding-snapshot-2-0/) by tzangms. The idea of creating structured, AI-friendly codebase documentation to reduce token consumption was pioneered in that work.

**ai_project_index** extends this with:
- Formalized TOML structure for better parsing
- Multi-module organization for larger codebases
- Cross-reference tracking for dependencies
- Language-agnostic approach

## License

MIT
