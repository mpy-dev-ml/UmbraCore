#!/usr/bin/env python3
# xpc_migration.py
#
# Python-based comprehensive runner for UmbraCore XPC migration

import argparse
import json
import os
import shutil
import subprocess
import sys
from enum import Enum
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple, Union


class MigrationStep(Enum):
    ANALYZE = "analyze"
    BASIC_MIGRATION = "basic"
    ADVANCED_FIXES = "advanced"
    VERIFY = "verify"
    ALL = "all"


class Colors:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'


class MigrationRunner:
    def __init__(self, project_root: Path, dry_run: bool = False, verbose: bool = False):
        self.project_root = project_root
        self.script_dir = project_root / "Scripts"
        self.dry_run = dry_run
        self.verbose = verbose
        self.analysis_file = project_root / "xpc_protocol_analysis.json"
        self.backups_dir = project_root / "BackupsMigration"
    
    def check_prerequisites(self) -> bool:
        """Check if all required tools are installed"""
        prerequisites = {
            "go": "Go",
            "jq": "jq"
        }
        
        missing = []
        for cmd, name in prerequisites.items():
            if not shutil.which(cmd):
                missing.append(name)
        
        if missing:
            print(f"{Colors.RED}❌ Missing required tools: {', '.join(missing)}{Colors.ENDC}")
            print("Please install these tools and try again.")
            return False
        
        print(f"{Colors.GREEN}✅ All prerequisites met{Colors.ENDC}")
        return True
    
    def make_scripts_executable(self) -> None:
        """Make all shell scripts executable"""
        for script in self.script_dir.glob("*.sh"):
            script.chmod(script.stat().st_mode | 0o111)  # Add executable bit
    
    def run_command(self, cmd: List[str], cwd: Optional[Path] = None) -> Tuple[bool, str]:
        """Run a command and return success status and output"""
        try:
            output = subprocess.check_output(
                cmd, 
                cwd=cwd or self.project_root,
                stderr=subprocess.STDOUT,
                text=True
            )
            return True, output
        except subprocess.CalledProcessError as e:
            return False, e.output
    
    def run_analyzer(self) -> bool:
        """Run the XPC protocol analyzer"""
        print(f"\n{Colors.BOLD}## Running XPC protocol analyzer ##{Colors.ENDC}")
        
        analyzer_path = self.script_dir / "xpc_protocol_analyzer.go"
        if not analyzer_path.exists():
            print(f"{Colors.RED}❌ XPC protocol analyzer not found at {analyzer_path}{Colors.ENDC}")
            return False
        
        print("Analyzing codebase...")
        success, output = self.run_command([
            "go", "run", str(analyzer_path),
            "-output", str(self.analysis_file)
        ], cwd=self.script_dir)
        
        if not success:
            print(f"{Colors.RED}❌ Analysis failed:{Colors.ENDC}\n{output}")
            return False
        
        print(f"{Colors.GREEN}✅ Analysis complete{Colors.ENDC}")
        return True
    
    def initialize_migration_tracking(self) -> bool:
        """Initialize migration tracking if not already done"""
        print(f"\n{Colors.BOLD}## Setting up migration tracking ##{Colors.ENDC}")
        
        manager_path = self.script_dir / "xpc_migration_manager.sh"
        if not manager_path.exists():
            print(f"{Colors.RED}❌ Migration manager not found at {manager_path}{Colors.ENDC}")
            return False
        
        # Check if migration tracking is already initialized
        success, output = self.run_command([str(manager_path), "status"])
        if "No migration data" in output:
            print("Initializing migration tracking...")
            success, output = self.run_command([str(manager_path), "init"])
            if not success:
                print(f"{Colors.RED}❌ Failed to initialize migration tracking:{Colors.ENDC}\n{output}")
                return False
        else:
            print("Migration tracking already initialized")
        
        print(f"{Colors.GREEN}✅ Migration tracking ready{Colors.ENDC}")
        return True
    
    def show_migration_status(self) -> None:
        """Display current migration status"""
        print(f"\n{Colors.BOLD}## Current migration status ##{Colors.ENDC}")
        
        manager_path = self.script_dir / "xpc_migration_manager.sh"
        success, output = self.run_command([str(manager_path), "status"])
        print(output)
    
    def get_available_modules(self) -> List[str]:
        """Get list of available modules from analysis file"""
        if not self.analysis_file.exists():
            print(f"{Colors.RED}❌ Analysis file not found at {self.analysis_file}{Colors.ENDC}")
            return []
        
        try:
            with open(self.analysis_file, 'r') as f:
                analysis = json.load(f)
            
            modules = set()
            for file_analysis in analysis.get('fileAnalyses', []):
                module = file_analysis.get('module')
                if module:
                    modules.add(module)
            
            return sorted(list(modules))
        except (json.JSONDecodeError, KeyError) as e:
            print(f"{Colors.RED}❌ Error parsing analysis file: {e}{Colors.ENDC}")
            return []
    
    def select_modules(self) -> List[str]:
        """Interactive module selection"""
        print(f"\n{Colors.BOLD}## Module selection ##{Colors.ENDC}")
        
        modules = self.get_available_modules()
        if not modules:
            return []
        
        print("Available modules:")
        for i, module in enumerate(modules, 1):
            print(f"{i}) {module}")
        
        print(f"\nEnter module numbers to process (comma-separated), or 'all' for all modules:")
        selection = input().strip()
        
        if selection.lower() == 'all':
            return modules
        
        selected_modules = []
        try:
            indices = [int(idx.strip()) for idx in selection.split(',')]
            for idx in indices:
                if 1 <= idx <= len(modules):
                    selected_modules.append(modules[idx-1])
        except ValueError:
            print(f"{Colors.YELLOW}⚠️ Invalid selection. Please enter numbers separated by commas.{Colors.ENDC}")
            return self.select_modules()
        
        if not selected_modules:
            print(f"{Colors.YELLOW}⚠️ No valid modules selected.{Colors.ENDC}")
            return self.select_modules()
        
        print(f"Selected modules: {', '.join(selected_modules)}")
        return selected_modules
    
    def run_basic_migration(self, module: str) -> bool:
        """Run basic migration for a module"""
        print(f"\n{Colors.BOLD}### Running basic migration for {module} ###{Colors.ENDC}")
        
        batch_migrate_script = self.script_dir / "batch_migrate_xpc.sh"
        if not batch_migrate_script.exists():
            print(f"{Colors.RED}❌ Batch migration script not found at {batch_migrate_script}{Colors.ENDC}")
            return False
        
        cmd = [str(batch_migrate_script), module]
        if self.dry_run:
            cmd.append("--dry-run")
        
        success, output = self.run_command(cmd)
        print(output)
        
        if not success:
            print(f"{Colors.YELLOW}⚠️ Basic migration had issues for {module}{Colors.ENDC}")
            return False
        
        print(f"{Colors.GREEN}✅ Basic migration complete for {module}{Colors.ENDC}")
        return True
    
    def run_advanced_fixes(self, module: str) -> bool:
        """Run advanced fixes for a module"""
        print(f"\n{Colors.BOLD}### Running advanced fixes for {module} ###{Colors.ENDC}")
        
        advanced_fixes_script = self.script_dir / "run_advanced_xpc_fixes.sh"
        if not advanced_fixes_script.exists():
            print(f"{Colors.RED}❌ Advanced fixes script not found at {advanced_fixes_script}{Colors.ENDC}")
            return False
        
        cmd = [
            str(advanced_fixes_script),
            "--module", module,
            "--verbose"
        ]
        if self.dry_run:
            cmd.append("--dry-run")
        
        success, output = self.run_command(cmd)
        print(output)
        
        if not success:
            print(f"{Colors.YELLOW}⚠️ Advanced fixes had issues for {module}{Colors.ENDC}")
            return False
        
        print(f"{Colors.GREEN}✅ Advanced fixes complete for {module}{Colors.ENDC}")
        return True
    
    def run_verification(self) -> bool:
        """Run verification of migration"""
        print(f"\n{Colors.BOLD}## Running verification ##{Colors.ENDC}")
        
        verify_script = self.script_dir / "verify_migration_completion.sh"
        if not verify_script.exists():
            print(f"{Colors.RED}❌ Verification script not found at {verify_script}{Colors.ENDC}")
            return False
        
        success, output = self.run_command([str(verify_script)])
        print(output)
        
        if not success:
            print(f"{Colors.YELLOW}⚠️ Verification had issues{Colors.ENDC}")
            return False
        
        print(f"{Colors.GREEN}✅ Verification complete{Colors.ENDC}")
        return True
    
    def process_module(self, module: str, steps: List[MigrationStep]) -> bool:
        """Process a single module with specified steps"""
        success = True
        
        if MigrationStep.BASIC_MIGRATION in steps or MigrationStep.ALL in steps:
            if not self.run_basic_migration(module):
                success = False
                # If dry run, continue with other steps
                if not self.dry_run:
                    return False
        
        if MigrationStep.ADVANCED_FIXES in steps or MigrationStep.ALL in steps:
            if not self.run_advanced_fixes(module):
                success = False
        
        return success
    
    def run_migration(self, modules: Optional[List[str]] = None, steps: List[MigrationStep] = [MigrationStep.ALL]) -> bool:
        """Run the migration process"""
        print(f"{Colors.HEADER}{'='*50}{Colors.ENDC}")
        print(f"{Colors.HEADER}{Colors.BOLD}       UmbraCore XPC Protocol Migration Tool      {Colors.ENDC}")
        print(f"{Colors.HEADER}{'='*50}{Colors.ENDC}")
        
        # Check prerequisites
        if not self.check_prerequisites():
            return False
        
        # Make scripts executable
        self.make_scripts_executable()
        
        # Run analyzer if needed
        if MigrationStep.ANALYZE in steps or MigrationStep.ALL in steps:
            if not self.analysis_file.exists():
                if not self.run_analyzer():
                    return False
            else:
                print(f"\n{Colors.BOLD}## Using existing XPC protocol analysis ##{Colors.ENDC}")
                print(f"{Colors.GREEN}✅ Analysis file found at {self.analysis_file}{Colors.ENDC}")
        
        # Initialize migration tracking
        if not self.initialize_migration_tracking():
            return False
        
        # Show migration status
        self.show_migration_status()
        
        # Select modules if not provided
        if not modules:
            modules = self.select_modules()
            if not modules:
                return False
        
        # Process each module
        print(f"\n{Colors.BOLD}## Processing modules ##{Colors.ENDC}")
        all_success = True
        for module in modules:
            if not self.process_module(module, steps):
                all_success = False
        
        # Run verification
        if MigrationStep.VERIFY in steps or MigrationStep.ALL in steps:
            if not self.run_verification():
                all_success = False
        
        # Summary
        print(f"\n{Colors.BOLD}## Migration process {'completed' if all_success else 'finished with issues'} ##{Colors.ENDC}")
        print("Please review the changes and run tests to ensure everything is working correctly.")
        if not self.dry_run:
            print("If you encounter any issues, you can restore backup files with the .bak or .gobackup extensions.")
        print(f"{Colors.HEADER}{'='*50}{Colors.ENDC}")
        
        return all_success


def parse_args():
    parser = argparse.ArgumentParser(description='UmbraCore XPC Protocol Migration Tool')
    parser.add_argument('--dry-run', action='store_true', help='Perform a dry run without modifying files')
    parser.add_argument('--verbose', action='store_true', help='Enable verbose output')
    parser.add_argument('--step', choices=[s.value for s in MigrationStep], 
                        default='all', help='Migration step to run')
    parser.add_argument('--module', action='append', help='Module to process (can be specified multiple times)')
    
    return parser.parse_args()


def main():
    args = parse_args()
    
    project_root = Path(__file__).resolve().parent.parent
    runner = MigrationRunner(
        project_root=project_root,
        dry_run=args.dry_run,
        verbose=args.verbose
    )
    
    step = MigrationStep(args.step)
    steps = [step]
    
    if not runner.run_migration(modules=args.module, steps=steps):
        sys.exit(1)


if __name__ == "__main__":
    main()
