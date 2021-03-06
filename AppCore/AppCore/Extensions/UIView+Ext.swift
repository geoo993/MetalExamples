
// from : https://stackoverflow.com/questions/30953201/adding-blur-effect-to-background-in-swift
//https://stackoverflow.com/questions/9115854/uiview-hide-show-with-animation
//https://stackoverflow.com/questions/6177393/how-to-add-animation-while-changing-the-hidden-mode-of-a-uiview

import Foundation
import UIKit

private let UIViewVisibilityShowAnimationKey = "UIViewVisibilityShowAnimationKey"
private let UIViewVisibilityHideAnimationKey = "UIViewVisibilityHideAnimationKey"

private class UIViewAnimationDelegate: NSObject, CAAnimationDelegate {
    weak var view: UIView?
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        guard let view = self.view, flag else {
            return
        }
        view.isHidden = !view.visible
        view.removeVisibilityAnimations()
    }
}

public protocol ViewCopyable {
    func copyView<Self: UIView>() -> Self
}

extension ViewCopyable where Self: UIView {
    /// Copy a subclass of UIView using NSKeyedArchiver.
    public func copyView<T: UIView>() -> T {
        let view = (self as? T)!
        let archived = NSKeyedArchiver.archivedData(withRootObject: view)
        let copy = NSKeyedUnarchiver.unarchiveObject(with: archived) as? T
        return copy!
    }
}

extension UIView: ViewCopyable {}

public extension UIView {
    
