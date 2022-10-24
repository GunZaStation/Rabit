import Foundation
import ImageIO

extension Data {
    func toDownsampledCGImage(pointSize: CGSize, scale: CGFloat) -> CGImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(
            self as CFData,
            imageSourceOptions) else {
            return nil
        }
        let maxDimensionInPixels = Swift.max(pointSize.width, pointSize.height) * scale
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary

        return CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)
    }
}
