//
//  SlideToUnlockButtonView.swift
//  teamAlerts
//
//  Created by MAC on 03/02/25.
//

import UIKit


/// locations: 分割动画
private let gradientViewAnimationKey = "locations"

/// 滑动来解锁视图
open class SlideToUnlockButtonView: UIView {
    
    // MARK: - Private Attribute
    /// 文本标签
    private lazy var textLabel = UILabel()

    /// 渐变图层
    private lazy var gradientLayer = CAGradientLayer()
    
    /// 内容图层
    private lazy var contentLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = self.textColor.cgColor
        layer.bounds = self.bounds
        layer.anchorPoint = CGPoint.zero    // 锚点 (0, 0)位置
        self.layer.addSublayer(layer)
        layer.mask = self.textLabel.layer
        return layer
    }()
    
    /// 闪烁图层
    private lazy var shimmerLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.bounds = self.bounds
        layer.colors = self.shimmerColors.map({ $0.cgColor })
        layer.anchorPoint = CGPoint.zero
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        self.contentLayer.addSublayer(layer)
        return layer
    }()
    
    
    // MARK: - Public Attribute
    
    /// 是否开启往返动画
    public var isEnableAutoreverses: Bool = false
    
    /// 文字
    public var textStr: String = "" {
        didSet {
            textLabel.text = textStr
        }
    }

    /// 持续时长
    public var duration: TimeInterval = 2.0 {
        didSet {
        }
    }
    
    /// 动画方向
    public var animationDirection = AnimationDirection.horizontal {
        didSet{                     // 监听数值animationDirection的改变
            switch animationDirection {
            case .horizontal:
                gradientLayer.startPoint = CGPoint(x:0, y:0.5);
                gradientLayer.endPoint = CGPoint(x:1.0, y:0.5);
            case .vertical:
                gradientLayer.startPoint = CGPoint(x:0.5, y:0);
                gradientLayer.endPoint = CGPoint(x:0.5, y:1.0);
            case .diagonalUp:
                gradientLayer.startPoint = CGPoint(x:0, y:1.0);
                gradientLayer.endPoint = CGPoint(x:1.0, y:0.0);
            case .diagonalDown:
                gradientLayer.startPoint = CGPoint(x:0, y:0.0);
                gradientLayer.endPoint = CGPoint(x:1.0, y:1.0);
            }
        }
    }
    
    /// 渐变图片 (跟`colors`只能设置一个)
    public var shimmerImage = UIImage(named: "gradient") {
        didSet{
            shimmerLayer.colors = nil
            shimmerLayer.contents = shimmerImage?.cgImage
        }
    }
    
    /// 渐变颜色组 (最少两个元素, 跟 `shimmerImage` 只能设置一个)
    public var shimmerColors = [UIColor.white, UIColor.white] {
        didSet {
            shimmerLayer.contents = nil
            shimmerLayer.colors = shimmerColors.map({ $0.cgColor })
        }
    }
 
    /// 文字颜色
    public var textColor = UIColor.black {
        didSet {
            contentLayer.backgroundColor = textColor.cgColor
        }
    }
    
    /// 字体
    public var font: UIFont = UIFont.systemFont(ofSize: 13) {
        didSet {
            textLabel.font = font
        }
    }
    
    // MARK: - Init Method
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    open override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    required public init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        commonInit()
    }
    func commonInit()
    {
        configLabel()
        configGradientLayer()
    }
}

// MARK: - Private Method
extension SlideToUnlockButtonView {
    
    /// 创建UILabel
    private func configLabel() {
        textLabel = UILabel(frame: bounds)
        textLabel.text = textStr
        textLabel.textAlignment = .center
        addSubview(textLabel)
    }
    
    private func configGradientLayer() {

        gradientLayer.bounds = bounds
        
        gradientLayer.anchorPoint = CGPoint.zero
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)

        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]

        gradientLayer.locations = [0.2, 0.5, 0.8]
        
        contentLayer.addSublayer(gradientLayer)
        
        shimmerLayer.mask = gradientLayer
        
        configAnimation()
    }
    
    /// 配置动画
    private func configAnimation() {
        
        // 1> 创建基于CAlayer层的动画, 通过 "locations" 创建UIView动画
        // locations: 分割动画
        let basicAnimation = CABasicAnimation(keyPath: gradientViewAnimationKey)
        
        // 2> 设置动画相关属性
        // fromValue: 动画当前值
        // toValue: 动画目标值
        basicAnimation.fromValue = [0, 0, 0.2]
        basicAnimation.toValue = [0.8, 1, 1]
        
        // 动画的持续时间
        basicAnimation.duration = duration
        // 动画的重复次数
        basicAnimation.repeatCount = MAXFLOAT
        // 完成后是否删除动画
        basicAnimation.isRemovedOnCompletion = false
        // 动画的填充模式, 返回到原点
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        // autoreverses: 属性会自动将动画恢复
        basicAnimation.autoreverses = isEnableAutoreverses ? true : false
        
        // 3> 添加动画
        gradientLayer.add(basicAnimation, forKey: nil)
    }
    
}

// MARK: - Public Method
extension SlideToUnlockButtonView {
    
    /// 显示淡影淡出效果
    ///
    /// - Parameter du: 持续时长
    public func showFadeWithDuration(_ du: TimeInterval) {
        duration = du
        gradientLayer.removeAllAnimations() // 移除动画,再添加
        configAnimation()
    }
}
public enum AnimationDirection {
    /// 水平
    case horizontal
    /// 垂直
    case vertical
    /// 对角线往上
    case diagonalUp
    /// 对角线往下
    case diagonalDown
}
