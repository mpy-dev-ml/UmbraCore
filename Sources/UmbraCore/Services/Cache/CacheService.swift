import Foundation

/// Service for managing cache operations
public final class CacheService: BaseSandboxedService {
    // MARK: Lifecycle

    // MARK: - Initialization

    /// Initialize with dependencies
    /// - Parameters:
    ///   - directoryURL: Cache directory URL
    ///   - configuration: Cache configuration
    ///   - performanceMonitor: Performance monitor
    ///   - logger: Logger for tracking operations
    public init(
        directoryURL: URL,
        configuration: Configuration = Configuration(),
        performanceMonitor: PerformanceMonitor,
        logger: LoggerProtocol
    ) {
        self.directoryURL = directoryURL
        self.configuration = configuration
        self.performanceMonitor = performanceMonitor
        super.init(logger: logger)
        setupDirectory()
        if configuration.autoCleanup {
            setupCleanupTimer()
        }
    }

    // MARK: - Deinitializer

    deinit {
        cleanupTimer?.invalidate()
    }

    // MARK: Public

    // MARK: - Types

    /// Cache entry
    public struct CacheEntry<T: Codable> {
        // MARK: Lifecycle

        /// Initialize with values
        public init(
            value: T,
            creationDate: Date = Date(),
            expirationDate: Date? = nil,
            size: Int64,
            metadata: [String: String] = [:]
        ) {
            self.value = value
            self.creationDate = creationDate
            self.expirationDate = expirationDate
            self.size = size
            self.metadata = metadata
        }

        // MARK: Public

        /// Entry value
        public let value: T

        /// Creation date
        public let creationDate: Date

        /// Expiration date
        public let expirationDate: Date?

        /// Entry size in bytes
        public let size: Int64

        /// Entry metadata
        public let metadata: [String: String]
    }

    /// Cache configuration
    public struct Configuration {
        // MARK: Lifecycle

        /// Initialize with values
        public init(
            maxSize: Int64 = 100 * 1024 * 1024, // 100MB
            defaultLifetime: TimeInterval? = nil,
            autoCleanup: Bool = true,
            cleanupInterval: TimeInterval = 300 // 5 minutes
        ) {
            self.maxSize = maxSize
            self.defaultLifetime = defaultLifetime
            self.autoCleanup = autoCleanup
            self.cleanupInterval = cleanupInterval
        }

        // MARK: Public

        /// Maximum cache size in bytes
        public let maxSize: Int64

        /// Default entry lifetime
        public let defaultLifetime: TimeInterval?

        /// Whether to clean up expired entries automatically
        public let autoCleanup: Bool

        /// Cleanup interval
        public let cleanupInterval: TimeInterval
    }

    // MARK: - Public Methods

    /// Set cache entry
    /// - Parameters:
    ///   - value: Entry value
    ///   - key: Cache key
    ///   - lifetime: Optional entry lifetime
    ///   - metadata: Optional entry metadata
    /// - Throws: Error if operation fails
    public func setValue(
        _ value: some Codable,
        forKey key: String,
        lifetime: TimeInterval? = nil,
        metadata: [String: String] = [:]
    ) async throws {
        try validateUsable(for: "setValue")

        try await performanceMonitor.trackDuration("cache.set") {
            // Create entry
            let data = try JSONEncoder().encode(value)
            let expirationDate = lifetime.map { Date().addingTimeInterval($0) }
                ?? configuration.defaultLifetime.map { Date().addingTimeInterval($0) }

            let entry = CacheEntry(
                value: value,
                expirationDate: expirationDate,
                size: Int64(data.count),
                metadata: metadata
            )

            // Save entry
            let entryURL = fileURL(forKey: key)
            try await save(entry, to: entryURL)

            // Update size
            queue.async(flags: .barrier) {
                self.currentSize += entry.size
            }

            // Log operation
            logger.debug(
                """
                Set cache entry:
                Key: \(key)
                Size: \(entry.size) bytes
                Expiration: \(String(describing: expirationDate))
                """,
                file: #file,
                function: #function,
                line: #line
            )

            // Check size limit
            if currentSize > configuration.maxSize {
                try await cleanup()
            }
        }
    }

    /// Get cache entry
    /// - Parameter key: Cache key
    /// - Returns: Cache entry if available
    /// - Throws: Error if operation fails
    public func getValue<T: Codable>(
        forKey key: String
    ) async throws -> CacheEntry<T>? {
        try validateUsable(for: "getValue")

        return try await performanceMonitor.trackDuration("cache.get") {
            let entryURL = fileURL(forKey: key)

            // Check if file exists
            guard FileManager.default.fileExists(atPath: entryURL.path) else {
                return nil
            }

            // Load entry
            let entry: CacheEntry<T> = try await load(from: entryURL)

            // Check expiration
            if let expirationDate = entry.expirationDate, expirationDate < Date() {
                try? await removeValue(forKey: key)
                return nil
            }

            // Log operation
            logger.debug(
                """
                Got cache entry:
                Key: \(key)
                Size: \(entry.size) bytes
                Age: \(Date().timeIntervalSince(entry.creationDate))s
                """,
                file: #file,
                function: #function,
                line: #line
            )

            return entry
        }
    }

