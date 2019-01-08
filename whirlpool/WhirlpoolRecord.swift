//
//  WhirlpoolRecord.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2019/1/8.
//  Copyright © 2019 Vincent.Tone. All rights reserved.
//

import Foundation

class WhirlpoolRecord :NSObject {
    var num = 0
    var time :TimeInterval!
    var time_far :TimeInterval?
    var desc :String = ""
    
    init(num :Int, time :TimeInterval, time_far :TimeInterval) {
        super.init()
        self.num = num
        self.time = time
        self.time_far = time_far
    }
    
    init(num :Int, time :TimeInterval, time_far :TimeInterval, desc :String) {
        super.init()
        self.num = num
        self.time = time
        self.time_far = time_far
        self.desc = desc
    }

    func set_desc(desc :String) {
        self.desc = desc
    }
    
    override var description: String{
        return "\(num) \(String(describing: time)) \(String(describing: time_far)) \(desc)"
    }
}
