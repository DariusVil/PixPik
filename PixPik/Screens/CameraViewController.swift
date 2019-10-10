import UIKit

final class CameraViewController: UIViewController {
    
    private var frameCaptureManager: FrameCaptureManager?
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
        frameCaptureManager = FrameCaptureManager(position: .back)
        frameCaptureManager?.delegate = self
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
    
    private func showPreview(image: UIImage, pixelizationLevel: PixelizationLevel) {
        let previewViewController = PreviewViewController(
            image: image,
            pixelizationLevel: pixelizationLevel
        )
        navigationController?.pushViewController(previewViewController, animated: true)
    }
}

extension CameraViewController: FrameCaptureManagerDelegate {
    
    func captured(image: CIImage) {
        guard let pixelizedImage = pixelize(ciImage: image, intensity: pixelizationLevel.intensity) else {
            return
        }
        
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
        showPreview(image: currentImage, pixelizationLevel: pixelizationLevel)
    }
    
    func switchTapped(in: CameraView) {
        guard let currentCameraPosition = frameCaptureManager?.position else { return }
        
        frameCaptureManager = FrameCaptureManager(
            position: currentCameraPosition == .back ? .front : .back
        )
        frameCaptureManager?.delegate = self
    }
    
    func libraryTapped(in: CameraView) {
        navigationController?.present(imagePicker, animated: true, completion: nil)
    }
}

extension CameraViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        let normalizedImage = fixOrientation(image: image)
        picker.dismiss(animated: true, completion: { [weak self] in
            guard let pixelizationLevel = self?.pixelizationLevel else { return }
            self?.showPreview(image: normalizedImage, pixelizationLevel: pixelizationLevel)
        })
    }
    
    // Needed because
    private func fixOrientation(image: UIImage) -> UIImage {
        if image.imageOrientation == .up {
            return image
        }

        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        let rect = CGRect(
            x: 0,
            y: 0,
            width: image.size.width,
            height: image.size.height
        )
        image.draw(in: rect)

        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return normalizedImage
    }
}

// Needed for UIImagePickerControllerDelegate
extension CameraViewController: UINavigationControllerDelegate { }
extension CameraViewController: Pixelizeable {}
