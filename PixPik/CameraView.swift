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
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 12
        return imageView
    }()
    
    private lazy var shutterButtonImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "appbar.location.circle"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(shutterTapped))
        imageView.addGestureRecognizer(tapGesture)
        
        return imageView
    }()
    
    private lazy var cameraSwitchButtonImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "appbar.camera.switch"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true;
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(switchTapped))
        imageView.addGestureRecognizer(tapGesture)
        
        return imageView
    }()
    
    private lazy var libraryButtonImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "appbar.image.gallery"))
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
    
    private lazy var transparentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(displayP3Red: 0, green: 0, blue: 0, alpha: 0.4)
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.layer.maskedCorners = [ .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return view
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
        backgroundColor = .black
        
        setupSwipeGestures()
        addImageView()
        addTransparentView()
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
    
    private func addTransparentView() {
        addSubview(transparentView)
        
        NSLayoutConstraint.activate([
            transparentView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            transparentView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            transparentView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            transparentView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func addImageView() {
        addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            imageView.widthAnchor.constraint(equalTo: widthAnchor),
            imageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 4/3)
        ])
    }
    
    private func addButtons() {
        addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(libraryButtonImageView)
        buttonStackView.addArrangedSubview(shutterButtonImageView)
        buttonStackView.addArrangedSubview(cameraSwitchButtonImageView)
        
        NSLayoutConstraint.activate([
            buttonStackView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            buttonStackView.heightAnchor.constraint(equalToConstant: 100)
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
