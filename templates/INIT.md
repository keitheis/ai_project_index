# AI Analysis Instructions

Welcome! This file guides you through analyzing this codebase and creating a structured index.

## Objective

Create a **split snapshot** system using TOML files to document this codebase efficiently.
This reduces token usage by allowing AI assistants to read only relevant parts of the architecture.

## Analysis Roots

Analyze starting from: **{{ROOT_FOLDERS}}**

(Multiple root folders can be specified to analyze different parts of the codebase separately)

## Thinking Framework

Before starting, adopt a structured thinking approach:

1. **Discovery Phase**: Understand the "what" - what does this project do?
2. **Architecture Phase**: Understand the "how" - how is it organized?
3. **Documentation Phase**: Create the "map" - document structure efficiently
4. **Validation Phase**: Verify completeness and accuracy

Use **chain-of-thought reasoning**:
- For each decision, explain your reasoning
- When identifying modules, explain why they're grouped together
- When documenting components, explain their role in the larger system

## Step-by-Step Process

### 1. Understand the Project Structure

**Chain-of-Thought Approach:**
1. Start with high-level discovery
2. Identify patterns and conventions
3. Map relationships between components
4. Validate understanding before documenting

**Discovery Checklist:**
- [ ] What programming language(s) are used?
- [ ] What framework(s) or libraries are central?
- [ ] How is the code organized? (monolith, modules, features, domains)
- [ ] What are the main entry points?
- [ ] What are the key external dependencies?
- [ ] What is the build/test/deploy workflow?
- [ ] Are there any architectural patterns (MVC, DDD, Clean Architecture, etc.)?

**Action:** Read key files systematically:
1. **Documentation**: README.md, CONTRIBUTING.md, ARCHITECTURE.md (if exists)
2. **Dependencies**: package.json, requirements.txt, go.mod, Cargo.toml, pubspec.yaml, etc.
3. **Configuration**: Build configs, linter configs, CI/CD configs
4. **Entry Points**: Main files, app initialization, CLI entry points
5. **Structure**: Directory tree (use `find . -type f -name "*.ext" | head -20` for sampling)

**Reasoning Prompt**: After reading, summarize:
- "This project appears to be a [type] built with [tech stack]"
- "The code is organized using [pattern]"
- "Key architectural decisions include: [list]"

### 2. Update ai_project_index.toml

**Structured Approach:**
Fill in sections systematically, using your discovery findings:

**Priority Order:**
1. `[meta]` - Core project metadata (name, version, roots, language, framework, architecture)
   - Set `created_at` to current ISO 8601 timestamp
   - Assess `complexity` based on codebase size and structure
2. `[structure]` - Folder organization (helps AI navigate)
3. `[entry_points]` - Main files (where to start reading)
4. `[commands]` - Development workflow (how to work with project)
5. `[dependencies.external]` - Key libraries (only critical ones, not exhaustive)
6. `[conventions]` - Patterns AI should follow (naming, imports, error handling)
7. `[ai_context]` - Hints for AI decision-making

**Quality Checklist:**
- [ ] All TODOs replaced with actual values
- [ ] Descriptions are concise (1-2 sentences max)
- [ ] Focus on "what" and "why", not "how"
- [ ] Timestamps are ISO 8601 format
- [ ] Complexity assessment is reasonable

**Important:** Keep descriptions concise. Focus on "what" and "why", not implementation details.
Think: "If I were an AI reading this, what would help me understand fastest?"

### 3. Identify Modules/Features

**Module Identification Strategy:**

Use **domain-driven thinking**:
1. **Feature-based**: Group by user-facing features (auth, payments, notifications)
2. **Domain-based**: Group by business domains (orders, inventory, shipping)
3. **Layer-based**: Group by technical layers (core, data, api, ui)
4. **Hybrid**: Combine approaches as needed

**Decision Framework:**
- **Size**: Module should represent 3-20 files (adjust based on project size)
- **Cohesion**: Files in module should be closely related
- **Coupling**: Module should have clear boundaries
- **Stability**: Module's purpose shouldn't change frequently

**Module Identification Process:**
1. List all top-level directories in root folders
2. For each directory, ask: "Is this a cohesive unit?"
3. Group related directories if they form a logical feature
4. Create modules for: core infrastructure, major features, shared utilities

**Reasoning**: Document why you grouped things together:
- "auth module includes login, registration, and session management"
- "core module contains shared utilities used across all features"

