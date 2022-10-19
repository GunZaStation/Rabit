import AVFoundation
import UIKit

final class CameraManager: NSObject {
    
    private let capturingSessinoQueue = DispatchQueue(label: "CapturingSessionQueue", qos: .background)
    private let capturingSession: AVCaptureSession = AVCaptureSession()
    private var capturingInput: AVCaptureDeviceInput?
    private let capturingOutput = AVCapturePhotoOutput()
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: capturingSession)

    private var completionHandler: ((Data) -> Void)?
    
    func prepareCapturing(with previewLayerView: UIView) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.setPreviewLayer(with: previewLayerView)
            
            self.capturingSessinoQueue.async {
                self.setupCapturingSession()
                self.capturingSession.startRunning()
            }
        }
    }
    
    func capture(completionHandler: @escaping (Data) -> Void) {
        capturingOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        self.completionHandler = completionHandler
    }
    
    func endCapturing() {
        capturingSession.stopRunning()
    }

    deinit {
        if capturingSession.isRunning {
           endCapturing()
        }
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let originalImageData = photo.fileDataRepresentation() {
            completionHandler?(originalImageData)
        }
    }
}

private extension CameraManager {
    
    //device input setup
    func setupInputDevice() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        let input = try? AVCaptureDeviceInput(device: device)
        self.capturingInput = input
    }
    
    //session configuration
    func setupCapturingSession() {
        capturingSession.beginConfiguration()
        setupInputDevice()
        guard let capturingInput = capturingInput else { return }
        
        capturingSession.sessionPreset = .photo
        if capturingSession.canAddInput(capturingInput) {
            capturingSession.addInput(capturingInput)
        }
        
        if capturingSession.canAddOutput(capturingOutput) {
            capturingSession.addOutput(capturingOutput)
        }
        
        previewLayer.connection?.videoOrientation = .portrait
        
        capturingSession.commitConfiguration()
    }
    
    //preview layer setup
    func setPreviewLayer(with previewLayerView: UIView) {
        previewLayer.frame = previewLayerView.bounds
        previewLayerView.layer.addSublayer(previewLayer)
        previewLayer.videoGravity = .resizeAspectFill
    }
}

