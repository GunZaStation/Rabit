import UIKit
import SnapKit

final class CircularProgressBar: UIView {
    var progress: Double? {
        didSet {
            self.setProgress(self.bounds)
        }
    }
    
    private let lineWidth = 5.62
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let bezierPath = UIBezierPath()
        
        bezierPath.addArc(
            withCenter: CGPoint(x: rect.midX, y: rect.midY),
            radius: rect.midX - lineWidth/2,
            startAngle: 0,
            endAngle: .pi * 2,
            clockwise: true
        )
        bezierPath.lineWidth = lineWidth
        UIColor(hexRGB: "#D9D9D9")?.set()
        bezierPath.stroke()

        self.setProgress(rect)
    }
    
    private func setProgress(_ rect: CGRect) {
        guard let value = progress else { return }
        
        // Cell이 reuse될 때 ProgressBar가 여러번 겹쳐져서 그려지는 것을 방지하기 위한 코드
        self.subviews.forEach { $0.removeFromSuperview() }
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let bezierPath = UIBezierPath()
        
        bezierPath.addArc(
            withCenter: CGPoint(x: rect.midX, y: rect.midY),
            radius: rect.midX - lineWidth/2,
            startAngle: -.pi/2,
            endAngle: ((.pi * 2) * value) - (.pi / 2),
            clockwise: true
        )
        
        let shapeLayer = CAShapeLayer()
        
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.lineCap = .round
        
        let progressBarColor = UIColor(hexRGB: "#EE5B0B") ?? .white
        
        shapeLayer.strokeColor = progressBarColor.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = lineWidth
        
        self.layer.addSublayer(shapeLayer)
        
        let checkMarkImageView = UIImageView()
        let tintColor = value < 1.0 ? (UIColor(hexRGB: "#D9D9D9") ?? .white) : progressBarColor
        checkMarkImageView.image = UIImage(named: "checkmark")?.withTintColor(tintColor)
        
        self.addSubview(checkMarkImageView)
        checkMarkImageView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
}
