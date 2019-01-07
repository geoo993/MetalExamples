//
//  UIViewController+Ext.swift

import Foundation

public extension UIViewController {
    func getVisibleViewController(with rootViewController: UIViewController?) -> UIViewController? {
        var rootVC = rootViewController
        if rootVC == nil {
            rootVC = UIApplication.shared.keyWindow?.rootViewController
        }
        
        if rootVC?.presentedViewController == nil { // vc
            return rootVC
        }
        
        if let presented = rootVC?.presentedViewController {
            if presented.isKind(of: UINavigationController.self) {
                let navigationController = presented as? UINavigationController
                
                return navigationController!.viewControllers.last!
            }
            
            if presented.isKind(of: UITabBarController.self) {
                let tabBarController = presented as? UITabBarController
                return tabBarController!.selectedViewController!
            }
            
            return getVisibleViewController(with: presented)
        }
        
        return nil
    }
    
//    var controllerAppDelegate : AppDelegate? {
//        return UIApplication.shared.delegate as? AppDelegate
//    }
//    
    func disableNavBackButton(){
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = nil
        navigationItem.setLeftBarButton(nil, animated: true)
        navigationItem.leftBarButtonItems = []
    }
    
    func addMenuButton(with target: Any?, selector: Selector?, image : UIImage? ){
        let img = image?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        //create a new button
        let button: UIButton = UIButton(type: .system)
        //set image for button
        button.setImage(img, for: UIControl.State.normal)
        //add function for button
        button.addTarget(target, action: selector!, for: .touchUpInside)
        //set frame
        button.frame = CGRect(x:0, y:0, width:30, height:30)
        
        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        navigationItem.rightBarButtonItem = barButton
        
        //let menu1 = UIBarButtonItem(title: "Menu", style: .plain, target: self, action: selector)
        //let menu2 = UIBarButtonItem(image: image, style: .plain, target: target, action: selector  )
        //navigationItem.rightBarButtonItem = menu2

    }
    
    func presentModally(_ viewControllerToPresent: UIViewController, transitionStyle: UIModalTransitionStyle) {
        viewControllerToPresent.modalTransitionStyle = transitionStyle
        present(viewControllerToPresent, animated: true)
    }
    
    func presentDetail(_ viewControllerToPresent: UIViewController, duration: CFTimeInterval) {
        let transition = CATransition()
        transition.duration = duration
        transition.type = CATransitionType.push// kCATransitionFromBottom // transition type
        transition.subtype = CATransitionSubtype.fromRight // starts from
        view.window!.layer.add(transition, forKey: kCATransition)
        
        present(viewControllerToPresent, animated: true)
    }
    
    func dismissDetail(transitionType _: String = CATransitionType.push.rawValue) {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push // transition type
        transition.subtype = CATransitionSubtype.fromLeft// starts from
        view.window!.layer.add(transition, forKey: kCATransition)
        
        dismiss(animated: false)
    }
    
    func hideRemoveNavigationbarItems() {
        navigationController?.navigationBar.clearNavigationBar()
        navigationController?.view.backgroundColor = UIColor.clear
        
        navigationController?.isNavigationBarHidden = true
        navigationItem.disableAllNavItems()
    }
    
    // MARK: - Helper Methods
    
    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChild(viewController)
        
        // Add Child View as Subview
        view.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParent: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParent()
    }
}
