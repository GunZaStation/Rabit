import UIKit
import RxSwift
import RxCocoa

final class CertPhotoCameraViewController: UIViewController {
    
    private let shutterButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.systemGray.cgColor
        button.layer.cornerRadius = 50
        button.layer.borderWidth = 10
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 50
        button.setTitle("✅", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.isHidden = true
        return button
    }()
    
    private let previewLayerView = UIView()
    private let previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isHidden = true
        return imageView
    }()
    
    private let disposeBag = DisposeBag()
    private let cameraManager: CameraManagable = CameraManager()
    private var viewModel: CertPhotoCameraViewModel?
    
    convenience init(viewModel: CertPhotoCameraViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setAttributes()
        bind()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cameraManager.prepareCapturing(with: previewLayerView)
    }
    
    private func bind() {
        guard let viewModel = viewModel else { return }
        
        shutterButton.rx.tap
            .withUnretained(self)
            .bind(onNext: { viewController, _ in
                viewController.cameraManager.capture { originalImage in
                    let resizedImageData = viewController.getResizedImageData(with: originalImage)
                    viewModel.certPhotoDataInput.accept(resizedImageData)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.previewPhotoData
            .map { UIImage(data: $0) }
            .bind(to: previewImageView.rx.image)
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .bind(to: viewModel.nextButtonTouched)
            .disposed(by: disposeBag)
    }
    
    private func setupViews() {
        
        view.addSubview(previewLayerView)
        previewLayerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(120)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(view.snp.width)
        }
        
        view.addSubview(previewImageView)
        previewImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(100)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(previewLayerView.snp.width)
        }
        
        view.addSubview(shutterButton)
        shutterButton.snp.makeConstraints {
            $0.width.equalTo(100)
            $0.height.equalTo(100)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(100)
        }
        
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints {
            $0.width.equalTo(100)
            $0.height.equalTo(100)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(100)
        }
    }
    
    private func setAttributes() {
        
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: nil)
    }
}

extension CertPhotoCameraViewController {
    
    func getResizedImageData(with originalImageData: Data) -> Data {
        
        guard let capturedImage = UIImage(data: originalImageData) else {
            return originalImageData
        }
        
        let length = view.bounds.width
        let squaredSize = CGSize(width: length, height: length)
        let squaredImage = capturedImage.cropImageToSquare()
                                        .resized(to: squaredSize)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.previewImageView.isHidden = false
            self.nextButton.isHidden = false
            self.shutterButton.isHidden = true
            self.previewLayerView.isHidden = true
            
            self.cameraManager.endCapturing()
        }
        
        return squaredImage.pngData() ?? originalImageData
    }
}
