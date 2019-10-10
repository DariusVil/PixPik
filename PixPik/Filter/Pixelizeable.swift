import UIKit

protocol Pixelizeable { }

extension Pixelizeable where Self : UIViewController {
        
    func pixelize(image: UIImage, intensity: Int) -> UIImage? {
        guard let ciImage = makeCIImage(from: image) else { return nil }
        return pixelize(ciImage: ciImage, intensity: intensity)
    }
    
    func pixelize(ciImage: CIImage, intensity: Int) -> UIImage? {
        let filter = CIFilter(name:"CIHexagonalPixellate")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(intensity, forKey: kCIInputScaleKey)
        
        guard let pixelizedCIImage = filter?.outputImage else { return nil}
        
        // Cropping is needed because after applying filter the image becomes larger
        let croppedCIImage = pixelizedCIImage.cropped(
            to: CGRect(
                x: 0,
                y: 0,
                width: ciImage.extent.size.width - CGFloat(integerLiteral: intensity) * 2,
                height: ciImage.extent.size.height - CGFloat(integerLiteral: intensity) * 2
            )
        )
        
        return UIImage(ciImage: croppedCIImage)
    }
    
    private func normalizeSize(ciImage: CIImage) {
        
    }
    
    // This solves a problem that image.ciImage will be nil if its created from cgImage
    private func makeCIImage(from image: UIImage) -> CIImage? {
        if let ciImage = image.ciImage {
            return ciImage
        } else {
            return CIImage(image: image)
        }
    }
}
