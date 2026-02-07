#!/bin/bash
# ai_project_index - TOML validation script
# Validates TOML files for syntax errors and basic structure

set -e
set -u

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_info() { echo -e "${BLUE}→${NC} $1"; }

# Check if TOML parser is available
check_toml_parser() {
    if command -v toml >/dev/null 2>&1; then
        return 0
    elif command -v python3 >/dev/null 2>&1; then
        # Check if tomli or tomllib is available
        python3 -c "import tomli" 2>/dev/null && return 0
        python3 -c "import tomllib" 2>/dev/null && return 0
    fi
    return 1
}

# Validate TOML syntax using Python
validate_toml_python() {
    local file="$1"
    python3 <<EOF
import sys
try:
    # Try tomllib (Python 3.11+)
    try:
        import tomllib
        with open("$file", "rb") as f:
            tomllib.load(f)
    except ImportError:
        # Fallback to tomli
        import tomli
        with open("$file", "rb") as f:
            tomli.load(f)
    sys.exit(0)
except Exception as e:
    print(f"TOML syntax error: {e}", file=sys.stderr)
    sys.exit(1)
EOF
}

# Basic structure validation
validate_structure() {
    local file="$1"
    local errors=0
    
    # Check for required [meta] section
    if ! grep -q "^\[meta\]" "$file"; then
        print_error "$file: Missing [meta] section"
        errors=$((errors + 1))
    fi
    
    # Check for meta.name
    if ! grep -q "^name\s*=" "$file"; then
        print_warning "$file: Missing 'name' in [meta] section"
    fi
    
    # Check for meta.roots (in main index only)
    if [[ "$file" == *"ai_project_index.toml" ]]; then
        if ! grep -q "^roots\s*=" "$file"; then
            print_warning "$file: Missing 'roots' in [meta] section"
        fi
    fi
    
    return $errors
}

# Main validation function
main() {
    local INDEX_DIR="${1:-ai_project_index}"
    
    if [ ! -d "$INDEX_DIR" ]; then
        print_error "Directory not found: $INDEX_DIR"
        echo "Usage: $0 [ai_project_index_directory]"
        exit 1
    fi
    
    print_info "Validating ai_project_index files in: $INDEX_DIR"
    echo ""
    
    local total_files=0
    local valid_files=0
    local invalid_files=0
    
    # Validate main index
    local main_index="$INDEX_DIR/ai_project_index.toml"
    if [ -f "$main_index" ]; then
        total_files=$((total_files + 1))
        print_info "Validating: $main_index"
        
        if check_toml_parser; then
            if validate_toml_python "$main_index" 2>/dev/null; then
                print_success "Syntax: Valid"
                validate_structure "$main_index" || invalid_files=$((invalid_files + 1))
                valid_files=$((valid_files + 1))
            else
                print_error "Syntax: Invalid"
                invalid_files=$((invalid_files + 1))
            fi
        else
            print_warning "No TOML parser found. Installing one recommended:"
            echo "  pip install tomli  # Python 3.10 and below"
            echo "  # Python 3.11+ has tomllib built-in"
            validate_structure "$main_index" || invalid_files=$((invalid_files + 1))
        fi
        echo ""
    else
        print_warning "Main index not found: $main_index"
    fi
    
    # Validate module files
    local modules_dir="$INDEX_DIR/modules"
    if [ -d "$modules_dir" ]; then
        while IFS= read -r -d '' file; do
            total_files=$((total_files + 1))
            print_info "Validating: $file"
            
            if check_toml_parser; then
                if validate_toml_python "$file" 2>/dev/null; then
                    print_success "Syntax: Valid"
                    validate_structure "$file" || invalid_files=$((invalid_files + 1))
                    valid_files=$((valid_files + 1))
                else
                    print_error "Syntax: Invalid"
                    invalid_files=$((invalid_files + 1))
                fi
            else
                validate_structure "$file" || invalid_files=$((invalid_files + 1))
            fi
            echo ""
        done < <(find "$modules_dir" -name "*.toml" -type f -print0 2>/dev/null)
    else
        print_warning "Modules directory not found: $modules_dir"
    fi
    
    # Summary
    echo ""
    print_info "Validation Summary:"
    echo "  Total files: $total_files"
    echo "  Valid: $valid_files"
    echo "  Issues: $invalid_files"
    
    if [ $invalid_files -eq 0 ] && [ $total_files -gt 0 ]; then
        print_success "All files validated successfully!"
        exit 0
    elif [ $total_files -eq 0 ]; then
        print_warning "No TOML files found to validate"
        exit 0
    else
        print_error "Validation found issues"
        exit 1
    fi
}

main "$@"
