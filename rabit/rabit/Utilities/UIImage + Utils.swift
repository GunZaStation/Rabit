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
        guard let image: UIImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return UIImage()
        }
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
        
        func overlayText(of photo: Photo) -> UIImage? {
            let text = DateConverter.convertToDateString(date: photo.date)
            let textColor = UIColor(hexRGB: photo.color) ?? .white
            let fontSize: CGFloat = 100
            let imageSize = size
            let textFont = UIFont(name: photo.style.name, size: fontSize) ?? UIFont.systemFont(ofSize: 100)
            
            let attributedString = NSMutableAttributedString(string: text)
            attributedString.addAttributes(
                [NSAttributedString.Key.font: textFont,
                 NSAttributedString.Key.foregroundColor: textColor],
                range: (text as NSString).range(of: text)
            )
            
            let image = UIImage(data: photo.imageData) ?? UIImage()
            
            UIGraphicsBeginImageContextWithOptions(imageSize, false, 1.0)
            
            image.draw(in: CGRect(origin: .zero, size: imageSize))
            
            let label = UILabel()
            label.numberOfLines = 0
            label.textAlignment = .center
            label.attributedText = attributedString
            label.drawText(in: CGRect(origin: .zero, size: imageSize))
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage
        }
    }
}
