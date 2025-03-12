# UmbraCore Development Roadmap

This document outlines the development roadmap for UmbraCore, detailing both completed and planned features.

## Common Requirements Across Applications

UmbraCore serves as the foundation for multiple applications (Rbum, Rbx, ResticBar), sharing these core requirements:

- **Core Restic Integration**: Repository initialisation, backup operations, restoration
- **Security & Credentials**: Password management, SSH keys, secure storage
- **Configuration Management**: Backup sources, exclusions, retention policies
- **Progress & Status**: Monitoring, metrics, notifications
- **Repository Management**: Multi-repository support, health checks
- **Scheduling System**: Timed operations, maintenance
- **State Management**: History, status tracking, preferences
- **Network Operations**: Remote repository access, bandwidth control

## Implementation Status

### Tested & Operable
- **Core Restic Integration**
    - Command execution system
    - Process management
    - Output parsing
    - Error handling
    - Basic repository operations
- **Security Layer**
    - Keychain integration
    - XPC service implementation
    - Secure data handling
    - XPC protocol consolidation
- **Repository Management**
    - Repository initialisation
    - Repository health monitoring
    - Multi-repository support
- **Testing Infrastructure**
    - Unit testing framework
    - Integration test suite
    - Performance benchmarks
    - Mock services

### Current Development Focus
- **Security Enhancements**
    - SSH key management
    - Cloud provider credentials
    - Repository password handling
- **Configuration System**
    - Configuration format design
    - Validation system
    - Migration framework
- **Progress Monitoring**
    - Progress protocol design
    - Status update system
    - Metrics collection

### Future Development

#### Short-term Goals (3-6 months)
- **Advanced Repository Management**
    - Statistics collection
    - Space management
    - Cache handling
- **Scheduling System**
    - Schedule format design
    - Timer implementation
    - Queue management
    - Conflict resolution
- **Network Operations**
    - Connection management
    - Protocol handlers
    - Retry logic
    - Rate limiting
- **State Management**
    - State persistence design
    - History tracking
    - Recovery management
    - Preference storage

#### Mid-term Goals (6-12 months)
- **Statistics & Analytics**
    - Performance metrics
    - Usage statistics
    - Trend analysis
    - Report generation
- **Health Monitoring**
    - System diagnostics
    - Performance monitoring
    - Resource tracking
    - Alert system
- **Event System**
    - Event dispatching
    - Notification management
    - Webhook support
    - Custom triggers
- **Cache Optimisation**
    - Memory usage optimisation
    - Disk cache management
    - Network caching
    - Cold/warm/hot cache strategies

#### Long-term Goals (12+ months)
- **Enhanced User Experience**
    - Improved error messaging
    - Contextual help
    - Smart suggestions
    - Accessibility features
- **Extended Platform Support**
    - Linux compatibility
    - Windows compatibility (where feasible)
    - Cross-platform testing
- **Enterprise Features**
    - Advanced logging
    - Audit trails
    - Team management
    - Policy enforcement
- **Integration Ecosystem**
    - Plugin architecture
    - Integration with monitoring tools
    - Backup verification workflows
    - Scripting support

## Development Principles

### 1. Security First
- Defence in depth approach
- Zero trust architecture
- Regular security reviews
- Secure by default

### 2. Performance
- Minimal resource usage
- Responsive user interface
- Efficient background operations
- Optimised network usage

### 3. Reliability
- Comprehensive error handling
- Graceful degradation
- Automatic recovery where possible
- Thorough logging

### 4. Maintainability
- Clean architecture
- Comprehensive documentation
- Consistent coding standards
- Automated testing

### 5. User Experience
- Intuitive interfaces
- Clear error messages
- Predictable behaviour
- Focus on developer workflows
