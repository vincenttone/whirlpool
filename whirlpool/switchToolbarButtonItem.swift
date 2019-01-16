//
//  switchToolbarButtonItem.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2019/1/16.
//  Copyright © 2019 Vincent.Tone. All rights reserved.
//

import UIKit

class switchToolbarButtonItem: UIBarButtonItem {
    var tableView: UITableView!
    var indexPath: IndexPath!
    var preIndexPath: IndexPath!
    var nextIndexPath: IndexPath!
    
    func switchToPreCell() -> UITableViewCell? {
        if indexPath.row == 0 {
            return nil
        }
        if tableView.numberOfRows(inSection: indexPath.section) > indexPath.row {
            self.preIndexPath = indexPath!
            self.preIndexPath.row -= 1
            return self.tableView.cellForRow(at: preIndexPath)
        }
        return nil
    }
    
    func switchToNextCell() -> UITableViewCell? {
        if indexPath.row < 0 {
            return nil
        }
        if tableView.numberOfRows(inSection: indexPath.section) - 1 > indexPath.row {
            self.nextIndexPath = indexPath!
            self.nextIndexPath.row += 1
            return self.tableView.cellForRow(at: nextIndexPath)
        }
        return nil
    }
}
