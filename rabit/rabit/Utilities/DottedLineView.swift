import UIKit

final class DottedLineView: UIView {
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawLine()
    }
    
    private func drawLine() {
        
        let borderLayer = CAShapeLayer()
        borderLayer.strokeColor = UIColor.systemGray.cgColor
        borderLayer.lineDashPattern = [2, 2]
        borderLayer.frame = self.bounds
        borderLayer.fillColor = nil
        borderLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 15).cgPath
        self.layer.addSublayer(borderLayer)
        self.setNeedsDisplay()
    }
}
