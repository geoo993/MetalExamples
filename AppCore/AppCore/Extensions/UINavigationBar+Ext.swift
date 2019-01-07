import Foundation

public extension UINavigationBar {
    
    public func clearNavigationBar(to color: UIColor){
        self.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.shadowImage = UIImage()
        self.isTranslucent = true
        self.backgroundColor = color
    }
    
    func clearNavigationBar() {
        setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        shadowImage = UIImage()
        isTranslucent = true
    }
    
    public func addBorderOnTitle(with textColor: UIColor, font: UIFont, borderWidth: CGFloat, borderColor: UIColor) {
        //Navigation Bar text
        self.titleTextAttributes = [
            NSAttributedString.Key.strokeColor : borderColor,
            NSAttributedString.Key.foregroundColor : textColor,
            NSAttributedString.Key.strokeWidth : -borderWidth,
            NSAttributedString.Key.font : font
            ] 
    }
    
    public func addBorderOnLargeTitle(with textColor: UIColor, font: UIFont, borderWidth: CGFloat, borderColor: UIColor) {
        //Navigation Bar text
        self.largeTitleTextAttributes = [
            NSAttributedString.Key.strokeColor : borderColor,
            NSAttributedString.Key.foregroundColor : textColor,
            NSAttributedString.Key.strokeWidth : -borderWidth,
            NSAttributedString.Key.font : font
            ]
    }
}
