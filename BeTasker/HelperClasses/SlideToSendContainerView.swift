//
//  SlideToSendContainerView.swift
//  teamAlerts
//
//  Created by MAC on 03/02/25.
//
protocol SlideToSendDelegate:AnyObject {
    func slideToSendDelegateDidFinish(_ sender: SlideToSendContainerView)
}
public class SlideToSendContainerView: UIView {
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var thumnailImageView: UIView!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var draggedView: UIView!
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var trailingDraggedViewConstraint: NSLayoutConstraint?
    @IBOutlet var leadingThumbnailViewConstraint: NSLayoutConstraint?
    
    weak var delegate: SlideToSendDelegate?
    
    private var xPositionInThumbnailView: CGFloat = 0
    public var animationVelocity: Double = 0.2
    
    
    public var thumbnailViewStartingDistance: CGFloat = 8.0 {
        didSet {
            leadingThumbnailViewConstraint?.constant = thumbnailViewStartingDistance
            trailingDraggedViewConstraint?.constant = thumbnailViewStartingDistance
            setNeedsLayout()
        }
    }
    private var xEndingPoint: CGFloat {
        get {
            return (self.bounds.maxX - thumnailImageView.bounds.width - thumbnailViewStartingDistance)
        }
    }
    private var isFinished: Bool = false
    
    private var panGestureRecognizer: UIPanGestureRecognizer!
    
    public var containerBackGroundColor: UIColor = UIColor.colorFFD01E
    {
        didSet {
            self.updateBackGroundColor()
        }
    }
    public var arrowImage: UIImage? = UIImage(named: "double-arrow-yellow")
    {
        didSet {
            self.updateArrowImage()
        }
    }
    var spinner = UIActivityIndicatorView()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        //setupView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        //setupView()
    }
    open override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    func updateBackGroundColor()
    {
        self.backgroundColor = self.containerBackGroundColor
        self.draggedView.backgroundColor = self.containerBackGroundColor
        self.shimmerLayer.colors = [gradientColorOne,gradientColorTwo]
        self.animationView.backgroundColor = self.containerBackGroundColor

    }
    func updateArrowImage()
    {
        self.arrowImageView.image = self.arrowImage
        self.arrowImageView.tintColor = containerBackGroundColor
        self.arrowImageView.isHidden = false
        
    }
    func reseSspinner()
    {
        spinner.removeFromSuperview()
        spinner.stopAnimating()
        self.arrowImageView.isHidden = false
    }
    private func setupView() {
        DispatchQueue.main.async {
            self.thumnailImageView.layer.cornerRadius = self.thumnailImageView.frame.height / 2
            self.layer.cornerRadius = self.frame.height / 2
        }
        
        self.thumnailImageView.applyShadow(radius: 3, opacity: 0.1, offset: CGSize(width: 0.0, height: 3.0))
        print("debug: SlideToSendContainerView.frame = \(self.frame)")
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:)))
        panGestureRecognizer.minimumNumberOfTouches = 1
        thumnailImageView.addGestureRecognizer(panGestureRecognizer)
    }
    func resetSliderView() {
        self.reseSspinner()
        UIView.animate(withDuration: animationVelocity) {
            self.leadingThumbnailViewConstraint?.constant = self.thumbnailViewStartingDistance
            self.textLabel.alpha = 1
            self.isFinished = false
            self.layoutIfNeeded()
        }
    }
    // MARK: UIPanGestureRecognizer
    @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        if isFinished {
            return
        }
        let translatedPoint = sender.translation(in: self).x
        
        switch sender.state {
        case .began:
            break
        case .changed:
            if translatedPoint >= xEndingPoint {
                updateThumbnailXPosition(xEndingPoint)
                return
            }
            if translatedPoint <= thumbnailViewStartingDistance {
                textLabel.alpha = 1
                updateThumbnailXPosition(thumbnailViewStartingDistance)
                return
            }
            updateThumbnailXPosition(translatedPoint)
            let textLabelalpha = (xEndingPoint - translatedPoint) / xEndingPoint
            textLabel.alpha = textLabelalpha
            break
        case .ended:
            if translatedPoint >= xEndingPoint {
                textLabel.alpha = 0
                updateThumbnailXPosition(xEndingPoint)
                // Finish action
                isFinished = true
                addSpinnerOnComplete()
                delegate?.slideToSendDelegateDidFinish(self)
                return
            }
            if translatedPoint <= thumbnailViewStartingDistance {
                textLabel.alpha = 1
                updateThumbnailXPosition(thumbnailViewStartingDistance)
                return
            }
            UIView.animate(withDuration: animationVelocity) {
                self.leadingThumbnailViewConstraint?.constant = self.thumbnailViewStartingDistance
                self.textLabel.alpha = 1
                self.layoutIfNeeded()
            }
            break
        default:
            break
        }
    }
    private func updateThumbnailXPosition(_ x: CGFloat) {
        leadingThumbnailViewConstraint?.constant = x
        setNeedsLayout()
    }
    func addSpinnerOnComplete()
    {
        spinner = UIActivityIndicatorView(style: .medium)
        spinner.frame = self.thumnailImageView.bounds
        spinner.color = self.containerBackGroundColor

        spinner.stopAnimating()
        spinner.removeFromSuperview()
        self.thumnailImageView.addSubview(spinner)
        self.arrowImageView.isHidden = true
        spinner.startAnimating()
    }
    //MARK: Gardient Animation
    var gradientColorOne : CGColor
    {
        get {
            return self.containerBackGroundColor.withAlphaComponent(0.85).cgColor
        }
        
    }
    var gradientColorTwo : CGColor
    {
        get {
            return self.containerBackGroundColor.withAlphaComponent(0.95).cgColor
        }
        
    }
    //        var gradientColorTwo : CGColor = UIColor(white: 0.95, alpha: 1.0).cgColor
    var gradientLayer = CAGradientLayer()
    
