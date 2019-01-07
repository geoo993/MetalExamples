import Foundation
import UIKit

public extension UITableView {
    
    public func getAllCells() -> [UITableViewCell] {
        
        var cells = [UITableViewCell]()
        // assuming tableView is your self.tableView defined somewhere
        for i in 0..<self.numberOfSections
        {
            for j in 0..<self.numberOfRows(inSection:i)
            {
                if let cell = self.cellForRow(at: IndexPath(row: j, section: i) ) {
                    
                    cells.append(cell)
                }
                
            }
        }
        return cells
    }
    
    public func scrollToBottom(animated: Bool) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            
            let numberOfSections = self.numberOfSections
            let numberOfRows = self.numberOfRows(inSection: numberOfSections-1)
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.bottom, animated: animated)
            }
        }
    }
    
    public func updateCellChange() {
        
    }
    
    public func applyChanges(section: Int, deletions: [Int], insertions: [Int], updates: [Int]) {
        beginUpdates()
        deleteRows(at: deletions.map(IndexPath.fromRow), with: .automatic)
        insertRows(at: insertions.map(IndexPath.fromRow), with: .automatic)
        reloadRows(at: updates.map(IndexPath.fromRow), with: .none)
        endUpdates()
    }
    
}
