
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
        self.separatorInset = UIEdgeInsetsMake(0.0, width, 0.0, 0.0)
    }
    
}
