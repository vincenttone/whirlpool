//
//  WhirlpoolSwitchToolbarButtonItem.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2019/1/16.
//  Copyright © 2019 Vincent.Tone. All rights reserved.
//

import UIKit

class WhirlpoolSwitchToolbarButtonItem: UIBarButtonItem {
    //var switchBar: WhirlpoolTableCellTextFieldSwitchBar!
    
    func switchToPreCell() -> UITableViewCell? {
        if self.target == nil {
            return nil
        }
        let switchBar: WhirlpoolTableCellTextFieldSwitchBar = self.target! as! WhirlpoolTableCellTextFieldSwitchBar
        if switchBar.indexPath.row == 0 {
            return nil
        }
        if switchBar.tableView.numberOfRows(inSection: switchBar.indexPath.section) > switchBar.indexPath.row {
            return switchBar.tableView.cellForRow(at: switchBar.preIndexPath)
        }
        return nil
    }
    
    func switchToNextCell() -> UITableViewCell? {
        if self.target == nil {
            return nil
        }
        let switchBar = self.target! as! WhirlpoolTableCellTextFieldSwitchBar
        if switchBar.indexPath.row < 0 {
            return nil
        }
        if switchBar.tableView.numberOfRows(inSection: switchBar.indexPath.section) - 1 > switchBar.indexPath.row {
            return switchBar.tableView.cellForRow(at: switchBar.nextIndexPath)
        }
        return nil
    }
}
