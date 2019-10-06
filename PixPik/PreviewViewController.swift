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
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
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
        
        let croppedImage = pixelizedCIImage.cropped(to: CGRect(
            x: 0,
            y: 0,
            width: ciImage.extent.size.width - CGFloat(integerLiteral: pixelizationLevel.intensity) * 2,
            height: ciImage.extent.size.height - CGFloat(integerLiteral: pixelizationLevel.intensity) * 2
            )
        )
        
        let pixelizedImage = UIImage(ciImage: croppedImage)
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
    
    func shareTapped(in: PreviewView) {
        guard let image = previewView.imageView.image else { return }
        let imageToShare = [image]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.completionWithItemsHandler = { [weak self] (_, isSuccess, _, _) in
            self?.handleShared(isSuccess: isSuccess)
        }

        navigationController?.present(activityViewController, animated: true, completion: nil)
    }
    
    func handleShared(isSuccess: Bool) {
        let alertController = isSuccess ?
            UIAlertController(title: "Success", message: "Photo shared", preferredStyle: .alert) :
            UIAlertController(title: "Fail", message: "There was a problem sharing your image", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }))
        
        navigationController?.present(alertController, animated: true, completion: nil)
    }
    
    func saveTapped(in: PreviewView) {
        guard let image = previewView.imageView.image else { return }
        
        // This image recreation is needed, because if image has ciImage saving will fail without error
        guard let ciImage = image.ciImage else { return }
        guard let cgImage = cgImage(from: ciImage) else { return }
        let newImage = UIImage(cgImage: cgImage)
        
        UIImageWriteToSavedPhotosAlbum(newImage, self, #selector(saved), nil)
    }
    
    func cgImage(from ciImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        return context.createCGImage(ciImage, from: ciImage.extent)
    }
    
    @objc func saved(_ im:UIImage, error:Error?, context:UnsafeMutableRawPointer?) {
        let alertController =
            error == nil ?
            UIAlertController(title: "Success", message: "Photo saved", preferredStyle: .alert) :
            UIAlertController(title: "Fail", message: "There was a problem saving your image", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }))
        
        navigationController?.present(alertController, animated: true, completion: nil)
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
