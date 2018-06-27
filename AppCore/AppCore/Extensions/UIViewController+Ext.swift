//
//  UIViewController+Ext.swift

import Foundation

public extension UIViewController {
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
        let img = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        //create a new button
        let button: UIButton = UIButton(type: .system)
        //set image for button
        button.setImage(img, for: UIControlState.normal)
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

    // MARK: - Helper Methods

    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChildViewController(viewController)

        // Add Child View as Subview
        view.addSubview(viewController.view)

        // Configure Child View
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }

    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParentViewController: nil)

        // Remove Child View From Superview
        viewController.view.removeFromSuperview()

        // Notify Child View Controller
        viewController.removeFromParentViewController()
    }
    
}
