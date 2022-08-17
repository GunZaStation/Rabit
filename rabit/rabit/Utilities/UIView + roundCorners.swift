import UIKit

extension UIView {
    func roundCorners(_ radius: CGFloat = 10) {
        self.layer.cornerCurve = .continuous
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
}
