import UIKit
import SnapKit
import RxCocoa
import RxDataSources
import RxSwift

final class GoalListViewController: UIViewController {
    
    private lazy var goalListDataSource: RxCollectionViewSectionedReloadDataSource<Category> = {
        initializeDataSource()
    }()
    
    private lazy var goalListCollectionView: UICollectionView = {
        initializeCollectionView()
    }()
    
    private var viewModel: GoalListViewModelProtocol?
    private let disposeBag = DisposeBag()
    
    convenience init(viewModel: GoalListViewModelProtocol) {
        
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setAttributes()
        bind()
    }
    
    private func bind() {
        guard let viewModel = viewModel else { return }
        
        viewModel.goalList
            .bind(to: goalListCollectionView.rx.items(dataSource: goalListDataSource))
            .disposed(by: disposeBag)
        
        navigationItem.rightBarButtonItem?.rx.tap
            .throttle(.milliseconds(400), scheduler: MainScheduler.instance)
            .bind(to: viewModel.categoryAddButtonTouched)
            .disposed(by: disposeBag)
        
        goalListCollectionView.rx.modelSelected(Goal.self)
            .bind(to: viewModel.showGoalDetailView)
            .disposed(by: disposeBag)
        
        viewModel.requestGoalList.accept(())
        
        viewModel.showActionSheetMenu
            .withUnretained(self)
            .bind(onNext: { viewController, goal in

                let actionSheetMenu = UIAlertController(title: nil, message: "옵션 선택", preferredStyle: .actionSheet)

                let deleteAction = UIAlertAction(title: "목표 삭제하기", style: .destructive, handler: { _ in
                    viewController.showAlert(message: "정말 삭제하시겠습니까?", activateCancelAction: true) {
                        viewModel.deleteGoal.accept(goal)
                    }
                })
                let cancelAction = UIAlertAction(title: "닫기", style: .cancel, handler: nil)
                
                actionSheetMenu.addAction(deleteAction)
                actionSheetMenu.addAction(cancelAction)
                
                viewController.present(actionSheetMenu, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        viewModel.showAlert
            .withUnretained(self)
            .bind(onNext: { viewController, message in
                viewController.showAlert(message: message)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupViews() {
        
        view.addSubview(goalListCollectionView)
        goalListCollectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    private func setAttributes() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "카테고리 추가", style: .plain, target: self, action: nil)
        navigationItem.rightBarButtonItem?.tintColor = UIColor(hexRGB: "#EE5B0B")
    }
}

private extension GoalListViewController {
    
    func showActionSheet() {
        
    }
    
    func showAlert(title: String? = nil, message: String, activateCancelAction: Bool = false, actionHandler: (() -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "확인", style: .default, handler: { _ in
            if let actionHandler = actionHandler {
                actionHandler()
            }
        })
        alert.addAction(confirmAction)
        
        if activateCancelAction {
            let cancelAction = UIAlertAction(title: "취소", style: .destructive)
            alert.addAction(cancelAction)
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func initializeDataSource() -> RxCollectionViewSectionedReloadDataSource<Category> {
        let viewModel = viewModel
        return .init(
            configureCell: { dataSource, collectionView, indexPath, goal in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: GoalListCollectionViewCell.identifier,
                    for: indexPath
                ) as? GoalListCollectionViewCell else {
                    return UICollectionViewCell()
                }
                
                cell.configure(goal: goal)
                cell.bind(to: viewModel, with: goal)
                
                return cell
            },
            configureSupplementaryView: {(dataSource, collectionView, kind, indexPath) -> UICollectionReusableView in
                guard let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: GoalListCollectionViewHeader.identifier,
                    for: indexPath
                ) as? GoalListCollectionViewHeader else {
                    return UICollectionReusableView()
                }
                
                let category = dataSource.sectionModels[indexPath.section]
                header.configure(with: category.title)
                header.bind(viewModel: viewModel, category: category)
                
                return header
            }
        )
    }
    
    func initializeCollectionView() -> UICollectionView {
        
        let layout = CompositionalLayoutFactory.shared.create(
            widthFraction: 1.0,
            heightFraction: 0.21,
            spacing: Spacing(bottom: 15),
            requireHeader: true,
            headerWidth: view.frame.width*0.85,
            headerHeight: view.frame.height*0.07
        )
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.register(
            GoalListCollectionViewCell.self,
            forCellWithReuseIdentifier: GoalListCollectionViewCell.identifier
        )
        
        collectionView.register(
            GoalListCollectionViewHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: GoalListCollectionViewHeader.identifier
        )
        
        collectionView.showsVerticalScrollIndicator = false
        
        return collectionView
    }
}
