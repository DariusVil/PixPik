import UIKit

class CameraViewController: UIViewController, FrameExtractorDelegate {
    
    var frameExtractor: FrameExtractor!
    var imageView = UIImageView()
    
    let context = CIContext()

    override func viewDidLoad() {
        super.viewDidLoad()
       
        frameExtractor = FrameExtractor()
        frameExtractor.delegate = self

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func sepiaFilter(_ input: CIImage, intensity: Double) -> CIImage?
    {
        let sepiaFilter = CIFilter(name:"CIPixellate")
        sepiaFilter?.setValue(input, forKey: kCIInputImageKey)
        return sepiaFilter?.outputImage
    }
    
    func captured(image: CIImage) {
        let sepiaCIImage = sepiaFilter(image, intensity:0.9)!
        imageView.image = UIImage(ciImage: sepiaCIImage)
    }
}
