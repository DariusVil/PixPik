import UIKit

final class CameraViewController: UIViewController {
    
    private var frameExtractor: FrameExtractor?
    
    private lazy var cameraView: CameraView = {
        let view = CameraView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFrameExtractor()
        setupView()
    }
    
    private func setupFrameExtractor() {
        frameExtractor = FrameExtractor()
        frameExtractor?.delegate = self
    }
    
    private func setupView() {
        view.addSubview(cameraView)
        
        NSLayoutConstraint.activate([
            cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cameraView.topAnchor.constraint(equalTo: view.topAnchor),
            cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func pixelize(image: CIImage, intensity: Double) -> CIImage? {
        let filter = CIFilter(name:"CIPixellate")
        filter?.setValue(image, forKey: kCIInputImageKey)
        filter?.setValue(50, forKey: kCIInputScaleKey)
        return filter?.outputImage
    }
}

extension CameraViewController: FrameExtractorDelegate {
    
    func captured(image: CIImage) {
        guard let pixelizedCImage = pixelize(image: image, intensity:5) else {
            return
        }
        
        let pixelizedImage = UIImage(ciImage: pixelizedCImage)
        
        cameraView.update(with: pixelizedImage)
    }
}

extension CameraViewController: CameraViewDelegate {
    
    func shutterTapped(in: CameraView) {
        
    }
    
    func switchTapped(in: CameraView) {
        
    }
    
    func libraryTapped(in: CameraView) {
        
    }
}
