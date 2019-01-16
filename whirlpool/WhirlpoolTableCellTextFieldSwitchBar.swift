//
//  WhirlpoolTableCellTextFieldSwitchBar.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2019/1/16.
//  Copyright © 2019 Vincent.Tone. All rights reserved.
//

import UIKit

class WhirlpoolTableCellTextFieldSwitchBar: UIToolbar {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var tableView: UITableView!
    var indexPath: IndexPath!
    var preIndexPath: IndexPath!
    var nextIndexPath: IndexPath!
    var record: WhirlpoolRecord!
    
    var preCallback: ((_ cell: UITableViewCell?) -> Void)?
    var nextCallback: ((_ cell: UITableViewCell?) -> Void)?
    
    func setIndexPath(_ indexPath: IndexPath) {
        self.indexPath = indexPath
        preIndexPath = indexPath
        nextIndexPath = indexPath
        preIndexPath.row = indexPath.row - 1
        nextIndexPath.row = indexPath.row + 1
    }
    
    func addSwitchItems(tableView: UITableView, indexPath: IndexPath, record:WhirlpoolRecord, preCallback: @escaping (_ cell: UITableViewCell?) -> Void, nextCallback: @escaping (_ cell: UITableViewCell?) -> Void) {
        self.setIndexPath(indexPath)
        self.tableView = tableView
        self.record = record
        let preBtn = WhirlpoolSwitchToolbarButtonItem(title: "上一个", style: .plain, target: self, action: #selector(switchToPreTarget(sender:)))
        self.preCallback = preCallback
        let nextBtn = WhirlpoolSwitchToolbarButtonItem(title: "下一个", style: .plain, target: self, action: #selector(switchToNextTarget(sender:)))
        self.nextCallback = nextCallback
        self.items = [preBtn, nextBtn]
        self.sizeToFit()
    }
    
    @objc func switchToPreTarget(sender: WhirlpoolSwitchToolbarButtonItem) {
        if self.preCallback != nil {
            self.preCallback!(sender.switchToPreCell())
        }
    }
    
    @objc func switchToNextTarget(sender: WhirlpoolSwitchToolbarButtonItem) {
        if self.nextCallback != nil {
            self.nextCallback!(sender.switchToNextCell())
        }
    }
}
