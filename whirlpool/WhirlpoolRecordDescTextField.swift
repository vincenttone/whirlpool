//
//  WhirlpoolRecordDescTextField.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2019/1/9.
//  Copyright © 2019 Vincent.Tone. All rights reserved.
//

import UIKit

class WhirlpoolRecordDescTextField: UITextField {
    var editable = false
    
    func setEditable() {
        if self.editable {
            return
        }
        self.editable = true
        if self.text?.count == 0 {
            self.placeholder = "添加备注"
        }
    }
    
    func setReadonly() {
        self.editable = false
        if self.text?.count == 0 {
            self.placeholder = ""
        }
    }

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.editable
    }

}
