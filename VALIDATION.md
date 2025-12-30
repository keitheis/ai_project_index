# Validation Tool

The `validate.py` script helps ensure your ai_project_index files are correct and up-to-date.

## Quick Start

```bash
# Validate current project
./validate.py

# Validate specific project
./validate.py -p /path/to/project

# Verbose output with details
./validate.py -v

# JSON output for CI/CD
./validate.py --json
```

## What It Checks

### ✅ TOML Syntax
- Valid TOML format in all files
- No syntax errors

### ✅ File References
- All file paths exist
- Entry points are valid
- Component files are present
- Structure paths are correct

### ✅ Module Integrity
- Modules declared in main index have corresponding files
- Module locations exist
- Dependencies reference valid paths

### ✅ Cross-References
- Module files match declarations
- No orphaned module files
- Dependency tracking is valid

### ✅ Required Fields
- [meta] sections present
- Required fields populated
- Detects TODO placeholders

## Exit Codes

- `0` - Validation passed (may have warnings)
- `1` - Validation failed (has errors)
- `2` - Invalid arguments or setup error

## Examples

### Example: All Good

```bash
$ ./validate.py -v

ℹ️  INFO:
  • Validating: ai_project_index/ai_project_index.toml
  • Found 3 module file(s)
  • Validating module: core.toml
  • Validating module: auth.toml
  • Validating module: api.toml
  • Cross-reference check: 3/3 modules found

============================================================
✅ VALIDATION PASSED
   No issues found
============================================================
```

### Example: Errors Found

```bash
$ ./validate.py

❌ ERRORS:
  • ai_project_index/modules/auth.toml: Location not found: src/modules/auth/
  • ai_project_index/modules/auth.toml: [[model]] 'User' file not found: src/auth/user.py

⚠️  WARNINGS:
  • ai_project_index/ai_project_index.toml: [structure].tests path not found: tests/
  • Module file exists but not declared in main index: modules/old_feature.toml

============================================================
❌ VALIDATION FAILED
   2 error(s), 2 warning(s)
============================================================
```

### Example: JSON Output for CI/CD

```bash
$ ./validate.py --json
{
  "errors": [],
  "warnings": [
    "ai_project_index/ai_project_index.toml: [meta] 'description' is still TODO"
  ],
  "info": [],
  "status": "passed"
}
```

## CLI Options

```
  -p PATH, --path PATH  Path to project directory (default: current directory)
  -i INDEX, --index INDEX
                        Name of index directory (default: ai_project_index)
  -v, --verbose         Verbose output with detailed information
  -q, --quiet           Quiet mode (errors only, no warnings)
  --json                Output results as JSON
  --no-color            Disable colored output
```

## Integration with CI/CD

### GitHub Actions

```yaml
name: Validate AI Index

on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      - name: Install dependencies
        run: pip install tomli
      - name: Validate ai_project_index
        run: ./validate.py --json
```

### Pre-commit Hook

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash
if [ -d "ai_project_index" ]; then
    echo "Validating ai_project_index..."
    ./validate.py -q
    if [ $? -ne 0 ]; then
        echo "❌ Validation failed. Fix errors before committing."
        exit 1
    fi
fi
```

### Makefile Integration

```makefile
.PHONY: validate-index
validate-index:
	@./validate.py

.PHONY: validate-index-strict
validate-index-strict:
	@./validate.py --json | jq -e '.status == "passed" and (.warnings | length) == 0'
```

## Dependencies

The validation tool requires Python 3.7+ and the `tomli` library:

```bash
pip install tomli
```

For Python 3.11+, `tomllib` is built-in (no installation needed).

## Common Issues

### Missing Files

**Problem:** File references in TOML don't exist

**Solution:**
- Update TOML files to remove references to deleted files
- Create missing files
- Verify paths are correct

### Orphaned Modules

**Problem:** Module TOML exists but not declared in main index

**Solution:**
```toml
# In ai_project_index.toml, add:
[modules]
my_module = "modules/my_module.toml"
```

### TODO Placeholders

**Problem:** Fields still have TODO values

**Solution:** Update with actual values:
```toml
[meta]
name = "MyProject"  # Not "TODO"
description = "Real description here"  # Not "TODO"
```

## Best Practices

1. **Run before commits** - Validate before committing index changes
2. **Use in CI/CD** - Catch issues automatically
3. **Fix errors first** - Address errors before warnings
4. **Keep it green** - Aim for zero errors and warnings
5. **Validate after refactoring** - Ensure index stays in sync with code

## Troubleshooting

### Script won't run

```bash
# Make executable
chmod +x validate.py

# Or run with Python directly
python3 validate.py
```

### Import error for tomli

```bash
pip install tomli
# Or use pip3 if needed
pip3 install tomli
```

### Path issues

Make sure to run from project root or use `-p` flag:
```bash
# From project root
./validate.py

# From anywhere
./validate.py -p /path/to/project
```
