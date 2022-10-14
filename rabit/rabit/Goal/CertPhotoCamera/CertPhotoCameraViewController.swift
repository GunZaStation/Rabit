import AVFoundation
import UIKit
import RxSwift
import RxCocoa

final class CertPhotoCameraViewController: UIViewController {
    
    
    private lazy var dimmedView: DimmedView = {
        let totalWidth = view.bounds.width
        let totalHeight = view.bounds.height
        let length = min(totalWidth, totalHeight)
        
        let centerOrigin = CGPoint(x: .zero, y: (totalHeight-length)/2)
        let centerSize = CGSize(width: length, height: length)
        let centerRect = CGRect(origin: centerOrigin, size: centerSize)

        let backgroundColor = UIColor.black.withAlphaComponent(0.8)
        let view = DimmedView(backgroundColor: backgroundColor, transparentRect: centerRect)
        return view
    }()

    
    private let shutterButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.cornerRadius = 50
        button.layer.borderWidth = 10
        return button
    }()
    
    private let previewLayerView = UIView()
    private let previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setAttributes()
        bind()
    }
    
    private func bind() {
        
    }
    
    private func setupViews() {
        
        view.addSubview(previewLayerView)
        previewLayerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        view.addSubview(dimmedView)
        dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        view.addSubview(previewImageView)
        previewImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        view.addSubview(shutterButton)
        shutterButton.snp.makeConstraints {
            $0.width.equalTo(100)
            $0.height.equalTo(100)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(30)
        }
    }
    
    private func setAttributes() {
        
        view.backgroundColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: nil)
    }
    
