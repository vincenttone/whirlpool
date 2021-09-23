//
//  DateUtil.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2021/9/23.
//  Copyright © 2021 Vincent.Tone. All rights reserved.
//

import Foundation

extension Date {
    /**
     * 快捷日期格式化方法
     * 比如： yyyy-MM-dd'T'HH:mm:ssZZZZZ
     */
    func quickFormat(format: String) -> String {//"dd MMM hh.mm" 1月20日 上午11:10
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate(format)
        formatter.locale = Locale.current
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func isDifferentDay(date: Date) -> Bool {
        let dateComponment = Calendar.current.dateComponents([.day], from: self, to: date)
        return dateComponment.day != 0
    }
}
