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
    
    @IBAction func descTextFieldEditing(_ sender: Any) {
        self.record?.desc = self.descTextField.text ?? ""
    }
    
    func setRecord(record: WhirlpoolRecord) {
        self.record = record
        self.updateData(num: record.num , t1: TimeHelper.format2ReadableTime(time: record.time) , t2: TimeHelper.format2ReadableTime(time: record.time_far ?? 0))
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