### 4. Create Module Files

**For each module**, create `ai_project_index/modules/{module_name}.toml` with:

**Template Structure:**
```toml
[meta]
name = "module_name"
location = "path/to/module"
description = "What this module does"
complexity = "low"  # or "medium", "high" - helps prioritize

# Document key components using arrays:

[[model]]
name = "ComponentName"
file = "relative/path/to/file.ext"
purpose = "Brief description"
exports = ["export1", "export2"]  # What this file exports
# Optional: complexity = "low", test_coverage = "high"

[[service]]
# ... similar structure for services, controllers, utilities, etc.

[dependencies]
core = ["shared/utils", "shared/types"]
modules = ["other_module/something"]
external = ["library_name"]

[usage]
imported_by = ["path/to/file1", "path/to/file2"]  # For refactoring safety
```

**Component Documentation Strategy:**
- **Document public APIs**: Focus on what's exported/imported
- **Document responsibilities**: What does this component do?
- **Document relationships**: How does it relate to other components?
- **Skip implementation details**: AI can read source code when needed

**Quality Guidelines:**
- Each component entry should be 1-3 lines
- Focus on architectural role, not implementation
- Include `exports` to help AI understand public interface
- Track `imported_by` for safe refactoring

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

**Value Assessment Framework:**

When documenting, ask yourself:
- **Would this help an AI understand the codebase faster?**
- **Does this reduce the need to read multiple files?**
- **Is this information stable (doesn't change often)?**
- **Would this help AI make better decisions?**
- **Is this architectural knowledge vs. implementation detail?**

**Include (High Value):**
- ✅ Component purposes and responsibilities
- ✅ Relationships between modules
- ✅ Architectural constraints and rules
- ✅ Key patterns and conventions
- ✅ Public APIs and interfaces
- ✅ Dependency directions (who depends on whom)
- ✅ Entry points and initialization flow

**Exclude (Low Value):**
- ❌ Implementation details (AI can read the source)
- ❌ Frequently changing data
- ❌ Obvious information (e.g., "this file contains code")
- ❌ Every single function or class
- ❌ Code examples or snippets
- ❌ Detailed algorithm descriptions

**Token Efficiency Principle:**
- If reading the TOML saves reading 2+ source files → Include it
- If it's faster to read the source → Skip it
- If it changes frequently → Skip it

## Best Practices

1. **Start small** - Document high-level structure first, add details iteratively
2. **Be consistent** - Use similar structure for similar modules
3. **Keep it current** - Update when architecture changes
4. **Be concise** - Prioritize clarity over completeness
5. **Think in layers** - Core → Modules → Features
6. **Use reasoning** - Explain your decisions in comments when helpful
7. **Validate incrementally** - Check each module file before moving to next
8. **Prioritize stability** - Focus on architectural knowledge, not implementation

## Validation Checklist

Before completing, verify:

- [ ] All `[meta]` sections have required fields
- [ ] Module files reference correct paths
- [ ] Dependencies are accurate
- [ ] No circular dependencies in documentation
- [ ] Entry points are correct
- [ ] Commands are accurate and tested
- [ ] Timestamps are set
- [ ] Complexity assessments are reasonable
- [ ] TOML syntax is valid (no parsing errors)

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

## Execution Plan

**Recommended Workflow:**

1. **Phase 1: Discovery** (5-10 minutes)
   - Read key files
   - Understand project structure
   - Identify main patterns

2. **Phase 2: Main Index** (5 minutes)
   - Update `ai_project_index.toml`
   - Fill all sections systematically
   - Set timestamps

3. **Phase 3: Modules** (10-30 minutes, depends on project size)
   - Identify modules
   - Create module TOML files
   - Document components and dependencies

4. **Phase 4: Validation** (5 minutes)
   - Review all files
   - Check for completeness
   - Verify paths and references

5. **Phase 5: Cleanup** (2 minutes)
   - Remove this INIT.md file (as instructed)
   - Final review

**Pro Tips:**
- Work incrementally: complete one module before starting next
- Ask user for clarification if architecture is unclear
- Don't over-document: less is more for token efficiency
- Focus on what helps AI navigate, not exhaustive details

## Ready?

Begin by reading `ai_project_index/ai_project_index.toml` and updating it with your findings.
Then create module files as you identify logical groupings.

**Remember**: This is a map, not a copy. Focus on navigation and understanding, not completeness.

Good luck!
