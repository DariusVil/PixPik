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
    
    private lazy var imagePicker: UIImagePickerController = {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary
        return pickerController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        showSwipeMessage()
        setupFrameExtractor()
        setupView()
    }
    
    private func showSwipeMessage() {
        if UserDefaults.isFirstLaunch() {
            let alert = UIAlertController(title: "Tip", message: "To change pixelation swipe left or right", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))
            
            navigationController?.present(alert, animated: true, completion: nil)
        }
    }

    private func setupFrameExtractor() {
        frameExtractor = FrameExtractor(position: .back)
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
        let filter = CIFilter(name:"CIHexagonalPixellate")
        filter?.setValue(image, forKey: kCIInputImageKey)
        filter?.setValue(pixelizationLevel.intensity, forKey: kCIInputScaleKey)
        return filter?.outputImage!.cropped(to: CGRect(
            x: 0,
            y: 0,
            width: image.extent.size.width - CGFloat(integerLiteral: pixelizationLevel.intensity) * 2,
            height: image.extent.size.height - CGFloat(integerLiteral: pixelizationLevel.intensity) * 2
            )
        )
    }
    
    private func showPreview(image: UIImage, pixelizationLevel: PixelizationLevel) {
        let previewViewController = PreviewViewController(
            image: image,
            pixelizationLevel: pixelizationLevel
        )
        navigationController?.pushViewController(previewViewController, animated: true)
    }
}

extension CameraViewController: FrameExtractorDelegate {
    
    func captured(image: CIImage) {
        guard let pixelizedCImage = pixelize(image: image) else {
            return
        }
        
        let pixelizedImage = UIImage(ciImage: pixelizedCImage)
        
        cameraView.update(with: pixelizedImage)
        
        currentImage = UIImage(ciImage: image)
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
        showPreview(image: currentImage, pixelizationLevel: pixelizationLevel)
    }
    
    func switchTapped(in: CameraView) {
        guard let currentCameraPosition = frameExtractor?.position else { return }
        
        frameExtractor = FrameExtractor(
            position: currentCameraPosition == .back ? .front : .back
        )
        frameExtractor?.delegate = self
    }
    
    func libraryTapped(in: CameraView) {
        navigationController?.present(imagePicker, animated: true, completion: nil)
    }
}

extension CameraViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        picker.dismiss(animated: true, completion: { [weak self] in
            guard let pixelizationLevel = self?.pixelizationLevel else { return }
            self?.showPreview(image: image, pixelizationLevel: pixelizationLevel)
        })
    }
}

extension CameraViewController: UINavigationControllerDelegate {
    
}
