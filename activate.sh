#!/bin/bash
# ai_project_index - Framework initialization script
# Usage: curl -fsSL https://raw.githubusercontent.com/keitheis/ai_project_index/main/activate.sh | bash
#    or: ./activate.sh [target_directory]

set -e  # Exit on error
set -u  # Exit on undefined variable

# CONSTANTS & CONFIGURATION
VERSION="1.0.0"
GITHUB_RAW_BASE="https://raw.githubusercontent.com/keitheis/ai_project_index/main"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# HELPER FUNCTIONS

print_header() {
    echo -e "${BLUE}  ai_project_index v$VERSION${NC}"
    echo ""
}

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_info() { echo -e "${BLUE}→${NC} $1"; }

error_exit() {
    print_error "$1"
    exit 1
}

# Check if running via pipe (curl | bash)
is_piped() {
    [ ! -t 0 ]
}

# Prompt for confirmation (read from /dev/tty if piped)
confirm() {
    local prompt="$1"
    local response
    if is_piped; then
        echo -n "$prompt [y/N]: "
        read response </dev/tty
    else
        read -p "$prompt [y/N]: " response
    fi
    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

# Download template from GitHub
download_template() {
    local template_name="$1"
    local url="${GITHUB_RAW_BASE}/templates/${template_name}"

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO- "$url"
    else
        error_exit "Neither curl nor wget found. Please install one of them."
    fi
}

# MAIN LOGIC

main() {
    print_header

    # Determine execution mode and target directory
    # Strategy: Check if local templates exist to determine mode
    local USE_REMOTE=false
    local SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-}")" 2>/dev/null && pwd || echo "")"

    # Check if local templates directory exists
    if [ -n "$SCRIPT_DIR" ] && [ -d "$SCRIPT_DIR/templates" ]; then
        USE_REMOTE=false
    else
        USE_REMOTE=true
    fi

    # Determine target directory
    if [ -n "${1:-}" ]; then
        # Argument provided - use it
        TARGET_DIR="$1"
        TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd || echo "$TARGET_DIR")"
        print_info "Target directory: $TARGET_DIR"
    elif is_piped; then
        # No argument, running via curl | bash
        TARGET_DIR="$(pwd)"
        if [ "$USE_REMOTE" = true ]; then
            print_info "Running via curl | bash"
        fi
        print_info "Target directory: $TARGET_DIR"
    else
        # No argument, not piped - use current directory
        TARGET_DIR="."
        TARGET_DIR="$(pwd)"
        print_info "Target directory: $TARGET_DIR"
    fi

    # Validate target directory
    if [ ! -d "$TARGET_DIR" ]; then
        error_exit "Directory does not exist: $TARGET_DIR"
    fi

    if [ ! -w "$TARGET_DIR" ]; then
        error_exit "Directory is not writable: $TARGET_DIR"
    fi

    # Define paths
    INDEX_DIR="$TARGET_DIR/ai_project_index"
    MODULES_DIR="$INDEX_DIR/modules"

    # Check if ai_project_index already exists
    if [ -d "$INDEX_DIR" ]; then
        print_warning "ai_project_index/ already exists in $TARGET_DIR"
        if ! confirm "Do you want to overwrite it?"; then
            echo "Cancelled. No changes made."
            exit 0
        fi
        print_warning "Proceeding with overwrite..."
    fi

    # Create directory structure
    print_info "Creating directory structure..."
    mkdir -p "$MODULES_DIR"
    print_success "Created: $MODULES_DIR"

    # Interactive: Ask for root folders to analyze
    echo ""
    print_info "Which folder(s) should I analyze?"
    echo "  These are the roots of your source code (e.g., src, lib, .)"
    echo "  You can specify multiple folders separated by commas or spaces"
    echo "  Examples: 'src' or 'src,lib' or 'frontend backend'"
    if is_piped; then
        echo -n "  Path(s) (default: .): "
        read ANALYZE_ROOTS_INPUT </dev/tty
    else
        read -p "  Path(s) (default: .): " ANALYZE_ROOTS_INPUT
    fi
    ANALYZE_ROOTS_INPUT="${ANALYZE_ROOTS_INPUT:-.}"

    # Parse input: split by comma or space
    IFS=', ' read -ra ROOT_ARRAY <<< "$ANALYZE_ROOTS_INPUT"

    # Validate and normalize each root folder
    NORMALIZED_ROOTS=()
    for root in "${ROOT_ARRAY[@]}"; do
        # Trim whitespace
        root=$(echo "$root" | xargs)
        [ -z "$root" ] && continue

        # Validate folder exists
        FULL_PATH="$TARGET_DIR/$root"
        if [ ! -d "$FULL_PATH" ]; then
            error_exit "Folder does not exist: $FULL_PATH"
        fi

        # Normalize path
        normalized="$(cd "$TARGET_DIR" && cd "$root" && pwd | sed "s|^$TARGET_DIR/||")"
        [ "$normalized" = "$TARGET_DIR" ] && normalized="."

        NORMALIZED_ROOTS+=("$normalized")
    done

    # Format as TOML array
    TOML_ROOTS=""
    for i in "${!NORMALIZED_ROOTS[@]}"; do
        if [ $i -gt 0 ]; then
            TOML_ROOTS+=", "
        fi
        TOML_ROOTS+="\"${NORMALIZED_ROOTS[$i]}\""
    done

    print_success "Will analyze: ${NORMALIZED_ROOTS[*]}"

    # Get project name from directory
    PROJECT_NAME="$(basename "$TARGET_DIR")"

    # Generate ai_project_index.toml
    print_info "Creating ai_project_index.toml..."

    if [ "$USE_REMOTE" = true ]; then
        # Download from GitHub
        download_template "ai_project_index.toml" | \
            sed "s|{{ROOT_FOLDERS}}|$TOML_ROOTS|g" | \
            sed "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
            > "$INDEX_DIR/ai_project_index.toml"
    else
        # Use local template
        TEMPLATE_FILE="$SCRIPT_DIR/templates/ai_project_index.toml"

        if [ ! -f "$TEMPLATE_FILE" ]; then
            error_exit "Template not found: $TEMPLATE_FILE"
        fi

        sed "s|{{ROOT_FOLDERS}}|$TOML_ROOTS|g" "$TEMPLATE_FILE" | \
            sed "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
            > "$INDEX_DIR/ai_project_index.toml"
    fi

    print_success "Created: ai_project_index.toml"

    # Generate INIT.md file
    print_info "Creating INIT.md file..."

    # Format roots for markdown display
    MARKDOWN_ROOTS="${NORMALIZED_ROOTS[*]}"

    if [ "$USE_REMOTE" = true ]; then
        download_template "INIT.md" | \
            sed "s|{{ROOT_FOLDERS}}|$MARKDOWN_ROOTS|g" \
            > "$INDEX_DIR/INIT.md"
    else
        INIT_MD_TEMPLATE="$SCRIPT_DIR/templates/INIT.md"
        if [ ! -f "$INIT_MD_TEMPLATE" ]; then
            error_exit "Template not found: $INIT_MD_TEMPLATE"
        fi
        sed "s|{{ROOT_FOLDERS}}|$MARKDOWN_ROOTS|g" "$INIT_MD_TEMPLATE" \
            > "$INDEX_DIR/INIT.md"
    fi

    print_success "Created: INIT.md"

    # Success message
    echo ""
    print_header
    print_success "Initialization complete!"
    echo ""
    echo -e "${GREEN}Created:${NC}"
    echo "  📁 $INDEX_DIR/modules/"
    echo "  📄 $INDEX_DIR/ai_project_index.toml"
    echo "  📄 $INDEX_DIR/INIT.md"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "  1. Open your AI IDE/CLI"
    echo "  2. Copy this prompt and paste it to AI dialog:"
    echo ""
    echo -e "${BLUE}     1. Read ai_project_index/INIT.md"
    echo "     2. Use snapshot concept to analyze this project"
    echo "     3. Update ai_project_index/ai_project_index.toml and create module files."
    echo "        Remove unused sections and comments to keep toml files small."
    echo -e "     4. Delete ai_project_index/INIT.md in the end. ${NC}"
    echo ""
    echo "  3. Add to your AI instructions (e.g., CLAUDE.md):"
    echo ""
    echo -e "${BLUE}     ## Architecture/Modules/Project Index"
    echo ""
    echo "     **Read first:**"
    echo "     - \`ai_project_index/ai_project_index.toml\` (project overview)"
    echo "     - Relevant \`ai_project_index/modules/*.toml\` files (module details)"
    echo ""
    echo -e "     Use the index to navigate the codebase efficiently.${NC}"
    echo ""
}

# Run main function
main "$@"
