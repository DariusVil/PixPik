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
    
    @objc private func handleBackTapped() {
        navigationController?.popViewController(animated: true)
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
        guard let pixelizedImage = pixelize(image: image, intensity: pixelizationLevel.intensity) else {
            return
        }
        previewView.update(with: pixelizedImage)
    }
}

extension PreviewViewController: PreviewViewDelegate {
    
    func closeTapped(in: PreviewView) {
        navigationController?.popViewController(animated: true)
    }

    func shareTapped(in: PreviewView) {
        guard let image = previewView.imageView.image else { return }
        let imageToShare = [image]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.completionWithItemsHandler = { [weak self] (_, isSuccess, _, error) in
            self?.handleShared(isSuccess: isSuccess, error: error)
        }

        navigationController?.present(activityViewController, animated: true, completion: nil)
    }
    
    func handleShared(isSuccess: Bool, error: Error?) {
        // Early return of the user just closed the share dialog
        if !isSuccess && error == nil {
            return
        }
        
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
    
    func pixelizationLevelIncreased(in: PreviewView) {
        pixelizationLevel = pixelizationLevel.incrementedValue
        applyFilter()
    }
    
    func pixelizationLevelDecreased(in: PreviewView) {
        pixelizationLevel = pixelizationLevel.decrementedValue
        applyFilter()
    }
    
    private func cgImage(from ciImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        return context.createCGImage(ciImage, from: ciImage.extent)
    }
    
    @objc
    private func saved(_ im:UIImage, error:Error?, context:UnsafeMutableRawPointer?) {
        let alertController: UIAlertController
        
        if error == nil {
            alertController = UIAlertController(title: "Success", message: "Photo saved", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }))
        } else {
           alertController = UIAlertController(title: "Fail", message: "There was a problem saving your image. Please try again", preferredStyle: .alert)
            
           alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        }

        navigationController?.present(alertController, animated: true, completion: nil)
    }
}

extension PreviewViewController: Pixelizeable {}
