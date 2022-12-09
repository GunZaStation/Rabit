import Foundation
import RxRelay
@testable import rabit

final class CalendarUsecaseMock: CalendarUsecaseProtocol {

    var dates: [CalendarDates] = []
    var startDate: BehaviorRelay<Date?> = .init(value: nil)
    var endDate: BehaviorRelay<Date?> = .init(value: nil)
    
    var updateSelectedDateCallCount = 0
    var updateSelectedDataInputDate: CalendarDate?
    func updateSelectedDate(with newDate: CalendarDate) {
        self.updateSelectedDateCallCount += 1
        self.updateSelectedDataInputDate = newDate
    }
    
    var updateDeselectedDateCallCount = 0
    var updateDeselectedDateInputDate: CalendarDate?
    func updateDeselectedDate(with oldDate: CalendarDate) {
        self.updateDeselectedDateCallCount += 1
        self.updateDeselectedDateInputDate = oldDate
    }
}
