import Foundation

protocol CalendarManagable {
    var days: [Days] { get }
}

struct CalendarUsecase: CalendarManagable {
    private let calendar = Calendar(identifier: .gregorian)

    var days: [Days] {
        return (0..<12).map { offset -> Days in
            generateDaysInMonth(for: calendar.date(byAdding: .month, value: offset, to: Date()) ?? Date())
        }
    }
}

private extension CalendarUsecase {
    func generateDaysInMonth(for baseDate: Date) -> Days {
        guard let monthMetaData = getMonthMetaData(for: baseDate) else { return Days(items: []) }

        let numberOfDaysInMonth = monthMetaData.numberOfDays
        let offsetInInitialRow = monthMetaData.firstDayOfWeekday
        let firstDayOfMonth = monthMetaData.firstDay

        let days: [Day] = (1..<(numberOfDaysInMonth + offsetInInitialRow))
            .map { day in
                let isWithinDisplayedMonth = day >= offsetInInitialRow

                let dayOffset = isWithinDisplayedMonth ? day - offsetInInitialRow : -(offsetInInitialRow - day)

                return generateDay(
                    offsetBy: dayOffset,
                    for: firstDayOfMonth,
                    isWithinDisplayedMonth: isWithinDisplayedMonth
                )
            }

        return Days(items: days)
    }

    func generateDay(
        offsetBy dayOffset: Int,
        for baseDate: Date,
        isWithinDisplayedMonth: Bool
    ) -> Day {
        let date = calendar.date(
            byAdding: .day,
            value: dayOffset,
            to: baseDate
        ) ?? baseDate
        let yesterDay = Date(timeIntervalSinceNow: -86400)
        let isBeforeToday = date <= yesterDay

        return Day(
            date: date,
            number: DateConverter.convertToDayString(date: date),
            isSelected: false,
            isWithinDisplayedMonth: isWithinDisplayedMonth,
            isBeforeToday: isBeforeToday
        )
    }

    func getMonthMetaData(for baseDate: Date) -> MonthMetaData? {
        guard let numberOfDaysInMonth = calendar.range(
            of: .day,
            in: .month,
            for: baseDate
        )?.count,
              let firstDayOfMonth = calendar.date(from: calendar.dateComponents(
                [.year, .month],
                from: baseDate
              )) else { return nil }

        let firstDayOfWeekday = calendar.component(.weekday, from: firstDayOfMonth)

        return MonthMetaData(
            numberOfDays: numberOfDaysInMonth,
            firstDay: firstDayOfMonth,
            firstDayOfWeekday: firstDayOfWeekday
        )
    }
}
