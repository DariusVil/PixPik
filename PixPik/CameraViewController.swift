import UIKit

final class CameraViewController: UIViewController {
    
    private var frameExtractor: FrameExtractor?
    
    private var pixelizationLevel: PixelizationLevel = .medium
    
    private var currentImage: UIImage?
    
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
    
    private func pixelize(image: CIImage) -> CIImage? {
        let filter = CIFilter(name:"CIPixellate")
        filter?.setValue(image, forKey: kCIInputImageKey)
        filter?.setValue(pixelizationLevel.intensity, forKey: kCIInputScaleKey)
        return filter?.outputImage
    }
}

extension CameraViewController: FrameExtractorDelegate {
    
    func captured(image: CIImage) {
        guard let pixelizedCImage = pixelize(image: image) else {
            return
        }
        
        let pixelizedImage = UIImage(ciImage: pixelizedCImage)
        
        cameraView.update(with: pixelizedImage)
        currentImage = pixelizedImage
    }
}

extension CameraViewController: CameraViewDelegate {
    
    func pixelizationLevelIncreased(in: CameraView) {
        pixelizationLevel = pixelizationLevel.incrementedValue
    }
    
    func pixelizationLevelDecreased(in: CameraView) {
        pixelizationLevel = pixelizationLevel.decrementedValue
    }

    func shutterTapped(in: CameraView) {
        guard let currentImage = currentImage else { return }
        let previewViewController = PreviewViewController(image: currentImage)
        
        navigationController?.pushViewController(previewViewController, animated: true)
    }
    
    func switchTapped(in: CameraView) {
        
    }
    
    func libraryTapped(in: CameraView) {
        
    }
}
