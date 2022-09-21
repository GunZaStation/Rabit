import Foundation

extension Date {
    func isSameDate(with target: Self) -> Bool {
        let calendar = Calendar.current
        let refDateComponent = calendar.dateComponents([.year, .month, .day], from: self)
        let targetDateComponent = calendar.dateComponents([.year, .month, .day], from: target)

        return refDateComponent.year == targetDateComponent.year
            && refDateComponent.month == targetDateComponent.month
            && refDateComponent.day == targetDateComponent.day
    }
}
