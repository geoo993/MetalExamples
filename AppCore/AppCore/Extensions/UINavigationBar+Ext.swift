import Foundation

public extension UINavigationBar {
    
    public func clearNavigationBarBackground(with color: UIColor){
        self.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.shadowImage = UIImage()
        self.isTranslucent = true
        self.backgroundColor = color
        
    }
    
    public func addBorderOnTitle(with textColor: UIColor, font: UIFont, borderWidth: CGFloat, borderColor: UIColor) {
        //Navigation Bar text
        self.titleTextAttributes = [
            NSAttributedStringKey.strokeColor : borderColor,
            NSAttributedStringKey.foregroundColor : textColor,
            NSAttributedStringKey.strokeWidth : -borderWidth,
            NSAttributedStringKey.font : font
            ] 
    }
    
    public func addBorderOnLargeTitle(with textColor: UIColor, font: UIFont, borderWidth: CGFloat, borderColor: UIColor) {
        //Navigation Bar text
        self.largeTitleTextAttributes = [
            NSAttributedStringKey.strokeColor : borderColor,
            NSAttributedStringKey.foregroundColor : textColor,
            NSAttributedStringKey.strokeWidth : -borderWidth,
            NSAttributedStringKey.font : font
            ]
    }
}
