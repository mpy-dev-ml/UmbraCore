import Foundation

/// Mock implementation of URLProvider for testing
public class MockURLProvider: URLProvider {
    /// Simulated bookmark data
    private var mockBookmarkData: [URL: Data] = [:]
    
    /// Set of accessed URLs
    private var accessedURLs: Set<URL> = []
    
    /// Initialize a new mock provider
    public init() {}
    
    public func createBookmarkData(for url: URL) throws -> Data {
        let data = "MockBookmark:\(url.path)".data(using: .utf8)!
        mockBookmarkData[url] = data
        return data
    }
    
    public func resolveBookmarkData(_ data: Data, isStale: inout Bool) throws -> URL {
        guard let str = String(data: data, encoding: .utf8),
              str.hasPrefix("MockBookmark:") else {
            throw NSError(domain: "MockURLProvider", code: -1)
        }
        
        let path = String(str.dropFirst("MockBookmark:".count))
        isStale = path.contains("stale")
        return URL(string: path)!
    }
    
    public func startAccessingSecurityScopedResource(_ url: URL) -> Bool {
        accessedURLs.insert(url)
        return true
    }
    
    public func stopAccessingSecurityScopedResource(_ url: URL) {
        accessedURLs.remove(url)
    }
}
