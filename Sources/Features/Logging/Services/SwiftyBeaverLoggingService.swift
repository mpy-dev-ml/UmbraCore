import Foundation
import SwiftyBeaver

/// A logging service implementation using SwiftyBeaver
@preconcurrency public final actor SwiftyBeaverLoggingService: LoggingProtocol {
    private let log = SwiftyBeaver.self
    private var isInitialized = false
    
    public init() {}
    
    public func initialize(with path: String) async throws {
        guard !isInitialized else { return }
        
        let console = ConsoleDestination()
        // Use British English for log level display
        console.levelString.debug = "DEBUG"
        console.levelString.info = "INFO"
        console.levelString.warning = "WARNING"
        console.levelString.error = "ERROR"
        
        let file = FileDestination()
        file.logFileURL = URL(fileURLWithPath: path)
        
        // Configure file logging
        file.format = "$DHH:mm:ss.SSS$d $C$L$c $N.$F:$l - $M"
        file.asynchronously = false  // Ensure logs are written immediately
        file.levelString.debug = "DEBUG"
        file.levelString.info = "INFO"
        file.levelString.warning = "WARNING"
        file.levelString.error = "ERROR"
        
        log.addDestination(console)
        log.addDestination(file)
        
        isInitialized = true
    }
    
    public func log(_ entry: LogEntry) async throws {
        guard isInitialized else {
            throw LoggingError.notInitialized
        }
        
        guard !entry.message.isEmpty else {
            throw LoggingError.invalidEntry
        }
        
        let metadata = entry.metadata?.description ?? ""
        let message = metadata.isEmpty ? entry.message : "\(entry.message) | \(metadata)"
        
        switch entry.level {
        case .debug:
            log.debug(message)
        case .info:
            log.info(message)
        case .warning:
            log.warning(message)
        case .error:
            log.error(message)
        case .critical:
            log.error("CRITICAL: \(message)")
        case .trace, .notice:
            // Handle trace and notice levels
            log.info(message)
        }
    }
    
    public func stop() async {
        // SwiftyBeaver handles cleanup automatically
        isInitialized = false
    }
}
