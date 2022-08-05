import UIKit
import SnapKit
import RxCocoa
import RxDataSources
import RxSwift

final class GoalListViewController: UIViewController {
    
    typealias DataSource = RxCollectionViewSectionedReloadDataSource
    private let goalListDataSource = DataSource<Goal> { _, collectionView, indexPath, goalDetail in
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GoalListCollectionViewCell.identifier, for: indexPath) as? GoalListCollectionViewCell else { return UICollectionViewCell() }
        
        
        cell.configure(title: goalDetail.title, subtitle: goalDetail.subtitle, progress: goalDetail.progress, target: goalDetail.target)
        
        return cell
    }
    
    private lazy var goalListCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = .init(top: .zero, left: .zero, bottom: 15, right: .zero)
        layout.itemSize = CGSize(width: view.frame.width*0.85, height: view.frame.height*0.15)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            GoalListCollectionViewCell.self,
            forCellWithReuseIdentifier: GoalListCollectionViewCell.identifier
        )
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private var viewModel: GoalListViewModel?
    private let disposeBag = DisposeBag()

    convenience init(viewModel: GoalListViewModel = GoalListViewModel()) {
        
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        bind()
        
        viewModel?.bind()
    }
    
    private func bind() {
  
        viewModel?.categories
            .bind(to: goalListCollectionView.rx.items(dataSource: goalListDataSource))
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
    
}
