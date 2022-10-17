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

        let imageWidth = self.size.width
        let imageHeight = self.size.height
        let squareLength = min(imageWidth,imageHeight)

        let centerRect = CGRect(
            x: (imageHeight - squareLength) * 0.5,
            y: 0,
            width: squareLength,
            height: squareLength
        )
        
        guard let croppedImage = self.cgImage?.cropping(to: centerRect) else { return self }
        return UIImage(cgImage: croppedImage, scale: 1.0, orientation: self.imageOrientation)
    }
}
