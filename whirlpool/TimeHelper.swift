//
//  TimeHelper.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2019/1/9.
//  Copyright © 2019 Vincent.Tone. All rights reserved.
//

import Foundation

class TimeHelper {
    
    class func format2ReadableTime(time: TimeInterval) -> String {
        if time == 0 {
            return "00:00.0"
        }
        let seconds = Int(abs(time))
        let minutes = Int(seconds / 60)
        let hours = Int(minutes / 60)
        let days = Int(hours / 24)

        let hour = hours - (days * 24)
        let minute = minutes - (hours * 60)
        let second = seconds - (minutes * 60)
        let ms = abs(time) - Double(seconds)
        
        if days > 0 {
            return String(format: "%d,%02d:%02d:%02d", days, hour, minute, second)
        } else if hour > 0 {
            return String(format: "%02d:%02d:%02d", hour, minute, second)
        } else {
            return String(format: "%02d:%04.1f", minutes, Double(second) + ms)
        }
    }
}
