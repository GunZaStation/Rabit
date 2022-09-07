import Foundation
import UIKit

extension String {

    func strikeThrough() -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)

        attributedString.addAttribute(
            NSAttributedString.Key.strikethroughStyle,
            value: NSUnderlineStyle.single.rawValue,
            range: NSRange(0..<attributedString.length)
        )

        return attributedString
    }
}
