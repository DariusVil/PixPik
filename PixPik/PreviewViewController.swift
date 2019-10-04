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
    
    init(image: UIImage) {
        self.image = image
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
        
        previewView.update(with: image)
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
    }
    
    func pixelizationLevelDecreased(in: PreviewView) {
        pixelizationLevel = pixelizationLevel.decrementedValue
    }
}
