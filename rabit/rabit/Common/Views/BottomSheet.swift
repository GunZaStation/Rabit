import UIKit
import SnapKit

final class BottomSheet: UIControl {
    
    private let topBar: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.roundCorners(4)
        return view
    }()
    
    let contentView = UIView()
    private var closeFlag = false {
        didSet { sendActions(for: .valueChanged) }
    }
    
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
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().multipliedBy(0.08)
            $0.width.equalToSuperview().multipliedBy(0.5)
            $0.height.equalTo(7)
        }
        
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top.equalTo(topBar.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.9)
            $0.height.equalToSuperview().multipliedBy(0.83)
        }
    }
}

extension BottomSheet {
    
    private func updateConstraints(_ topOffset: CGFloat) {
        self.snp.remakeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.top.equalToSuperview().inset(topOffset)
        }
    }
    
    func move(upTo topOffset: CGFloat,
              duration: CGFloat,
              animation: @escaping () -> Void,
              completion: @escaping (Bool) -> Void = { _ in }) {
        
        updateConstraints(topOffset)
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            animations: animation,
            completion: completion
        )
    }
}
