import UIKit

extension UIColor {
    convenience init?(hexRGBA: String?) {
        guard let rgba = hexRGBA,
              let val = Int(rgba.replacingOccurrences(of: "#", with: ""), radix: 16) else {
            return nil
        }

        self.init(
            red: CGFloat((val >> 24) & 0xff) / 255.0,
            green: CGFloat((val >> 16) & 0xff) / 255.0,
            blue: CGFloat((val >> 8) & 0xff) / 255.0,
            alpha: CGFloat(val & 0xff) / 255.0
        )
    }

    convenience init?(hexRGB: String?) {
        guard let rgb = hexRGB else {
            return nil
        }
        self.init(hexRGBA: rgb + "ff") // Add alpha = 1.0
    }
    
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb: Int = (Int)(r * 255) << 24 | (Int)(g*255) << 16 | (Int)(b*255) << 8 | (Int)(a*255) << 0
        
        return NSString(format: "#%08x", rgb) as String
    }
}
