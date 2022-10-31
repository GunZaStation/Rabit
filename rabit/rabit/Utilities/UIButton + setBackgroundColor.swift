import UIKit

extension UIButton {
    func setBackgroundColor(_ color: UIColor?, for state: UIControl.State) {
        guard let color = color else { return }
        let size = CGSize(width: 1.0, height: 1.0)
        let renderer = UIGraphicsImageRenderer(size: size)

        let backgroundImage = renderer.image { context in
            color.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 1.0, height: 1.0))
        }

        self.setBackgroundImage(backgroundImage, for: state)
    }
}
