import UIKit

final class PreviewViewController: UIViewController {
    
    private let image: UIImage
    
    private var pixelizationLevel: PixelizationLevel = .medium
    
    private lazy var previewView: PreviewView = {
        let view = PreviewView ()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(image: UIImage, pixelizationLevel: PixelizationLevel) {
        self.image = image
        self.pixelizationLevel = pixelizationLevel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        view.addSubview(previewView)
        
        NSLayoutConstraint.activate([
            previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewView.topAnchor.constraint(equalTo: view.topAnchor),
            previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        applyFilter()
    }
    
    private func applyFilter() {
        guard let ciImage = makeCIImage(from: image) else {
            return
        }
        
        let filter = CIFilter(name:"CIPixellate")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(pixelizationLevel.intensity, forKey: kCIInputScaleKey)
        guard let pixelizedCIImage = filter?.outputImage else { return }
        let pixelizedImage = UIImage(ciImage: pixelizedCIImage)
        previewView.update(with: pixelizedImage)
    }
    
    private func makeCIImage(from image: UIImage) -> CIImage? {
        if let ciImage = image.ciImage {
            return ciImage
        } else {
            return CIImage(image: image)
        }
    }
}

extension PreviewViewController: PreviewViewDelegate {
    
    func dismissTapped(in: PreviewView) {
    }
    
    func shareTapped(in: PreviewView) {
    }
    
    func saveTapped(in: PreviewView) {
    }
    
    func pixelizationLevelIncreased(in: PreviewView) {
        pixelizationLevel = pixelizationLevel.incrementedValue
        applyFilter()
    }
    
    func pixelizationLevelDecreased(in: PreviewView) {
        pixelizationLevel = pixelizationLevel.decrementedValue
        applyFilter()
    }
}
