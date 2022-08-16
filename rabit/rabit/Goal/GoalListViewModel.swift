import Foundation
import RxSwift
import RxCocoa

final class GoalListViewModel {
    
    let categoryAddButtonTouched = PublishRelay<Void>()
    let categories = PublishRelay<[Goal]>()
    
    weak var navigation: GoalNavigation?
    
    private var sections: [Goal] = [
        Goal(category: "운동", details: []),
        Goal(category: "공부", details: []),
        Goal(category: "건강", details: []),
        Goal(category: "독서", details: [])
    ]
    
    private let disposeBag = DisposeBag()
    
    init() {
        setMockData()
        bind()
    }
    
    private func bind() {
        
        categoryAddButtonTouched
            .withUnretained(self)
            .bind(onNext: { viewModel, _ in
                viewModel.navigation?.showCategoryAddView()
            })
            .disposed(by: disposeBag)
    }
    
    func getMockData() {
        
        categories.accept(sections)
    }
}

extension GoalListViewModel {
    
    private func setMockData() {
        category1()
        category2()
        category3()
        category4()
    }
    
    private func category1() {
        let models = [
            GoalDetail(title: "유산소", subtitle: "공원에서 달리기", progress: 50, target: 100),
            GoalDetail(title: "근력", subtitle: "2분할 주 4회", progress: 60, target: 100),
            GoalDetail(title: "스트레칭", subtitle: "스트레칭 하기", progress: 20, target: 100),
            GoalDetail(title: "보조 운동", subtitle: "팔과 복근", progress: 40, target: 100),
        ]
        sections[0].items = models
    }
    
    private func category2() {
        let models = [
            GoalDetail(title: "CS 공부", subtitle: "운영체제, 네트워크 스터디", progress: 10, target: 100),
            GoalDetail(title: "Swift 공부", subtitle: "WWDC 발표자료 정리", progress: 20, target: 100)
        ]
        sections[1].items = models
    }
    
    private func category3() {
        let models = [
            GoalDetail(title: "영양제", subtitle: "비타민 먹기", progress: 40, target: 80),
            GoalDetail(title: "수면 패턴", subtitle: "일찍 자기", progress: 60, target: 120)
        ]
        sections[2].items = models
    }
    
    private func category4() {
        let models = [
            GoalDetail(title: "만화책 읽기", subtitle: "짱구는 못말려 완독", progress: 50, target: 200)
        ]
        sections[3].items = models
    }
}
