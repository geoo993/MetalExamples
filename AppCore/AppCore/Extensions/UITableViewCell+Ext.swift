
import Foundation
import UIKit

public extension UITableViewCell
{
    func addSeparator(margin: CGFloat, color: UIColor, separatorHeight: CGFloat = 0.7, cellHeight : CGFloat? = nil, useFullWidth: Bool = false)
    {
        let width = useFullWidth ? UIScreen.main.bounds.width :self.frame.size.width
        let height = cellHeight ?? self.frame.size.height
        let seperatorFrame = CGRect(x:margin,y: height - separatorHeight, width: width - margin, height: separatorHeight)
        let seperatorView = UIView(frame: seperatorFrame)
        seperatorView.backgroundColor = color
        self.addSubview(seperatorView)
    }
  
    public func addTopSeparator(tableView: UITableView)
    {
        let margin = tableView.separatorInset.left
        self.addSeparator(margin: margin, color: tableView.separatorColor!)
    }
    
    public func addBottomSeparator(tableView: UITableView, cellHeight: CGFloat)
    {
        let margin = tableView.separatorInset.left
        
        self.addSeparator(margin: margin, color: tableView.separatorColor!, separatorHeight: 0.7, cellHeight: cellHeight - 2)
    }
    
    public func removeSeparator(width: CGFloat)
    {
        self.separatorInset = UIEdgeInsets(top: 0.0, left: width, bottom: 0.0, right: 0.0)
    }
    
    public func customSeperatorLine(withColor color: UIColor, separatorHeight: CGFloat){
        let screenSize = UIScreen.main.bounds
        let additionalSeparator = UIView.init(frame: CGRect(x: 0,
                                                            y: self.frame.size.height - separatorHeight,
                                                            width: screenSize.width,
                                                            height: separatorHeight))
        additionalSeparator.backgroundColor = color
        self.addSubview(additionalSeparator)
    }
    
}
