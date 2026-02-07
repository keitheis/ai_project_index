# AI Analysis Instructions

Welcome! This file guides you through analyzing this codebase and building a structured index.

## Goal

Build a **navigational map** of this codebase — not a copy, not an exhaustive listing, but a concise guide that helps any AI assistant quickly orient itself and make safe changes.

The result is a set of TOML files that answer: *"What does this project do, how is it organized, what are the boundaries, and where should I look?"*

## Analysis Roots

Analyze starting from: **{{ROOT_FOLDERS}}**

## Principles (Read Before Starting)

1. **Map, not territory** — Document structure and relationships, not implementation details. An AI can read source files; it cannot easily infer architecture.
2. **Hierarchical navigation** — The index supports a "zoom in" workflow: `ai_project_index.toml` → `modules/*.toml` → actual source files.
3. **Boundaries over details** — The most valuable information is *what must not cross what*. Architectural rules prevent entire classes of bugs.
4. **Gotchas save the most time** — A single documented pitfall can save thousands of tokens of debugging. Prioritize surprises.
5. **Lean is better** — Every line in the index is read on every future interaction. Remove anything that doesn't earn its tokens.

## Step-by-Step Process

### Step 1: Orient — Understand the Project

Explore the codebase to build a mental model:
- What programming language(s) and framework(s)?
- How is code organized? (monolith, modules, layers, domains)
- What are the main entry points?
- What are the key external dependencies?

**Actions:**
- Read: README.md, package/dependency files (package.json, requirements.txt, go.mod, Cargo.toml, etc.)
- Read: Main entry point file(s)
- Scan: Top-level directory structure

### Step 2: Fill in ai_project_index.toml

Update `ai_project_index/ai_project_index.toml` section by section:

| Section | What to fill in | Priority |
|---------|----------------|----------|
| `[meta]` + `[meta.tech]` | Project name, description, tech stack | **Must** |
| `[structure]` | Folder layout | **Must** |
| `[modules]` | Module file references | **Must** |
| `[entry_points]` | Main files | **Must** |
| `[boundaries]` | Architectural rules | **High** — this prevents bugs |
| `[gotchas]` | Surprising behaviors, traps | **High** — this saves debugging time |
| `[change_risk]` | High-risk / fragile areas | **High** — this prevents breakage |
| `[commands]` | Dev workflow commands | Medium |
| `[dependencies.external]` | Key libraries | Medium |
| `[conventions]` | Coding patterns | Medium |
| `[notes]` | Migration status, special context | If applicable |

**Important:** Keep descriptions concise. One sentence per value. Remove any section that has no useful content — empty sections waste tokens.

### Step 3: Identify Modules

Look for logical groupings:
- **Features**: authentication, user management, payments, notifications
- **Domains**: orders, inventory, shipping (DDD-style)
- **Layers**: core utilities, data access, API routes, UI components

Each significant grouping should get its own TOML file.

**Rule of thumb:** If a group has 3+ related files with shared dependencies, it deserves a module file.

### Step 4: Create Module Files

For each module, create `ai_project_index/modules/{module_name}.toml`:

```toml
[meta]
name = "module_name"
location = "path/to/module/"
description = "What this module does — one sentence"

# Document key components using typed arrays:

[[model]]
name = "User"
file = "src/auth/models/user.py"
purpose = "User entity with credentials and roles"

[[service]]
name = "AuthService"
file = "src/auth/service.py"
purpose = "Login, logout, token generation and validation"

[dependencies]
core = ["src/core/http.py", "src/core/logger.py"]
modules = ["src/users/models.py"]
external = ["bcrypt", "pyjwt"]

[usage]
imported_by = [
    "src/api/routes/auth.py",
    "src/api/middleware/auth_middleware.py",
]
```

**Component types** — use whatever fits the project:
- `[[model]]` — Data structures, entities, domain objects
- `[[service]]` — Business logic, use cases
- `[[repository]]` — Data access layer
- `[[controller]]` / `[[handler]]` — API endpoints, route handlers
- `[[component]]` — UI components, widgets
- `[[utility]]` — Helpers, shared tools
- `[[middleware]]` — Interceptors, filters
- `[[config]]` — Configuration modules

### Step 5: Track Dependencies and Usage

For each module, document:
- **`[dependencies]`** — What it depends on (imports, calls)
- **`[usage]`** — What depends on it (imported_by)

This enables:
- Safe refactoring (know the blast radius before changing)
- Architectural analysis (detect coupling problems)
- Quick navigation (find related code)

### Step 6: Verify and Trim

Before finishing, check:

1. **Accuracy** — Do file paths actually exist? Do descriptions match reality?
2. **Completeness** — Are all significant modules represented? Are boundaries documented?
3. **Leanness** — Remove:
   - Empty or placeholder sections (delete them, don't leave `TODO`)
   - Obvious information (don't document that `main.py` is the main file if it's the only file)
   - Implementation details (AI can read the source)
   - Commented-out examples from the template

The final index should be **compact and accurate** — every line earns its place.

## What Good Looks Like

**Good module description:**
```toml
description = "JWT-based authentication with role-based access control"
```

**Bad module description:**
```toml
description = "This module handles authentication"  # Too vague
description = "Contains user.py, service.py, and middleware.py with classes for User, AuthService..."  # Too detailed
```

**Good gotcha:**
```toml
[gotchas]
"session_store" = "Sessions use Redis — app fails silently if Redis is down"
```

**Good boundary:**
```toml
[boundaries]
forbidden = ["handlers -> database (must go through repository layer)"]
```

## Expected Output

```
ai_project_index/
├── ai_project_index.toml       # Main index (completed, trimmed)
└── modules/
    ├── core.toml               # Shared infrastructure
    ├── auth.toml               # Authentication module
    ├── users.toml              # User management
    └── ...                     # Other modules
```

## Final Step

After creating all files, **delete this INIT.md file** — it has served its purpose and should not consume tokens in future interactions.

Begin by reading `ai_project_index/ai_project_index.toml` and updating it with your findings. Then create module files as you identify logical groupings.
