import UIKit
import SnapKit
import RxCocoa
import RxDataSources
import RxSwift

final class GoalListViewController: UIViewController {
    
    private lazy var goalListDataSource: RxCollectionViewSectionedReloadDataSource<Goal> = {
        initializeDataSource()
    }()
    
    private lazy var goalListCollectionView: UICollectionView = {
        initializeCollectionView()
    }()
    
    private var viewModel: GoalListViewModel?
    private let disposeBag = DisposeBag()
    
    convenience init(viewModel: GoalListViewModel) {
        
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setAttributes()
        bind()
        
        viewModel?.requestGoalList.accept(())
    }
    
    private func bind() {
        guard let viewModel = viewModel else { return }
        
        viewModel.goalList
            .bind(to: goalListCollectionView.rx.items(dataSource: goalListDataSource))
            .disposed(by: disposeBag)
        
        navigationItem.rightBarButtonItem?.rx.tap
            .bind(to: viewModel.categoryAddButtonTouched)
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "카테고리 생성", style: .plain, target: self, action: nil)
    }
}

extension GoalListViewController {
    
    private func initializeDataSource() -> RxCollectionViewSectionedReloadDataSource<Goal> {
        return .init(
            configureCell: { dataSource, collectionView, indexPath, goalDetail in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: GoalListCollectionViewCell.identifier,
                    for: indexPath
                ) as? GoalListCollectionViewCell else {
                    return UICollectionViewCell()
                }
                
                cell.configure(goalDetail: goalDetail)
                
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
                
                let goal = dataSource.sectionModels[indexPath.section]
                header.configure(title: goal.category)
                
                return header
            }
        )
    }
    
    private func initializeCollectionView() -> UICollectionView {
        
        let layout = AlbumCollectionCompositionalLayoutFactory.shared.create(
            widthFraction: 1.0,
            heightFraction: 0.21,
            bottomSpacing: 15,
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
