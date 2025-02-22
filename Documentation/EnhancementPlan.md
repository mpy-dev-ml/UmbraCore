# UmbraCore Restic CLI Helper Enhancement Plan

## Current Implementation Status

### Core Features Implemented
1. **Command Structure**
   - Base `ResticCommand` protocol
   - Type-safe command builders
   - Comprehensive error handling
   - Exit code validation

2. **Backup Operations**
   - Multiple path support
   - Tag management
   - Exclude patterns
   - Skip-if-unchanged option
   - Dry run capability

3. **Models**
   - `BackupProgress` for real-time status
   - `SnapshotInfo` for backup metadata
   - `RepositoryStats` for storage information
   - `FileMetadata` for comprehensive file attributes
   - `RepositoryObject` for internal objects

## Planned Enhancements

### Phase 1: Command Set Completion

1. **Repository Management**
   - [ ] Initialize repository
   - [ ] Check repository integrity
   - [ ] List repository objects
   - [ ] Find specific objects
   - [ ] Repository statistics with multiple modes
   - [ ] Cache management

2. **Backup Enhancements**
   - [ ] Read from stdin
   - [ ] Read from command output
   - [ ] Advanced exclude patterns
   - [ ] Cache directory handling
   - [ ] Size-based exclusions
   - [ ] Case-sensitive/insensitive patterns

3. **Restore Operations**
   - [ ] Restore to different target
   - [ ] Include/exclude patterns
   - [ ] Verify restored files
   - [ ] Handle extended attributes
   - [ ] Sparse file support
   - [ ] ACL preservation

### Phase 2: Advanced Features

1. **Repository Analysis**
   - [ ] Deduplication statistics
   - [ ] Space usage analysis
   - [ ] Content-based file grouping
   - [ ] Snapshot comparison
   - [ ] File tree visualization

2. **Performance Optimisation**
   - [ ] Parallel operations
   - [ ] Network bandwidth control
   - [ ] Cache optimization
   - [ ] Progress monitoring
   - [ ] Rate limiting

3. **Security Features**
   - [ ] Repository encryption
   - [ ] Key management
   - [ ] Password handling
   - [ ] SSH integration
   - [ ] Cloud provider credentials

### Phase 3: Integration Support

1. **Monitoring & Reporting**
   - [ ] Detailed backup reports
   - [ ] Space usage trends
   - [ ] Backup success rates
   - [ ] Performance metrics
   - [ ] Error statistics

2. **Automation Support**
   - [ ] Scheduled backups
   - [ ] Pre/post backup scripts
   - [ ] Event hooks
   - [ ] Notification system
   - [ ] Retry mechanisms

3. **Platform Integration**
   - [ ] macOS Keychain support
   - [ ] System notifications
   - [ ] Background operation
   - [ ] Power management
   - [ ] Network awareness

## Learnings from Restic Documentation

### Command Line Interface
1. **Exit Codes**
   - 0: Success
   - 1: Fatal error
   - 3: Partial backup (some files unreadable)
   - 10: Repository not found
   - 11: Repository lock failed
   - 12: Wrong password
   - 130: Interrupted

### Repository Structure
1. **Object Types**
   - Blobs: Raw data
   - Packs: Collection of blobs
   - Index: Lookup tables
   - Snapshots: Backup points
   - Keys: Encryption
   - Locks: Concurrency control

### File Handling
1. **Metadata Support**
   - Standard attributes (mode, times)
   - Extended attributes
   - ACLs
   - Sparse files
   - Hard links
   - Symbolic links

### Performance Considerations
1. **Space Efficiency**
   - Deduplication
   - Compression
   - Pack consolidation
   - Cache management

2. **Network Usage**
   - Bandwidth control
   - Resume support
   - Connection pooling
   - Rate limiting

## Implementation Guidelines

### Code Structure
1. **Command Pattern**
   - Type-safe builders
   - Fluent interfaces
   - Validation at compile time
   - Clear error messages

2. **Error Handling**
   - Specific error types
   - Context preservation
   - Recovery options
   - User-friendly messages

3. **Testing Strategy**
   - Unit tests for commands
   - Integration tests for workflows
   - Performance benchmarks
   - Error scenario coverage

### Documentation
1. **API Documentation**
   - Clear examples
   - Use cases
   - Parameter descriptions
   - Error conditions

2. **Integration Guide**
   - Setup instructions
   - Common patterns
   - Best practices
   - Troubleshooting

## Timeline
- Phase 1: Q1 2025 (March)
- Phase 2: Q2 2025 (April-May)
- Phase 3: Q3 2025 (June-July)

## Success Criteria
1. **Functionality**
   - Complete command coverage
   - Robust error handling
   - Comprehensive documentation

2. **Performance**
   - Efficient resource usage
   - Fast operation
   - Minimal overhead

3. **Integration**
   - Easy to use API
   - Clear documentation
   - Reliable operation
