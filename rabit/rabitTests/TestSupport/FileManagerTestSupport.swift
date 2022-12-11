import Foundation

final class FileManagerMock: FileManager {
    
    var mockURLsResult: [URL]?
    
    var urlsCallCount = 0
    override func urls(
        for directory: FileManager.SearchPathDirectory,
        in domainMask: FileManager.SearchPathDomainMask
    ) -> [URL] {
        self.urlsCallCount += 1
        
        if let mockURLsResult = mockURLsResult {
            return mockURLsResult
        }
        return []
    }
    
    var mockFileExistsResult: Bool?
    
    var fileExistsCallCount = 0
    override func fileExists(atPath path: String) -> Bool {
        self.fileExistsCallCount += 1
        
        if let mockFileExistsResult = mockFileExistsResult {
            return mockFileExistsResult
        }
        return false
    }
    
    var removeItemCallCount = 0
    override func removeItem(at URL: URL) throws {
        self.removeItemCallCount += 1
    }
}
