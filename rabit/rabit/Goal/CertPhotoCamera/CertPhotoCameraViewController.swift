import AVFoundation
import UIKit
import RxSwift
import RxCocoa

final class CertPhotoCameraViewController: UIViewController {
    
    private var captureSession: AVCaptureSession?
    
    private let capturedOutput = AVCapturePhotoOutput()
    private let previewLayer = AVCaptureVideoPreviewLayer()
    
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
        checkCameraPermissionSettings()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupPreviewLayerView()
    }
    
    private func setupPreviewLayerView() {
        
        previewLayerView.layer.addSublayer(previewLayer)
        previewLayer.frame = previewLayerView.bounds
    }
    
    private func bind() {
        
        shutterButton.rx.tapGesture()
            .when(.recognized)
            .withUnretained(self)
            .bind(onNext: { viewController, _ in
                viewController.capturedOutput.capturePhoto(
                    with: AVCapturePhotoSettings(),
                    delegate: viewController
                )
            })
            .disposed(by: disposeBag)
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
    
    private func checkCameraPermissionSettings() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] isAllowed in
                guard isAllowed else { return }
                DispatchQueue.main.async {
                    self?.setupCamera()
                }
            }
        case .authorized:
            setupCamera()
        default:
            break
        }
    }
    
    private func setupCamera() {
        guard let device = AVCaptureDevice.default(for:.video) else { return }
        let session = AVCaptureSession()
        session.sessionPreset = .photo
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            if session.canAddOutput(capturedOutput) {
                session.addOutput(capturedOutput)
            }
            
            previewLayer.videoGravity = .resizeAspect
            previewLayer.session = session
            
            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
            }
            
            captureSession = session
        }
        catch {
            fatalError("unknown error while setting up camera")
        }
    }
}

extension CertPhotoCameraViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let capturedData = photo.fileDataRepresentation(),
              let capturedImage = UIImage(data: capturedData) else { return }
        
        let length = view.bounds.width
        let squaredSize = CGSize(width: length, height: length)
        let squaredImage = capturedImage.cropImageToSquare()
                                        .resized(to: squaredSize)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.previewImageView.image = squaredImage
            self.previewImageView.isHidden = false
            self.shutterButton.isHidden = true
            self.previewLayerView.isHidden = true
        }
    }
}
