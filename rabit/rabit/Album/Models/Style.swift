import Foundation

enum Style: String, CaseIterable {
    case Helvetica
    case AmericanTypewriter
    case AppleSDGothic
    case Noteworthy
    case GillSans
    case Verdana
    case none

    init(_ StyleString: String) {
        switch StyleString.lowercased() {
        case "helvetica": self = .Helvetica
        case "americantypewriter": self = .AmericanTypewriter
        case "applesdgothic": self = .AppleSDGothic
        case "noteworthy": self = .Noteworthy
        case "gillsans": self = .GillSans
        case "verdana": self = .Verdana
        default: self = .none
        }
    }

    var name: String {
        switch self {
        case .Helvetica:
            return "Helvetica-Bold"
        case .AmericanTypewriter:
            return "AmericanTypewriter-Bold"
        case .AppleSDGothic:
            return "AppleSDGothicNeo-Bold"
        case .Noteworthy:
            return "Noteworthy-Bold"
        case .GillSans:
            return "GilSans-BoldItalic"
        case .Verdana:
            return "Verdana-Bold"
        case .none:
            return ""
        }
    }
}

