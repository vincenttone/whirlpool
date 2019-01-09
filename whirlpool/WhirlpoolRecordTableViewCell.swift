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
        self.updateData(num: record.num , t1: self.format2ReadableTime(time: record.time) , t2: self.format2ReadableTime(time: record.time_far ?? 0))
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
    
    func format2ReadableTime(time: TimeInterval) -> String {
        if time == 0 {
            return "00:00.0"
        }
        let timed = fabs(Double(time))
        let day = Int(floor(timed / 86400))
        let hours = Int(floor(timed / 3600))
        let minutes = Int(floor(timed.truncatingRemainder(dividingBy: 3600) / 60))
        let seconds = timed.truncatingRemainder(dividingBy: 60)
        if day > 0 {
            return String(format: "%d,%02d:%02d", day, hours, minutes)
        } else if hours > 0 {
            return String(format: "%02d:%02d:%04.1f", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%04.1f", minutes, seconds)
        }
    }
}
