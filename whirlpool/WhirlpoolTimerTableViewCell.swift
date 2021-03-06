//
//  WhirlpoolTimerTableViewCell.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2019/1/15.
//  Copyright © 2019 Vincent.Tone. All rights reserved.
//

import UIKit

class WhirlpoolTimerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var t1Label: UILabel!
    @IBOutlet weak var t2Label: UILabel!
    
    var record: WhirlpoolRecord!
    var desc_changed: Bool = false
    var switchBar: WhirlpoolTableCellTextFieldSwitchBar?
    var beginEditingCallback: (()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.commentTextField.placeholder = NSLocalizedString("ADD_COMMENT", comment: "add comment")
        // Bundle.main.loadNibNamed("WhirlpoolTimerTableViewCell", owner: nil, options: nil)
    }
    
    @IBAction func finshEditing(_ sender: Any) {
        self.isEditing = false
        //self.resignFirstResponder()
    }
    
    @IBAction func didEndEditing(_ sender: Any) {
        if self.desc_changed {
            do {
                try self.record.update()
                self.desc_changed = false
                if self.record.uuid == WhirlpoolRecordStoreManager.manager().currentStore?.uuid {
                    let record = WhirlpoolRecordStoreManager.manager().currentStore?.records[self.record.num - 1]
                    record?.desc = self.record.desc
                }
            } catch {
                dump(error)
                print("update failed!")
            }
        }
    }
    
    @IBAction func whenEditing(_ sender: Any) {
        if beginEditingCallback != nil {
            beginEditingCallback!()
        }
        if self.record.desc != self.commentTextField.text {
            self.record.desc = self.commentTextField.text ?? ""
            self.desc_changed = true
        }
    }
    
    func setRecord(_ record: WhirlpoolRecord) {
        self.record = record
        self.titleLabel.text = "#" + self.record.num.description
        self.commentTextField.text = self.record.desc
        self.t1Label.text = TimeHelper.format2ReadableTime(time: self.record.time)
        self.t2Label.text = TimeHelper.format2ReadableTime(time: self.record.time_far)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func prepareSwitchBar(tableView: UITableView, indexPath: IndexPath) {
        switchBar = WhirlpoolTableCellTextFieldSwitchBar()
        switchBar?.addSwitchItems(
            tableView: tableView,
            indexPath: indexPath,
            textField: self.commentTextField,
            preCallback: {
                (cell: UITableViewCell?) in
                if cell == nil {
                    return
                }
                let commentField = (cell as! WhirlpoolTimerTableViewCell).commentTextField
                if commentField != nil {
                    tableView.scrollToRow(at: self.switchBar!.preIndexPath, at: .middle, animated: true)
                    commentField?.becomeFirstResponder()
                }
            },
            nextCallback: {(cell: UITableViewCell?) in
                if cell == nil {
                    return
                }
                let commentField = (cell as! WhirlpoolTimerTableViewCell).commentTextField
                if commentField != nil {
                    tableView.scrollToRow(at: self.switchBar!.nextIndexPath, at: .middle, animated: true)
                    commentField?.becomeFirstResponder()
                }
            }
        )
        self.commentTextField.inputAccessoryView = self.switchBar
    }
}
