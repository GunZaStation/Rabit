import UIKit

class ImageCacheManager {
    static let shared = NSCache<NSString, UIImage>()

    private init() { }
}
