import Foundation
import RxSwift
import RxRelay

protocol CalendarManagable {
    var dates: [CalendarDates] { get }
    var startDate: BehaviorRelay<CalendarDate?> { get }
    var endDate: BehaviorRelay<CalendarDate?> { get }

    func updateSelectedDate(with newDate: CalendarDate)
}

struct CalendarUsecase: CalendarManagable {
    private let calendar = Calendar(identifier: .gregorian)

    var dates: [CalendarDates] {
        return (0..<12).map { offset -> CalendarDates in
            generateDatesInMonth(for: calendar.date(byAdding: .month, value: offset, to: Date()) ?? Date())
        }
    }
    var startDate = BehaviorRelay<CalendarDate?>(value: nil)
    var endDate = BehaviorRelay<CalendarDate?>(value: nil)

    func updateSelectedDate(with newDate: CalendarDate) {
        let isSetBothDates = (startDate.value != nil && endDate.value != nil)

        if isSetBothDates {
            startDate.accept(newDate)
            endDate.accept(nil)
        } else if let startDayValue = startDate.value {
            if newDate.date <= startDayValue.date {
                endDate.accept(startDayValue)
                startDate.accept(newDate)
            } else {
                endDate.accept(newDate)
            }
        } else {
            startDate.accept(newDate)
            endDate.accept(nil)
        }
    }
}

private extension CalendarUsecase {
    func generateDatesInMonth(for baseDate: Date) -> CalendarDates {
        guard let monthMetaData = getMonthMetaData(for: baseDate) else { return CalendarDates(items: []) }

        let numberOfDaysInMonth = monthMetaData.numberOfDays
        let offsetInInitialRow = monthMetaData.firstDayOfWeekday
        let firstDayOfMonth = monthMetaData.firstDay

        let dates: [CalendarDate] = (1..<(numberOfDaysInMonth + offsetInInitialRow))
            .map { day in
                let isWithinDisplayedMonth = day >= offsetInInitialRow

                let dayOffset = isWithinDisplayedMonth ? day - offsetInInitialRow : -(offsetInInitialRow - day)

                return generateDate(
                    offsetBy: dayOffset,
                    for: firstDayOfMonth,
                    isWithinDisplayedMonth: isWithinDisplayedMonth
                )
            }

        return CalendarDates(items: dates)
    }

    func generateDate(
        offsetBy dayOffset: Int,
        for baseDate: Date,
        isWithinDisplayedMonth: Bool
    ) -> CalendarDate {
        let date = calendar.date(
            byAdding: .day,
            value: dayOffset,
            to: baseDate
        ) ?? baseDate
        let yesterDay = Date(timeIntervalSinceNow: -86400)
        let isBeforeToday = date <= yesterDay

        return CalendarDate(
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
