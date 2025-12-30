#!/usr/bin/env python3
"""
ai_project_index Validation Tool

Validates the structure and integrity of ai_project_index TOML files.
Checks for:
- TOML syntax errors
- File path existence
- Module references
- Cross-references and dependencies
- Orphaned files
"""

__version__ = "1.0.0"

import argparse
import json
import sys
from pathlib import Path
from typing import Any, Dict, List, Tuple

try:
    import tomli
except ImportError:
    try:
        import tomllib as tomli  # Python 3.11+
    except ImportError:
        print("Error: Required module 'tomli' not found.")
        print("Install with: pip install tomli")
        sys.exit(1)


class Colors:
    """ANSI color codes for terminal output"""
    RED = '\033[91m'
    YELLOW = '\033[93m'
    GREEN = '\033[92m'
    BLUE = '\033[94m'
    RESET = '\033[0m'
    BOLD = '\033[1m'


class ValidationResult:
    """Stores validation results"""
    def __init__(self):
        self.errors: List[str] = []
        self.warnings: List[str] = []
        self.info: List[str] = []

    def add_error(self, message: str):
        self.errors.append(message)

    def add_warning(self, message: str):
        self.warnings.append(message)

    def add_info(self, message: str):
        self.info.append(message)

    def has_errors(self) -> bool:
        return len(self.errors) > 0

    def to_dict(self) -> Dict[str, Any]:
        return {
            "errors": self.errors,
            "warnings": self.warnings,
            "info": self.info,
            "status": "failed" if self.has_errors() else "passed"
        }


