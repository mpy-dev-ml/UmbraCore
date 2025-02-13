@preconcurrency import Foundation

/// Service for managing cache operations
@objc
public final class CacheService: BaseSandboxedService, @unchecked Sendable {
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
    public struct CacheEntry<T: Codable & Sendable>: Codable, Sendable {
        /// The cached value
        public let value: T
        /// Size of the entry in bytes
        public let size: Int
        /// Timestamp when entry was created
        public let timestamp: Date
        /// Optional expiration date
        public let expirationDate: Date?

        /// Initialize a new cache entry
        /// - Parameters:
        ///   - value: Value to cache
        ///   - size: Size in bytes
        ///   - timestamp: Creation timestamp
        ///   - expirationDate: Optional expiration date
        public init(
            value: T,
            size: Int,
            timestamp: Date = Date(),
            expirationDate: Date? = nil
        ) {
            self.value = value
            self.size = size
            self.timestamp = timestamp
            self.expirationDate = expirationDate
        }
    }

    /// Cache configuration
    public struct Configuration {
        // MARK: Lifecycle

        /// Initialize with values
        public init(
            maxSize: Int = 100 * 1_024 * 1_024, // 100MB
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
        public let maxSize: Int

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
        _ value: some Codable & Sendable,
        forKey key: String,
        lifetime: TimeInterval? = nil,
        metadata: [String: String] = [:]
    ) async throws {
        try await withValidation("setValue") {
            try await performanceMonitor.trackDuration("cache.set") {
                // Create entry
                let data = try JSONEncoder().encode(value)
                let expirationDate = lifetime.map { Date().addingTimeInterval($0) }
                    ?? configuration.defaultLifetime.map { Date().addingTimeInterval($0) }

                let entry = CacheEntry(
                    value: value,
                    size: data.count,
                    expirationDate: expirationDate
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
    }

    /// Get cache entry
    /// - Parameter key: Cache key
    /// - Returns: Cache entry if available
    /// - Throws: Error if operation fails
    public func getValue<T: Codable & Sendable>(
        forKey key: String
    ) async throws -> CacheEntry<T>? {
        try await withValidation("getValue") {
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
                Age: \(Date().timeIntervalSince(entry.timestamp))s
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
        try await withValidation("removeValue") {
            let entryURL = fileURL(forKey: key)

            // Get file size before removal
            let fileSize = try? FileManager.default.attributesOfItem(atPath: entryURL.path)[.size] as? Int ?? 0

            // Remove file
            try FileManager.default.removeItem(at: entryURL)

            // Update size
            if let size = fileSize {
                queue.async(flags: .barrier) {
                    self.currentSize -= size
                }
            }

            // Log operation
            logger.debug(
                """
                Removed cache entry:
                Key: \(key)
                Size: \(fileSize ?? 0) bytes
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
        try await withValidation("clearCache") {
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
    private var currentSize: Int = 0

    // MARK: - Private Methods

    /// Validate service is usable and wrap operation
    private func withValidation<T>(_ operation: String, block: () async throws -> T) async throws -> T {
        try validateUsable(for: operation)
        return try await block()
    }

    private func validateUsable(for key: String) async throws -> Bool {
        let isValid = try await validateCache()
        guard isValid else {
            throw CacheError.cacheInvalid
        }
        return true
    }

    /// Set up cache directory
    private func setupDirectory() {
        do {
            try FileManager.default.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true,
                attributes: nil
            )

            // Calculate initial size
            let contents = try FileManager.default.contentsOfDirectory(
                at: directoryURL,
                includingPropertiesForKeys: [.fileSizeKey]
            )

            var totalSize = 0
            for url in contents {
                let attributes = try FileManager.default.attributesOfItem(
                    atPath: url.path
                )
                totalSize += attributes[.size] as? Int ?? 0
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

            var removedSize = 0
            var removedCount = 0

            for url in contents {
                // Check if entry is expired
                if let entry: CacheEntry<Data> = try? await load(from: url),
                   let expirationDate = entry.expirationDate,
                   expirationDate < Date() {
                    // Remove file
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
        directoryURL.appendingPathComponent(key.md5)
    }

    /// Load entry from file
    private func load<T: Codable & Sendable>(from url: URL) async throws -> CacheEntry<T> {
        guard let data = try? Data(contentsOf: url) else {
            throw CacheError.entryNotFound
        }
        return try JSONDecoder().decode(CacheEntry<T>.self, from: data)
    }

    /// Save entry to file
    private func save<T: Codable & Sendable>(
        _ entry: CacheEntry<T>,
        to url: URL
    ) async throws {
        let data = try JSONEncoder().encode(entry)
        try data.write(to: url, options: .atomicWrite)
    }
}
