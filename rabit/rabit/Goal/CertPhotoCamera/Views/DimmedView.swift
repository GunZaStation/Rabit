import UIKit

class DimmedView: UIView {
    
    private var transparentRect: CGRect?
    
    convenience init(backgroundColor: UIColor = .black, transparentRect: CGRect? = nil) {
        self.init()
        self.transparentRect = transparentRect
        self.backgroundColor = backgroundColor
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setTransparentArea(rect)
    }
    
    private func setTransparentArea(_ rect: CGRect) {
        guard let transparentRect = transparentRect else { return }
        let transparentColor = UIColor.clear
        transparentColor.setFill()
        UIRectFill(rect.intersection(transparentRect))
    }
}
