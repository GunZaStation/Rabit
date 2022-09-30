import Foundation
import RxSwift
import RxRelay

protocol CalendarUsecaseProtocol {
    var dates: [CalendarDates] { get }
    var startDate: BehaviorRelay<Date?> { get }
    var endDate: BehaviorRelay<Date?> { get }

    func updateSelectedDate(with newDate: CalendarDate)
    func updateDeselectedDate(with oldDate: CalendarDate)
}

struct CalendarUsecase: CalendarUsecaseProtocol {
    private let calendar = Calendar(identifier: .gregorian)

    var dates: [CalendarDates] {
        return (0..<12).map { offset -> CalendarDates in
            generateDatesInMonth(for: calendar.date(byAdding: .month, value: offset, to: Date()) ?? Date())
        }
    }
    let startDate: BehaviorRelay<Date?>
    let endDate: BehaviorRelay<Date?>

    init(periodStream: BehaviorRelay<Period>) {
        startDate = .init(value: periodStream.value.start)
        endDate = .init(value: periodStream.value.end)
    }

    func updateSelectedDate(with newDate: CalendarDate) {
        let newDate = newDate.date
        let countSetDate = [startDate.value, endDate.value]
            .compactMap { $0 }
            .count
        var isSetSameDate: Bool {
            if let startDateValue = startDate.value,
               let endDateValue = endDate.value {
                return startDateValue.isSameDate(with: endDateValue)
            }
            return false
        }

        if countSetDate == 2 && isSetSameDate {
            guard let startDateValue = startDate.value else { return }

            if startDateValue >= newDate {
                startDate.accept(newDate)
                endDate.accept(startDateValue)
            } else {
                endDate.accept(newDate)
            }

        } else {
            startDate.accept(newDate)
            endDate.accept(newDate)
        }
    }

    func updateDeselectedDate(with oldDate: CalendarDate) {
        let oldDate = oldDate.date
        let startDateValue = startDate.value
        let endDateValue = endDate.value

        if let startDateValue = startDateValue,
           oldDate.isSameDate(with: startDateValue) {
            startDate.accept(endDateValue == startDateValue ? nil : endDateValue)
        }

        if let endDateValue = endDateValue,
           oldDate.isSameDate(with: endDateValue) {
            endDate.accept(startDateValue == endDateValue ? nil : startDateValue)
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