class Validator:
    """Main validation class"""

    def __init__(self, index_path: Path, project_root: Path, verbose: bool = False):
        self.index_path = index_path
        self.project_root = project_root
        self.verbose = verbose
        self.result = ValidationResult()
        self.main_toml: Dict[str, Any] = {}
        self.module_tomls: Dict[str, Dict[str, Any]] = {}

    def validate(self) -> ValidationResult:
        """Run all validation checks"""
        # Check if index directory exists
        if not self.index_path.exists():
            self.result.add_error(f"Index directory not found: {self.index_path}")
            return self.result

        # Validate main index file
        main_file = self.index_path / "ai_project_index.toml"
        if not main_file.exists():
            self.result.add_error(f"Main index file not found: {main_file}")
            return self.result

        self.result.add_info(f"Validating: {main_file}")
        self._validate_main_index(main_file)

        # Validate module files
        modules_dir = self.index_path / "modules"
        if modules_dir.exists() and modules_dir.is_dir():
            self._validate_modules(modules_dir)
        else:
            self.result.add_warning(f"Modules directory not found: {modules_dir}")

        # Cross-reference validation
        self._validate_cross_references()

        return self.result

    def _load_toml(self, file_path: Path) -> Tuple[bool, Dict[str, Any]]:
        """Load and parse TOML file"""
        try:
            with open(file_path, 'rb') as f:
                data = tomli.load(f)
            return True, data
        except tomli.TOMLDecodeError as e:
            self.result.add_error(f"TOML syntax error in {file_path}: {e}")
            return False, {}
        except Exception as e:
            self.result.add_error(f"Failed to read {file_path}: {e}")
            return False, {}

    def _validate_main_index(self, file_path: Path):
        """Validate main ai_project_index.toml"""
        success, data = self._load_toml(file_path)
        if not success:
            return

        self.main_toml = data

        # Check required [meta] section
        if 'meta' not in data:
            self.result.add_error(f"{file_path}: Missing required [meta] section")
            return

        meta = data['meta']

        # Check required meta fields
        if 'name' not in meta or not meta['name'] or meta['name'] == "{{PROJECT_NAME}}":
            self.result.add_warning(f"{file_path}: [meta] 'name' not set or is placeholder")

        if 'roots' not in meta:
            self.result.add_warning(f"{file_path}: [meta] 'roots' not specified")
        elif not isinstance(meta['roots'], list):
            self.result.add_error(f"{file_path}: [meta] 'roots' must be a list")
        else:
            # Validate root folders exist
            for root in meta['roots']:
                root_path = self.project_root / root
                if not root_path.exists():
                    self.result.add_error(f"{file_path}: Root folder not found: {root_path}")
                elif not root_path.is_dir():
                    self.result.add_error(f"{file_path}: Root path is not a directory: {root_path}")

        # Check for TODO placeholders in important fields
        for field in ['description', 'language', 'framework', 'architecture']:
            if field in meta and meta[field] == "TODO":
                self.result.add_warning(f"{file_path}: [meta] '{field}' is still TODO")

        # Validate [modules] section if present
        if 'modules' in data:
            self._validate_module_references(file_path, data['modules'])

        # Validate [entry_points] if present
        if 'entry_points' in data:
            self._validate_file_paths(file_path, data['entry_points'], "[entry_points]")

        # Validate [structure] paths if present
        if 'structure' in data:
            self._validate_file_paths(file_path, data['structure'], "[structure]")

    def _validate_module_references(self, source_file: Path, modules: Dict[str, str]):
        """Validate module file references"""
        for module_name, module_file in modules.items():
            if not module_file:
                continue

            # Module file paths are relative to project root or index directory
            module_path = self.project_root / module_file
            if not module_path.exists():
                # Try relative to index directory
                module_path = self.index_path / module_file
                if not module_path.exists():
                    self.result.add_error(
                        f"{source_file}: Module file not found: {module_file} (for module '{module_name}')"
                    )

    def _validate_file_paths(self, source_file: Path, section: Dict[str, Any], section_name: str):
        """Validate file paths in a section"""
        for key, value in section.items():
            if isinstance(value, str) and value and value != "TODO" and not value.startswith("#"):
                file_path = self.project_root / value
                if not file_path.exists():
                    self.result.add_warning(
                        f"{source_file}: {section_name}.{key} path not found: {value}"
                    )

    def _validate_modules(self, modules_dir: Path):
        """Validate all module TOML files"""
        toml_files = list(modules_dir.glob("*.toml"))

        if not toml_files:
            self.result.add_warning(f"No module TOML files found in {modules_dir}")
            return

        self.result.add_info(f"Found {len(toml_files)} module file(s)")

        for module_file in toml_files:
            self._validate_module_file(module_file)

    def _validate_module_file(self, file_path: Path):
        """Validate a single module TOML file"""
        if self.verbose:
            self.result.add_info(f"Validating module: {file_path.name}")

        success, data = self._load_toml(file_path)
        if not success:
            return

        self.module_tomls[file_path.stem] = data

        # Check required [meta] section
        if 'meta' not in data:
            self.result.add_error(f"{file_path}: Missing required [meta] section")
            return

        meta = data['meta']

        # Check required meta fields
        if 'name' not in meta or not meta['name']:
            self.result.add_error(f"{file_path}: [meta] 'name' is required")

        if 'location' not in meta or not meta['location']:
            self.result.add_warning(f"{file_path}: [meta] 'location' not specified")
        else:
            # Validate location exists
            location_path = self.project_root / meta['location']
            if not location_path.exists():
                self.result.add_error(f"{file_path}: Location not found: {meta['location']}")

        # Validate component arrays (model, service, component, etc.)
        for section_name in data:
            if section_name in ['meta', 'dependencies', 'usage', 'notes']:
                continue

            section = data[section_name]
            if isinstance(section, list):
                # Array of components
                for i, component in enumerate(section):
                    if isinstance(component, dict) and 'file' in component:
                        self._validate_component_file(file_path, section_name, component, i)
            elif isinstance(section, dict) and 'file' in section:
                self._validate_component_file(file_path, section_name, section, 0)

        # Validate [dependencies] if present
        if 'dependencies' in data:
            self._validate_dependencies(file_path, data['dependencies'])

        # Validate [usage] if present
        if 'usage' in data:
            self._validate_usage(file_path, data['usage'])

    def _validate_component_file(self, source_file: Path, section_name: str,
                                  component: Dict[str, Any], index: int):
        """Validate a component's file reference"""
        file_ref = component.get('file', '')
        if not file_ref:
            return

        file_path = self.project_root / file_ref
        if not file_path.exists():
            component_name = component.get('name', f'#{index}')
            self.result.add_error(
                f"{source_file}: [[{section_name}]] '{component_name}' file not found: {file_ref}"
            )

    def _validate_dependencies(self, source_file: Path, dependencies: Dict[str, Any]):
        """Validate dependency references"""
        # Check module dependencies
        if 'modules' in dependencies:
            modules = dependencies['modules']
            if isinstance(modules, list):
                for module_path in modules:
                    path = self.project_root / module_path
                    if not path.exists():
                        self.result.add_warning(
                            f"{source_file}: [dependencies] module not found: {module_path}"
                        )

        # Check core/other file dependencies
        for dep_type in ['core', 'shared', 'common']:
            if dep_type in dependencies:
                deps = dependencies[dep_type]
                if isinstance(deps, list):
                    for dep_path in deps:
                        path = self.project_root / dep_path
                        if not path.exists():
                            self.result.add_warning(
                                f"{source_file}: [dependencies.{dep_type}] file not found: {dep_path}"
                            )

    def _validate_usage(self, source_file: Path, usage: Dict[str, Any]):
        """Validate usage tracking references"""
        if 'imported_by' in usage:
            imported_by = usage['imported_by']
            if isinstance(imported_by, list):
                for import_path in imported_by:
                    path = self.project_root / import_path
                    if not path.exists():
                        self.result.add_warning(
                            f"{source_file}: [usage] imported_by file not found: {import_path}"
                        )

    def _validate_cross_references(self):
        """Validate cross-references between main index and modules"""
        if not self.main_toml:
            return

        # Get modules declared in main index
        declared_modules = set()
        if 'modules' in self.main_toml:
            declared_modules = set(self.main_toml['modules'].keys())

        # Get actual module files
        actual_modules = set(self.module_tomls.keys())

        # Check for orphaned modules (exist but not declared)
        orphaned = actual_modules - declared_modules
        if orphaned and declared_modules:  # Only warn if main index has modules section
            for orphan in orphaned:
                self.result.add_warning(
                    f"Module file exists but not declared in main index: modules/{orphan}.toml"
                )

        # Check for missing module files (declared but don't exist)
        # This is already handled in _validate_module_references, but we can add summary
        if self.verbose and declared_modules:
            self.result.add_info(
                f"Cross-reference check: {len(actual_modules)}/{len(declared_modules)} modules found"
            )