//    private lazy var contentLayer: CALayer = {
//        let layer = CALayer()
//        layer.backgroundColor = UIColor.colorFFFFFF000000.cgColor
//        layer.bounds = self.bounds
//        layer.anchorPoint = CGPoint.zero    // 锚点 (0, 0)位置
//        self.layer.addSublayer(layer)
//        layer.mask = self.textLabel.layer
//        return layer
//    }()
    private lazy var contentLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.clear.cgColor
        layer.bounds = self.animationView.bounds
        layer.anchorPoint = CGPoint.zero    // 锚点 (0, 0)位置
        self.layer.addSublayer(layer)
        //layer.mask = self.textLabel.layer
        return layer
    }()
    
    private lazy var shimmerLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.bounds = self.animationView.bounds
        layer.colors = [gradientColorOne,gradientColorTwo]
        layer.anchorPoint = CGPoint.zero
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        self.contentLayer.addSublayer(layer)
        return layer
    }()
    
    func addGradientLayer() -> CAGradientLayer {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.bounds = self.animationView.bounds
        
        gradientLayer.anchorPoint = CGPoint.zero
        
        gradientLayer.startPoint = CGPoint(x: 0.20, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.80, y: 0.5)
        
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
        
        gradientLayer.locations = [0.2, 0.5, 0.8]
        
        contentLayer.addSublayer(gradientLayer)
        
        shimmerLayer.mask = gradientLayer
        
        
        return gradientLayer
    }
    
    func addAnimation() -> CABasicAnimation {
        
        let basicAnimation = CABasicAnimation(keyPath: "locations")
        
        basicAnimation.fromValue = [0.01, 0, 0.2]
        basicAnimation.toValue = [0.8, 1, 1]
        
        basicAnimation.duration = 3.0
        basicAnimation.repeatCount = MAXFLOAT
        basicAnimation.isRemovedOnCompletion = false
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.autoreverses = false
        return basicAnimation
    }
    
    func startAnimating() {
        stopAnimating()
        gradientLayer = addGradientLayer()
        let animation = addAnimation()
        
        gradientLayer.add(animation, forKey: animation.keyPath)
    }
    func stopAnimating()
    {
        gradientLayer.removeAllAnimations()
        gradientLayer.removeFromSuperlayer()
    }
}
