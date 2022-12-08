import Foundation
import RxRelay
@testable import rabit

/* Navigation 프로토콜의 property들 중,
   BehaviorRelay을 value type으로 하는 Observable들이 있어,
   해당 Observable 들의 value 일치 여부를 판단하기 위해 만든 Equatable extension
 */
extension BehaviorRelay: Equatable where Element: Equatable {
    public static func == (lhs: BehaviorRelay<Element>, rhs: BehaviorRelay<Element>) -> Bool {
        return lhs.value == rhs.value
    }
}