    /// Remove cache entry
    /// - Parameter key: Cache key
    /// - Throws: Error if operation fails
    public func removeValue(forKey key: String) async throws {
        try validateUsable(for: "removeValue")

        try await performanceMonitor.trackDuration("cache.remove") {
            let entryURL = fileURL(forKey: key)

            // Get file size
            let attributes = try FileManager.default.attributesOfItem(
                atPath: entryURL.path
            )
            let size = attributes[.size] as? Int64 ?? 0

            // Remove file
            try FileManager.default.removeItem(at: entryURL)

            // Update size
            queue.async(flags: .barrier) {
                self.currentSize -= size
            }

            // Log operation
            logger.debug(
                """
                Removed cache entry:
                Key: \(key)
                Size: \(size) bytes
                """,
                file: #file,
                function: #function,
                line: #line
            )
        }
    }

    /// Clear all cache entries
    /// - Throws: Error if operation fails
    public func clearCache() async throws {
        try validateUsable(for: "clearCache")

        try await performanceMonitor.trackDuration("cache.clear") {
            // Remove all files
            let contents = try FileManager.default.contentsOfDirectory(
                at: directoryURL,
                includingPropertiesForKeys: nil
            )

            for url in contents {
                try FileManager.default.removeItem(at: url)
            }

            // Reset size
            queue.async(flags: .barrier) {
                self.currentSize = 0
            }

            // Log operation
            logger.debug(
                "Cleared cache",
                file: #file,
                function: #function,
                line: #line
            )
        }
    }

    // MARK: Private

    /// Cache directory URL
    private let directoryURL: URL

    /// Cache configuration
    private let configuration: Configuration

    /// Queue for synchronizing operations
    private let queue: DispatchQueue = .init(
        label: "dev.mpy.umbracore.cache",
        qos: .utility,
        attributes: .concurrent
    )

    /// Performance monitor
    private let performanceMonitor: PerformanceMonitor

    /// Cleanup timer
    private var cleanupTimer: Timer?

    /// Current cache size
    private var currentSize: Int64 = 0

    // MARK: - Private Methods

    /// Set up cache directory
    private func setupDirectory() {
        do {
            try FileManager.default.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true
            )

            // Calculate initial size
            let contents = try FileManager.default.contentsOfDirectory(
                at: directoryURL,
                includingPropertiesForKeys: [.fileSizeKey]
            )

            var totalSize: Int64 = 0
            for url in contents {
                let attributes = try FileManager.default.attributesOfItem(
                    atPath: url.path
                )
                totalSize += attributes[.size] as? Int64 ?? 0
            }

            currentSize = totalSize

            logger.debug(
                """
                Set up cache directory:
                Path: \(directoryURL.path)
                Size: \(totalSize) bytes
                """,
                file: #file,
                function: #function,
                line: #line
            )
        } catch {
            logger.error(
                "Failed to set up cache directory: \(error)",
                file: #file,
                function: #function,
                line: #line
            )
        }
    }

    /// Set up cleanup timer
    private func setupCleanupTimer() {
        cleanupTimer = Timer.scheduledTimer(
            withTimeInterval: configuration.cleanupInterval,
            repeats: true
        ) { [weak self] _ in
            Task {
                try? await self?.cleanup()
            }
        }
    }

    /// Clean up expired entries
    private func cleanup() async throws {
        try await performanceMonitor.trackDuration("cache.cleanup") {
            let contents = try FileManager.default.contentsOfDirectory(
                at: directoryURL,
                includingPropertiesForKeys: [.fileSizeKey]
            )

            var removedSize: Int64 = 0
            var removedCount = 0

            for url in contents {
                if let entry: CacheEntry<Data> = try? await load(from: url),
                   let expirationDate = entry.expirationDate,
                   expirationDate < Date() {
                    try FileManager.default.removeItem(at: url)
                    removedSize += entry.size
                    removedCount += 1
                }
            }

            // Update size
            queue.async(flags: .barrier) {
                self.currentSize -= removedSize
            }

            // Log operation
            logger.debug(
                """
                Cleaned up cache:
                Removed: \(removedCount) entries
                Size: \(removedSize) bytes
                """,
                file: #file,
                function: #function,
                line: #line
            )
        }
    }

    /// Get file URL for key
    private func fileURL(forKey key: String) -> URL {
        directoryURL.appendingPathComponent(key)
    }

    /// Save entry to file
    private func save(
        _ entry: CacheEntry<some Codable>,
        to url: URL
    ) async throws {
        let data = try JSONEncoder().encode(entry)
        try data.write(to: url, options: .atomic)
    }

    /// Load entry from file
    private func load<T: Codable>(from url: URL) async throws -> CacheEntry<T> {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(CacheEntry<T>.self, from: data)
    }
}
