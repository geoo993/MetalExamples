
import Foundation
import UIKit

//@IBDesignable 
public extension UINavigationController {
    /*
    @IBInspectable var barTintColor: UIColor? {
        set {
            navigationBar.barTintColor = newValue
        }
        get {
            guard  let color = navigationBar.barTintColor else { return nil }
            return color
        }
    }
    
    @IBInspectable var tintColor: UIColor? {
        set {
            navigationBar.tintColor = newValue
        }
        get {
            guard  let color = navigationBar.tintColor else { return nil }
            return color
        }
    }
    
    @IBInspectable var titleColor: UIColor? {
        set {
            guard let color = newValue else { return }
            navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: color]
        }
        get {
            return navigationBar.titleTextAttributes?[NSAttributedStringKey.foregroundColor] as? UIColor
        }
    }
    
    @IBInspectable var largeTitleColor: UIColor? {
        set {
            guard let color = newValue else { return }
            navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: color]
        }
        get {
            return navigationBar.largeTitleTextAttributes?[NSAttributedStringKey.foregroundColor] as? UIColor
        }
    }
    */
    public var rootViewControllerInNavigationStack : UIViewController? {
        return viewControllers.first 
    }
    
    public func previousViewControllerInNavigationStack() -> UIViewController? {
        guard let _ = self.navigationController else {
            return nil
        }
        
        guard let viewControllers = self.navigationController?.viewControllers else {
            return nil
        }
        
        guard viewControllers.count >= 2 else {
            return nil
        }        
        return viewControllers[viewControllers.count - 2]
    }
    
    
    public func setRootViewController (_ vc : UIViewController) {
        popToRootViewController(animated: false)
        setViewControllers([vc], animated: true)
    }
    
    public func push(viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
    
    public func pop(animated: Bool, completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        popViewController(animated: animated)
        CATransaction.commit()
    }
    
    public func popNavigationStack<T : UIViewController>(to target: T.Type, animated: Bool = true) {
        let popToTargetVC : () -> Void = {
            
            while !(self.topViewController is T) {
                self.popViewController(animated: false)
                if self.viewControllers.first == self.topViewController {
                    break
                }
            }
        }
        
        if self.topViewController?.presentedViewController != nil {
            self.topViewController?.dismiss(animated: animated, completion: {
                popToTargetVC()
            })
        } else {
            popToTargetVC()
        }
    }
    
    private func callCompletion(animated: Bool, completion: @escaping () -> Void) {
        if animated, let coordinator = self.transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }
    
    func popTo(viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
        self.popToViewController(viewController, animated: animated)
        self.callCompletion(animated: animated, completion: completion)
    }
    
    // Pop to specific view controller
    public func pop<T : UIViewController>(to target: T.Type, animated: Bool = true) {
        for aViewController in self.viewControllers {
            if(aViewController is T){
                self.popToViewController(aViewController, animated: animated)
                break
            }
        }
    }
    
    func unwindBack(to viewController: Swift.AnyClass, animated: Bool = false) {
        
        for element in self.viewControllers as Array {
            if element.isKind(of: viewController) {
                self.popToViewController(element, animated: animated)
                break
            }
        }
    }
    
    
    public func remove<T: UIViewController>(type target: T.Type, animated: Bool = true ) {
        
        for tempVC: UIViewController in self.viewControllers
        {
            if tempVC.isKind(of: T.classForCoder()) {
                tempVC.removeFromParent()
            }
        }
    }
    
    public func removeAllBut<T: UIViewController>(type target: T.Type, animated: Bool = true ) {
        
        for tempVC: UIViewController in self.viewControllers
        {
            if tempVC.isKind(of: T.classForCoder()) == false {
                tempVC.removeFromParent()
            }
        }
    }
    
    /*
     These are the types that are available:
     
     kCATransitionFade
     kCATransitionMoveIn
     kCATransitionPush
     kCATransitionReveal
     @"cameraIris"
     @"cameraIrisHollowOpen"
     @"cameraIrisHollowClose"
     @"cube"
     @"alignedCube"
     @"flip"
     @"alignedFlip"
     @"oglFlip"
     @"rotate"
     @"pageCurl"
     @"pageUnCurl"
     @"rippleEffect"
     @"suckEffect"
     
     Subtypes that are available are:
     kCATransitionFromRight
     kCATransitionFromLeft
     kCATransitionFromTop
     kCATransitionFromBottom
 
 
 */
    // TODO: SWIFT4-2 Consider using CATransitionType in parameter list
    public func addTransition(transitionType type: CATransitionType = CATransitionType.fade,
                              subtype: String = CATransitionType.reveal.rawValue,
                              duration: CFTimeInterval = 0.3) {
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = type
        self.view.layer.add(transition, forKey: nil)
    }
}
