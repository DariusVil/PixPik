import UIKit

protocol CameraViewDelegate: class {
    
    func shutterTapped(in: CameraView)
    func switchTapped(in: CameraView)
    func libraryTapped(in: CameraView)
    func pixelizationLevelIncreased(in: CameraView)
    func pixelizationLevelDecreased(in: CameraView)
}

final class CameraView: UIView {
    
    weak var delegate: CameraViewDelegate?
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var shutterButtonImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "shutter_button"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(shutterTapped))
        imageView.addGestureRecognizer(tapGesture)
        
        return imageView
    }()
    
    private lazy var cameraSwitchButtonImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "camera_switch_button"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true;
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(switchTapped))
        imageView.addGestureRecognizer(tapGesture)
        
        return imageView
    }()
    
    private lazy var libraryButtonImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "library_button"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true;
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(libraryTapped))
        imageView.addGestureRecognizer(tapGesture)
        
        return imageView
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.contentMode = .scaleAspectFit
        stackView.axis = .horizontal
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with image: UIImage) {
        imageView.image = image
    }
    
    private func setup() {
        setupSwipeGestures()
        addImageView()
        addButtons()
    }
    
    private func setupSwipeGestures() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGestures))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        addGestureRecognizer(swipeRight)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGestures))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        addGestureRecognizer(swipeLeft)
    }
    
    private func addImageView() {
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    private func addButtons() {
        addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(libraryButtonImageView)
        buttonStackView.addArrangedSubview(shutterButtonImageView)
        buttonStackView.addArrangedSubview(cameraSwitchButtonImageView)
        
        NSLayoutConstraint.activate([
            buttonStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            buttonStackView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    @objc func shutterTapped(gesture: UIGestureRecognizer) {
        delegate?.shutterTapped(in: self)
    }
    
    @objc func switchTapped(gesture: UIGestureRecognizer) {
        delegate?.switchTapped(in: self)
    }
    
    @objc func libraryTapped(gesture: UIGestureRecognizer) {
        delegate?.libraryTapped(in: self)
    }
    
    @objc func respondToSwipeGestures(gesture: UIGestureRecognizer)
    {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer
        {
            switch swipeGesture.direction
            {
            case UISwipeGestureRecognizer.Direction.right:
                delegate?.pixelizationLevelIncreased(in: self)
            case UISwipeGestureRecognizer.Direction.left:
                delegate?.pixelizationLevelDecreased(in: self)
            default: break
            }
        }
    }
}
