import UIKit

protocol PreviewViewDelegate: class {
    
    func dismissTapped(in: PreviewView)
    func shareTapped(in: PreviewView)
    func saveTapped(in: PreviewView)
    func pixelizationLevelIncreased(in: PreviewView)
    func pixelizationLevelDecreased(in: PreviewView)
}

final class PreviewView: UIView {
    
    weak var delegate: PreviewViewDelegate?
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var dismissButtonImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "shutter_button"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissTapped))
        imageView.addGestureRecognizer(tapGesture)
        
        return imageView
    }()
    
    private lazy var shareButtonImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "camera_switch_button"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true;
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(shareTapped))
        imageView.addGestureRecognizer(tapGesture)
        
        return imageView
    }()
    
    private lazy var saveButtonImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "library_button"))
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
        addButtons()
        addSwipeGestures()
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
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    private func addButtons() {
        addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(dismissButtonImageView)
        buttonStackView.addArrangedSubview(shareButtonImageView)
        buttonStackView.addArrangedSubview(saveButtonImageView)
        
        NSLayoutConstraint.activate([
            buttonStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            buttonStackView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    @objc func dismissTapped(gesture: UIGestureRecognizer) {
        delegate?.dismissTapped(in: self)
    }
    
    @objc func shareTapped(gesture: UIGestureRecognizer) {
        delegate?.shareTapped(in: self)
    }
    
    @objc func saveTapped(gesture: UIGestureRecognizer) {
        delegate?.saveTapped(in: self)
    }
}
