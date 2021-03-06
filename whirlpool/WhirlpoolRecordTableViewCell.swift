//
//  WhirlpoolRecordTableViewCell.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2019/1/9.
//  Copyright © 2019 Vincent.Tone. All rights reserved.
//

import UIKit


class WhirlpoolRecordTableViewCell : UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var time1Label: UILabel!
    @IBOutlet var time2Label: UILabel!
    @IBOutlet var descTextField: WhirlpoolRecordDescTextField!
    
    var record: WhirlpoolRecord?
    var beginEditingCallback: (() -> Void)?
    
    @IBAction func descTextFieldEditing(_ sender: Any) {
        self.record?.desc = self.descTextField.text ?? ""
    }
    @IBAction func didEndEditing(_ sender: Any) {
        self.descTextField.resignFirstResponder()
    }
    
    @IBAction func didBeginEditing(_ sender: Any) {
        if self.beginEditingCallback != nil {
            beginEditingCallback!()
        }
    }
    
    func setRecord(record: WhirlpoolRecord) {
        self.record = record
        self.updateData(num: record.num , t1: TimeHelper.format2ReadableTime(time: record.time) , t2: TimeHelper.format2ReadableTime(time: record.time_far))
    }
    
    func updateData(num: Int, t1: String, t2: String) {
        self.titleLabel.text = "#" + num.description
        self.time1Label.text = t1
        self.time2Label.text = t2
        self.descTextField.text = record?.desc ?? ""
    }
    
    func disableDescTextField() {
        self.descTextField.setReadonly()
    }
    
    func enableDescTextField() {
        self.descTextField.setEditable()
    }
}
