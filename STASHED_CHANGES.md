# UmbraCore Stashed Changes Review

This document provides an overview of the stashed changes that have been preserved in separate branches for review and potential integration.

## Stashed Changes Branches

Each stash has been placed into its own branch to allow for careful review and selective application of changes. The branches are named according to their original stash description.

### Available Branches

1. **stashed-changes-wip-on-security-interface-refactor-march2025--9dea56a-fix-swift-6-concurrency-warnings-and-add-test-support-utilities**
   - Contains security interface refactoring work
   - Fixes Swift 6 concurrency warnings
   - Adds test support utilities
   - Original branch: security-interface-refactor-march2025

2. **stashed-changes-wip-on-security-protocols-refactoring--ed111b9-fix-aes-gcm-iv-size-standardisation-to-12-bytes-across-codebase**
   - Standardises AES-GCM IV size to 12 bytes across the codebase
   - Original branch: security-protocols-refactoring

3. **stashed-changes-wip-on-main--7ae4ae7-merge-pull-request--19-from-mpy-dev-ml-feature-foundation-free-testing**
   - Contains changes related to foundation-free testing
   - Based on main branch after PR #19

4. **stashed-changes-wip-on-refactor-test-kit-restructure--a1d7fb0-fix-swift-6-warning-for-actor-initialiser**
   - Fixes Swift 6 warnings for actor initialisers
   - Based on the refactor/test-kit-restructure branch

5. **stashed-changes-on-umbracore-test-suite--stashing-changes-before-refactoring**
   - Contains changes that were stashed before refactoring the test suite
   - Based on the umbracore-test-suite branch

6. **stashed-changes-on-main--wip--current-changes-for-cross-platform-crypto**
   - Contains work-in-progress changes for cross-platform crypto
   - Based on the main branch

7. **stashed-changes-wip-on--no-branch---24191d2-refactor--consolidate-test-infrastructure-and-fix-dependency-management**
   - Consolidates test infrastructure
   - Fixes dependency management issues
   - Originally not on any specific branch

8. **stashed-changes-on-backup-docs-pre-biometric--pre-biometric-auth-integration-changes**
   - Contains changes made before biometric authentication integration
   - Based on the backup/docs-pre-biometric branch

## Recommended Review Process

1. Check out each branch individually: `git checkout <branch-name>`
2. Review the changes: `git diff origin/main..HEAD`
3. If the changes are to be kept, create a new feature branch from main and cherry-pick the changes:
   ```
   git checkout -b feature/keep-changes-from-stash-N main
   git cherry-pick -x <commit-hash-from-stash-branch>
   ```
4. Fix any conflicts that arise during cherry-picking
5. Run tests to ensure the changes don't break existing functionality
6. Push the new feature branch and create a pull request

## Notes

- Some branches contain overlapping changes and may cause conflicts when cherry-picked together
- The original stash descriptions have been preserved in the branch names for reference
- This approach allows for selective application of stashed changes while maintaining a clean history

For any questions or issues, please contact the repository maintainers.