def format_output(result: ValidationResult, use_color: bool = True) -> str:
    """Format validation results as colored text"""
    output = []

    def colorize(text: str, color: str) -> str:
        return f"{color}{text}{Colors.RESET}" if use_color else text

    # Errors
    if result.errors:
        output.append(colorize("\n❌ ERRORS:", Colors.RED + Colors.BOLD))
        for error in result.errors:
            output.append(colorize(f"  • {error}", Colors.RED))

    # Warnings
    if result.warnings:
        output.append(colorize("\n⚠️  WARNINGS:", Colors.YELLOW + Colors.BOLD))
        for warning in result.warnings:
            output.append(colorize(f"  • {warning}", Colors.YELLOW))

    # Info (only in verbose mode, checked by caller)
    if result.info:
        output.append(colorize("\nℹ️  INFO:", Colors.BLUE + Colors.BOLD))
        for info in result.info:
            output.append(colorize(f"  • {info}", Colors.BLUE))

    # Summary
    output.append("")
    output.append("=" * 60)
    if result.has_errors():
        output.append(colorize("❌ VALIDATION FAILED", Colors.RED + Colors.BOLD))
        output.append(colorize(f"   {len(result.errors)} error(s), {len(result.warnings)} warning(s)", Colors.RED))
    else:
        output.append(colorize("✅ VALIDATION PASSED", Colors.GREEN + Colors.BOLD))
        if result.warnings:
            output.append(colorize(f"   {len(result.warnings)} warning(s)", Colors.YELLOW))
        else:
            output.append(colorize("   No issues found", Colors.GREEN))
    output.append("=" * 60)

    return "\n".join(output)


def main():
    parser = argparse.ArgumentParser(
        description="Validate ai_project_index TOML files",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                          # Validate ./ai_project_index
  %(prog)s -p ../myproject          # Validate specific project
  %(prog)s -v                       # Verbose output
  %(prog)s --json                   # Output as JSON
  %(prog)s --no-color               # Disable colored output

Exit codes:
  0 - Validation passed (may have warnings)
  1 - Validation failed (has errors)
  2 - Invalid arguments or setup error
        """
    )

    parser.add_argument(
        '-p', '--path',
        type=Path,
        default=Path.cwd(),
        help='Path to project directory (default: current directory)'
    )

    parser.add_argument(
        '-i', '--index',
        type=str,
        default='ai_project_index',
        help='Name of index directory (default: ai_project_index)'
    )

    parser.add_argument(
        '-v', '--verbose',
        action='store_true',
        help='Verbose output with detailed information'
    )

    parser.add_argument(
        '-q', '--quiet',
        action='store_true',
        help='Quiet mode (errors only, no warnings)'
    )

    parser.add_argument(
        '--json',
        action='store_true',
        help='Output results as JSON'
    )

    parser.add_argument(
        '--no-color',
        action='store_true',
        help='Disable colored output'
    )

    parser.add_argument(
        '--version',
        action='version',
        version=f'%(prog)s {__version__}'
    )

    args = parser.parse_args()

    # Resolve paths
    project_root = args.path.resolve()
    index_path = project_root / args.index

    if not project_root.exists():
        print(f"Error: Project directory not found: {project_root}", file=sys.stderr)
        return 2

    # Run validation
    validator = Validator(index_path, project_root, verbose=args.verbose)
    result = validator.validate()

    # Output results
    if args.json:
        print(json.dumps(result.to_dict(), indent=2))
    else:
        use_color = not args.no_color and sys.stdout.isatty()

        # Filter info messages if not verbose
        if not args.verbose:
            result.info = []

        # Filter warnings if quiet
        if args.quiet:
            result.warnings = []

        output = format_output(result, use_color)
        print(output)

    # Exit with appropriate code
    return 1 if result.has_errors() else 0


if __name__ == '__main__':
    sys.exit(main())
