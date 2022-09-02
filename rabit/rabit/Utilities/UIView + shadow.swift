import UIKit

extension UIView {
    
    func shadowApplied(offset: CGSize = CGSize(width: 0, height: 5), opacity: Float) {
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.masksToBounds = false
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = opacity
    }
}
