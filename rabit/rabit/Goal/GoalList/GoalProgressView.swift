import UIKit
import SnapKit

final class GoalProgressView: UIView {
    
    private let carrotIcon: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "carrot")
        imageView.image = image
        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    private let rabbitIcon: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "rabbit")
        imageView.image = image
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    private let targetView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        view.clipsToBounds = true
        view.layer.cornerRadius = 5
        return view
    }()
    
    private let progressView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemOrange
        return view
    }()
    
    var progress: CGFloat? {
        didSet {
            updateProgress(progress: progress ?? 0.0)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAttributes()
        setupViews()
    }
    
    private func updateProgress(progress: CGFloat) {
        
        progressView.snp.remakeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(progress)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setAttributes() {
        backgroundColor = .systemBackground
    }
    
    private func setupViews() {
        
        addSubview(targetView)
        targetView.snp.makeConstraints {
            $0.centerY.leading.trailing.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.5)
        }
        
        targetView.addSubview(progressView)
        progressView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.47)
        }
        
        addSubview(carrotIcon)
        carrotIcon.snp.makeConstraints {
            $0.centerY.trailing.equalToSuperview()
            $0.width.equalTo(25)
            $0.height.equalTo(30)
        }
        
        addSubview(rabbitIcon)
        rabbitIcon.snp.makeConstraints {
            $0.trailing.equalTo(progressView.snp.trailing)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(35)
            $0.height.equalTo(30)
        }
    }
}
