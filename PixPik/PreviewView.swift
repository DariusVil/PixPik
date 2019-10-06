import UIKit

protocol PreviewViewDelegate: class {
    
    func shareTapped(in: PreviewView)
    func saveTapped(in: PreviewView)
    func pixelizationLevelIncreased(in: PreviewView)
    func pixelizationLevelDecreased(in: PreviewView)
}

final class PreviewView: UIView {
    
    weak var delegate: PreviewViewDelegate?
    
    private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 12
        return imageView
    }()
    
    private lazy var shareButtonImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "appbar.share"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true;
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(shareTapped))
        imageView.addGestureRecognizer(tapGesture)
        
        return imageView
    }()
    
    private lazy var saveButtonImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "appbar.disk"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true;
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(saveTapped))
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
        
        addImageView()
        addTransparentView()
        addButtons()
        addSwipeGestures()
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

    private func addSwipeGestures() {
        let swipeLeftGesture = UISwipeGestureRecognizer(
            target: self,
            action: #selector(handleSwipeGesture)
        )
        swipeLeftGesture.direction = .left
        addGestureRecognizer(swipeLeftGesture)
        
        let swipeRightGesture = UISwipeGestureRecognizer(
            target: self,
            action: #selector(handleSwipeGesture)
        )
        swipeRightGesture.direction = .right
        addGestureRecognizer(swipeRightGesture)
    }

    @objc private func handleSwipeGesture(gesture: UIGestureRecognizer) {
        guard let swipeGesture = gesture as? UISwipeGestureRecognizer else { return }
        
        switch swipeGesture.direction {
        case .right: delegate?.pixelizationLevelIncreased(in: self)
        case .left: delegate?.pixelizationLevelDecreased(in: self)
        default: break
        }
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
        buttonStackView.addArrangedSubview(shareButtonImageView)
        buttonStackView.addArrangedSubview(saveButtonImageView)
        
        NSLayoutConstraint.activate([
            buttonStackView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            buttonStackView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    @objc func shareTapped(gesture: UIGestureRecognizer) {
        delegate?.shareTapped(in: self)
    }
    
    @objc func saveTapped(gesture: UIGestureRecognizer) {
        delegate?.saveTapped(in: self)
    }
}
