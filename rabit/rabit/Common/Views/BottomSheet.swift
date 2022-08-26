import UIKit
import SnapKit

final class BottomSheet: UIView {
    
    private let topBar: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.roundCorners(4)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(topBar)
        topBar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.width.equalToSuperview().multipliedBy(0.5)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(8)
        }
    }
}
