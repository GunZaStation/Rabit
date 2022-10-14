import UIKit

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    static func imageWithColor(color: UIColor?, size: CGSize) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        (color ?? .white).setFill()
        UIBezierPath(ovalIn: rect).fill()
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func cropImageToSquare() -> UIImage {

        var imageWidth = self.size.width
        var imageHeight = self.size.height
        imageWidth = self.size.height
        imageHeight = self.size.width

        let rcy = imageHeight * 0.5
        let centerRect = CGRect(x: rcy - imageWidth * 0.5, y: 0, width: imageWidth, height: imageWidth)
        
        guard let croppedImage = self.cgImage?.cropping(to: centerRect) else { return self }
        return UIImage(cgImage: croppedImage, scale: 1.0, orientation: self.imageOrientation)
    }
}
