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
        return String(format: "#%d\t%@\t%@\t%@", self.num, self.format2ReadableTime(time: self.time ?? 0), self.format2ReadableTime(time: self.time_far ?? 0), self.desc)
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
