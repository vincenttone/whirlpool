//
//  WhirlpoolToolbarTableViewCell.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2019/1/10.
//  Copyright © 2019 Vincent.Tone. All rights reserved.
//

import UIKit
import CoreData

class WhirlpoolToolbarTableViewCell: UITableViewCell {
    
    var recordStore : WhirlpoolRecordStore!
    var basedViewController :WhirlpoolViewController!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    
    @IBAction func didEndEditing(_ sender: Any) {
        self.nameTextField.resignFirstResponder()
    }
    @IBAction func editChanged(_ sender: Any) {
        self.recordStore.title = self.nameTextField.text ?? ""
    }
    
    @IBAction func shareBtnTouched(_ sender: Any) {
        if self.recordStore.isWaiting() {
            return
        }
        let items = [self.recordStore.description]
        
        let avc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        avc.completionWithItemsHandler = {act, success, items, error in print(error ?? "ok") }
        self.basedViewController.present(avc, animated: true)
    }
    
    @IBAction func saveBtnTouched(_ sender: Any) {
        self.recordStore.save()
    }
    
}
