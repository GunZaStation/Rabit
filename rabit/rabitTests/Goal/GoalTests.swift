import XCTest
@testable import rabit

class GoalTests: XCTestCase {
    
    private var sut: Goal!

    override func setUpWithError() throws {
        self.sut = Goal(title: "", subtitle: "", period: .init(), certTime: .init(), category: "")
    }
    
    func testTarget_WhenCertDaysInPeriod() throws {
        // given
        let startDate = DateComponents(
            calendar: .current,
            timeZone: .init(secondsFromGMT: 0),
            year: 2022,
            month: 01,
            day: 01
        ).date!
        let endDate = DateComponents(
            calendar: .current,
            timeZone: .init(secondsFromGMT: 0),
            year: 2022,
            month: 01,
            day: 05
        ).date!
        let period = Period(
            start: startDate,
            end: endDate
        )
        
        let monToThu = Set<Day>([
            Day(rawValue: 1)!,
            Day(rawValue: 2)!,
            Day(rawValue: 3)!,
            Day(rawValue: 4)!
        ])
        let certDays = Days(monToThu)
        let certTime = CertifiableTime(
            start: 1,
            end: 60*60*12,
            days: certDays
        )
        
        // when
        sut = Goal(
            title: "",
            subtitle: "",
            period: period,
            certTime: certTime,
            category: "",
            createdDate: startDate
        )
        
        // then
        // 22.01.01(토) ~ 22.01.05(수) 사이 (월 ~ 목)의 갯수 == 3
        XCTAssertEqual(sut.target, 3)
    }
    
    func testTarget_WhenCertDaysNotInPeriod() throws {
        // given
        let startDate = DateComponents(
            calendar: .current,
            timeZone: .init(secondsFromGMT: 0),
            year: 2022,
            month: 01,
            day: 01
        ).date!
        let endDate = DateComponents(
            calendar: .current,
            timeZone: .init(secondsFromGMT: 0),
            year: 2022,
            month: 01,
            day: 05
        ).date!
        let period = Period(
            start: startDate,
            end: endDate
        )
        
        let friday = Set<Day>([
            Day(rawValue: 5)!
        ])
        let certDays = Days(friday)
        let certTime = CertifiableTime(
            start: 1,
            end: 60*60*12,
            days: certDays
        )
        
        // when
        sut = Goal(
            title: "",
            subtitle: "",
            period: period,
            certTime: certTime,
            category: "",
            createdDate: startDate
        )
        
        // then
        // 22.01.01(토) ~ 22.01.05(수) 사이 (금)의 갯수 == 0
        XCTAssertEqual(sut.target, 0)
    }
    
    func testTarget_WhenSameCertDaysInPeriod() throws {
        // given
        let startDate = DateComponents(
            calendar: .current,
            timeZone: .init(secondsFromGMT: 0),
            year: 2022,
            month: 01,
            day: 01
        ).date!
        let endDate = DateComponents(
            calendar: .current,
            timeZone: .init(secondsFromGMT: 0),
            year: 2022,
            month: 01,
            day: 15
        ).date!
        let period = Period(
            start: startDate,
            end: endDate
        )
        
        let saturday = Set<Day>([
            Day(rawValue: 6)!
        ])
        let certDays = Days(saturday)
        let certTime = CertifiableTime(
            start: 1,
            end: 60*60*12,
            days: certDays
        )
        
        // when
        sut = Goal(
            title: "",
            subtitle: "",
            period: period,
            certTime: certTime,
            category: "",
            createdDate: startDate
        )
        
        // then
        // 22.01.01(토) ~ 22.01.15(토) 사이 (토)의 갯수 == 3
        XCTAssertEqual(sut.target, 3)
    }
    
    func testTarget_CreatedDateIsLaterThanCertTime_AndCreatedDateIsInCertDays() throws {
        // given
        let startDate = DateComponents(
            calendar: .current,
            timeZone: .init(secondsFromGMT: 0),
            year: 2022,
            month: 01,
            day: 01
        ).date!
        let endDate = DateComponents(
            calendar: .current,
            timeZone: .init(secondsFromGMT: 0),
            year: 2022,
            month: 01,
            day: 15
        ).date!
        let period = Period(
            start: startDate,
            end: endDate
        )
        
        let createdDate = DateComponents(
            calendar: .current,
            timeZone: .init(secondsFromGMT: 0),
            year: 2022,
            month: 01,
            day: 01,
            hour: 1,
            minute: 0,
            second: 0
        ).date!
        
        let saturday = Set<Day>([
            Day(rawValue: 6)!
        ])
        let certDays = Days(saturday)
        let certTime = CertifiableTime(
            start: 1,
            end: 60*30, // 00:30
            days: certDays
        )
        
        // when
        sut = Goal(
            title: "",
            subtitle: "",
            period: period,
            certTime: certTime,
            category: "",
            createdDate: createdDate
        )
        
        // then
        // (22.01.01, 01:00에 만든 Goal, CertTime은 00:01~ 00:30) 22.01.01(토) ~ 22.01.15(토) 사이 (토)의 갯수 == 2
        XCTAssertEqual(sut.target, 2)
    }
}