    public func addConstraints(with format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
    public func addCenterConstraints(with view: UIView) {
        addConstraint(NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    func copyView<T: UIView>() -> T {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as! T
    }

    public static func createPickerViewItem(with frame : CGRect, text: String) -> UIView {
        
        let view = UIView(frame: frame )
        
        let label = UILabel(frame: view.frame)
        label.text = text
        label.textAlignment = .center
        label.contentMode = .center
        label.font = UIFont.systemFont(ofSize: 24)
        view.addSubview(label)
        
        return view
    }
    
    
    public func shakeView(repeatCount: Float){
        
        let view = self
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            //view.isHidden = true
        })
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = repeatCount
        shake.autoreverses = true
        
        let from_point = CGPoint(x: view.center.x - 5, y: view.center.y)
        let from_value : NSValue = NSValue(cgPoint: from_point)
        
        let to_point = CGPoint(x: view.center.x + 5, y:view.center.y)
        let to_value : NSValue = NSValue(cgPoint: to_point)
        
        shake.fromValue = from_value
        shake.toValue = to_value
        view.layer.add(shake, forKey: "position")
        
        //shake.delegate = self
        
        CATransaction.commit()
    }
    
    public func snapShotImage(withSize size: CGSize, opaque: Bool = false, offset :CGPoint = CGPoint.zero) -> UIImage {
        
        ///size, opaque, scale
        //UIGraphicsBeginImageContextWithOptions(size, false, 1)
        
        if UIScreen.main.responds(to: #selector(NSDecimalNumberBehaviors.scale)){
            UIGraphicsBeginImageContextWithOptions(size, opaque, UIScreen.main.scale);
        }
        else
        {
            UIGraphicsBeginImageContext(size);
        }
        
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
        context.translateBy(x: -offset.x, y: -offset.y)
        
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image ?? UIImage()
    }
    
    ///takes anyview and creates an image from it using its frame
    public func bluredImage(radius:CGFloat = 1) -> UIImage {
        
        if self.superview == nil
        {
            return UIImage()
        }
        
        let image = self.snapShotImage(withSize: self.frame.size)
        
        guard let source = image.cgImage else { return UIImage() }
        
        let context = CIContext(options: nil)
        let inputImage = CIImage(cgImage: source)
        
        let clampFilter = CIFilter(name: "CIAffineClamp")
        clampFilter?.setDefaults()
        clampFilter?.setValue(inputImage, forKey: kCIInputImageKey)
        
        if let clampedImage = clampFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
            let explosureFilter = CIFilter(name: "CIExposureAdjust")
            explosureFilter?.setValue(clampedImage, forKey: kCIInputImageKey)
            explosureFilter?.setValue(-1.0, forKey: kCIInputEVKey)
            
            if let explosureImage = explosureFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
                let filter = CIFilter(name: "CIGaussianBlur")
                filter?.setValue(explosureImage, forKey: kCIInputImageKey)
                filter?.setValue("\(radius)", forKey:kCIInputRadiusKey)
                
                if let resultImage = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
                    let imageWidth = inputImage.extent.size.width
                    let imageHeight = inputImage.extent.size.height 
                    let boundingRect = CGRect(x:0, y:0, width:imageWidth, height: imageHeight)
                    guard let cgImage = context.createCGImage(resultImage, from: boundingRect) else { return UIImage() }
                    let filteredImage = UIImage(cgImage: cgImage)
                    return filteredImage
                }
            }
            
        }
        
        return UIImage()
    }
    
    public func applyBlurWithCrop(radius:CGFloat = 1, cropBy:CGFloat = 1) -> UIImage {
        
        if self.superview == nil
        {
            return UIImage()
        }
        
        let image = self.snapShotImage(withSize: self.frame.size)
        
        /// convert UIImage to CIImage
        let inputImage = CIImage(image: image)
        
        // Create Blur CIFilter, and set the input image
        let blurfilter = CIFilter(name: "CIGaussianBlur")
        blurfilter?.setValue(inputImage, forKey: kCIInputImageKey)
        blurfilter?.setValue(radius, forKey: kCIInputRadiusKey)
        
         // Get the filtered output image and return it
        if let resultImage = blurfilter?.value(forKey: kCIOutputImageKey) as? CIImage, 
            let imageWidth = inputImage?.extent.size.width ,
            let imageHeight = inputImage?.extent.size.height {
            var blurredImage = UIImage(ciImage: resultImage)
            
            let half = CGFloat(2)
            let xPos = -(cropBy/half)
            let yPos = -(cropBy/half)
            let boundingRect = CGRect(x: xPos, y:yPos, width:imageWidth + cropBy, height: imageHeight + cropBy)
            let cropped:CIImage = resultImage.cropped(to: boundingRect)
            blurredImage = UIImage(ciImage: cropped)
            return blurredImage
            
        }else { return UIImage() }
    }
    
    
    public func blurNewView(newChild: UIView, effect: UIBlurEffect.Style){
        let parent = self
        
        // Blur Effect
        let blurEffect = UIBlurEffect(style: effect)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = parent.bounds
        parent.addSubview(blurEffectView)
        
        // Vibrancy Effect
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyEffectView.frame = parent.bounds
        
        // Add label to the vibrancy view
        vibrancyEffectView.contentView.addSubview(newChild)
        
        // Add the vibrancy view to the blur view
        blurEffectView.contentView.addSubview(vibrancyEffectView)
    }
    
    func addBlurEffectToTopView() {
        // Add blur view
        let view = self
        
        //This will let visualEffectView to work perfectly
        if let navBar = view as? UINavigationBar{
            navBar.setBackgroundImage(UIImage(), for: .default)
            navBar.shadowImage = UIImage()
        }
        
        var bounds = view.bounds
        bounds.offsetBy(dx: 0.0, dy: -20.0)
        bounds.size.height = bounds.height + 20.0
        
        let blurEffect = UIBlurEffect(style: .dark)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        
        visualEffectView.isUserInteractionEnabled = false
        visualEffectView.frame = bounds
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(visualEffectView, at: 0)
        
    }
    
    public func addDropShadowWithGlowLayer(
        backgroungColor: UIColor = UIColor.clear,
        shadowColor: CGColor = UIColor.yellow.cgColor,
        shadowOffset: CGSize = CGSize.zero,
        shadowOpacity: Float = 0.8,
        shadowRadius: CGFloat = 15.0) {
        
        let sublayer = CALayer()
        sublayer.backgroundColor = backgroungColor.cgColor
        sublayer.shadowColor = shadowColor
        sublayer.shadowOffset = shadowOffset
        sublayer.shadowOpacity = shadowOpacity
        sublayer.shadowRadius = shadowRadius
        sublayer.frame = self.frame
        sublayer.borderColor = shadowColor
        sublayer.borderWidth = 2.0
        //sublayer.cornerRadius = 10.0
        
        self.layer.insertSublayer(sublayer, at: 0)
    }
    
    public func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.frame = self.layer.bounds
        mask.path = path.cgPath
        self.layer.mask = mask
        //https://stackoverflow.com/questions/10167266/how-to-set-cornerradius-for-only-top-left-and-top-right-corner-of-a-uiview
        
    }

    public func addBorder(mask: CAShapeLayer, 
                          borderColor: UIColor?, 
                          borderWidth: CGFloat) {
        let borderLayer = CAShapeLayer()
        borderLayer.path = mask.path
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = borderColor?.cgColor
        borderLayer.lineWidth = borderWidth
        borderLayer.frame = bounds
        layer.addSublayer(borderLayer)
    }
    
    public func addBorder(borderColor: UIColor? = .black, 
                          borderWidth: CGFloat = 1.0, 
                          cornerRadius: CGFloat = 10.0) {
        
        layer.borderColor = borderColor?.cgColor
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
        
    }
    
    public func addShadow(with color : UIColor = UIColor.black,
                          width:CGFloat = 0.2,
                          height:CGFloat = 0.2,
                          opacity:Float = 0.7,
                          radius:CGFloat = 0.5,
                          maskToBounds:Bool = false
        ) {
        
        layer.shadowColor = color.cgColor
        layer.shadowOffset = CGSize(width: width, height: height)
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.masksToBounds = maskToBounds
    }
    
    func addDashedBorder(with color: UIColor, lineWidth: CGFloat = 2) {
        // https://stackoverflow.com/questions/13679923/dashed-line-border-around-uiview
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = [6,3]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 5).cgPath
        
        self.layer.addSublayer(shapeLayer)
    }
    func addDashedLine(color: UIColor = .lightGray, lineWidth: CGFloat = 1) {
        // https://stackoverflow.com/questions/12091916/uiview-with-a-dashed-line
        _ = layer
            .sublayers?
            .filter({ $0.name == "DashedTopLine" })
            .map({ $0.removeFromSuperlayer() })
        
        backgroundColor = .clear
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.name = "DashedTopLine"
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = [4, 4]
        
        let path = CGMutablePath()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: frame.width, y: 0))
        shapeLayer.path = path
        
        layer.addSublayer(shapeLayer)
    }
    
    public func fadeIn(_ duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)  }
    
    public func fadeOut(_ duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
    
    // Recursive remove subviews and constraints
    public func removeSubviews() {
        self.subviews.forEach({
            if !($0 is UILayoutSupport) {
                $0.removeSubviews()
                $0.removeFromSuperview()
            }
        })
        
    }
    
    ///tempView = UIView()
    ///originalView.copyViewElements(to: tempView)
    func copyViewElements(to view : UIView){
        for subView in self.subviews{
            let subViewCopy = UIView()
            subView.copyViewElements(to: subViewCopy)
            view.addSubview(subViewCopy.copyView())
            view.addConstraints(subViewCopy.constraints)
        }
    }
    
    // Recursive remove subviews and constraints
    public func removeSubviewsAndConstraints() {
        self.subviews.forEach({
            $0.removeSubviewsAndConstraints()
            $0.removeConstraints($0.constraints)
            $0.removeFromSuperview()
        })
    }

    public func removeNestedSubviewsAndConstraints(){
        while(self.subviews.count > 0)
        {
            self.removeSubviewsAndConstraints()
        }
    }


    /**
     Removes all constrains for this view
     */
    func removeConstraints() {
        
        let constraints = self.superview?.constraints.filter{
            $0.firstItem as? UIView == self || $0.secondItem as? UIView == self
            } ?? []
        
        self.superview?.removeConstraints(constraints)
        self.removeConstraints(self.constraints)
    }


    /// Removes all constrains for this view
    public func removeViewConstraints() {
        var topView: UIView? = self
        repeat {
            var list = [NSLayoutConstraint]()
            for c in topView?.constraints ?? [] {
                if c.firstItem as? UIView == self || c.secondItem as? UIView == self {
                    list.append(c)
                }
            }
            topView?.removeConstraints(list)
            topView = topView?.superview

        } while topView != nil

        translatesAutoresizingMaskIntoConstraints = true
    }

    func removeSubview<T>(with type : T.Type){
        for subview in self.subviews {
            if (subview is T) {
                subview.removeNestedSubviewsAndConstraints()
                subview.removeFromSuperview()
            }
        }
    }
    
    func removeSubview(with view : UIView){
        for subview in self.subviews {
            if (subview == view) {
                subview.removeNestedSubviewsAndConstraints()
                subview.removeFromSuperview()
            }
        }
    }
    
    
    func removeVisibilityAnimations() {
        self.layer.removeAnimation(forKey: UIViewVisibilityShowAnimationKey)
        self.layer.removeAnimation(forKey: UIViewVisibilityHideAnimationKey)
    }
    
    var visible: Bool {
        get {
            return !self.isHidden && self.layer.animation(forKey: UIViewVisibilityHideAnimationKey) == nil
        }
        
        set {
            let visible = newValue
            
            guard self.visible != visible else {
                return
            }
            
            let animated = UIView.areAnimationsEnabled
            
            self.removeVisibilityAnimations()
            
            guard animated else {
                self.isHidden = !visible
                return
            }
            
            self.isHidden = false
            
            let delegate = UIViewAnimationDelegate()
            delegate.view = self
            
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = visible ? 0.0 : 1.0
            animation.toValue = visible ? 1.0 : 0.0
            animation.fillMode = CAMediaTimingFillMode.forwards
            animation.isRemovedOnCompletion = false
            animation.delegate = delegate
            
            self.layer.add(animation, forKey: visible ? UIViewVisibilityShowAnimationKey : UIViewVisibilityHideAnimationKey)
        }
    }
    
    func setVisible(visible: Bool, animated: Bool) {
        let wereAnimationsEnabled = UIView.areAnimationsEnabled
        
        if wereAnimationsEnabled != animated {
            UIView.setAnimationsEnabled(animated)
            defer { UIView.setAnimationsEnabled(!animated) }
        }
        
        self.visible = visible
    }
    
    
    func setHidden(with hidden: Bool, animated:Bool)
    {
        // If the hidden value is already set, do nothing
        if (hidden == self.isHidden) {
            return
        }
        // If no animation requested, do the normal setHidden method
        else if (animated == false) {
            self.isHidden = hidden // self.setHidden(with: hidden)
            return
        }
        else {
            // Store the view's current alpha value
            let originalAlpha = self.alpha
        
            // If we're unhiding the view, make it invisible initially
            if (hidden == false) {
                self.alpha = 0
            }
    
            // Unhide the view so we can see the animation
            self.isHidden = false
    
            // Do the animation
            UIView.animate(withDuration: 0.5,
                           delay: 0.0,
                           options: UIView.AnimationOptions.curveEaseOut,
                           animations: { [weak self] () -> Void in
                            // Start animation block
                            if (hidden == true) {
                                self?.alpha = 0
                            }else {
                                self?.alpha = originalAlpha;
                            }
                            self?.layoutIfNeeded()
                            // End animation block
            }, completion: { [weak self] (completed) -> Void in
                // Start completion block
                // Finish up by hiding the view if necessary...
                self?.isHidden = hidden
                // ... and putting back the correct alpha value
                self?.alpha = originalAlpha;
                // End completion block
            })
        }
        
    }
    
    /// The top coordinate of the UIView.
    public var top: CGFloat {
        get {
            return frame.top
        }
        set(value) {
            var frame = self.frame
            frame.top = value
            self.frame = frame
        }
    }
    /// The left coordinate of the UIView.
    public var left: CGFloat {
        get {
            return frame.left
        }
        set(value) {
            var frame = self.frame
            frame.left = value
            self.frame = frame
        }
    }
    /// The bottom coordinate of the UIView.
    public var bottom: CGFloat {
        get {
            return frame.bottom
        }
        set(value) {
            var frame = self.frame
            frame.bottom = value
            self.frame = frame
        }
    }
    /// The right coordinate of the UIView.
    public var right: CGFloat {
        get {
            return frame.right
        }
        set(value) {
            var frame = self.frame
            frame.right = value
            self.frame = frame
        }
    }
    // The width of the UIView.
    public var width: CGFloat {
        get {
            return frame.width
        }
        set(value) {
            var frame = self.frame
            frame.size.width = value
            self.frame = frame
        }
    }
    // The height of the UIView.
    public var height: CGFloat {
        get {
            return frame.height
        }
        set(value) {
            var frame = self.frame
            frame.size.height = value
            self.frame = frame
        }
    }
    /// The horizontal center coordinate of the UIView.
    public var centerX: CGFloat {
        get {
            return frame.centerX
        }
        set(value) {
            var frame = self.frame
            frame.centerX = value
            self.frame = frame
        }
    }
    /// The vertical center coordinate of the UIView.
    public var centerY: CGFloat {
        get {
            return frame.centerY
        }
        set(value) {
            var frame = self.frame
            frame.centerY = value
            self.frame = frame
        }
    }
    
}
