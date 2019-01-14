//
//  WhirlpoolRecord.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2019/1/8.
//  Copyright © 2019 Vincent.Tone. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class WhirlpoolRecord :NSObject, NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(num, forKey: "num")
        aCoder.encode(time, forKey: "time")
        aCoder.encode(time_far, forKey: "time_far")
        aCoder.encode(desc, forKey: "desc")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.num = aDecoder.decodeObject(forKey: "num") as! Int
        self.time = (aDecoder.decodeObject(forKey: "time") as! TimeInterval)
        self.time_far = aDecoder.decodeObject(forKey: "time_far") as? TimeInterval
        self.desc = aDecoder.decodeObject(forKey: "desc") as! String
    }
    
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
    
    func encodedString() -> String {
        return String(format: "%d\t%@\t%@\t%@", self.num, TimeHelper.format2ReadableTime(time: self.time ?? 0), TimeHelper.format2ReadableTime(time: self.time_far ?? 0), self.desc)
    }
    
    override var description: String{
        return String(format: "#%d\t%@\t%@\t%@", self.num, TimeHelper.format2ReadableTime(time: self.time ?? 0), TimeHelper.format2ReadableTime(time: self.time_far ?? 0), self.desc)
    }
    
    func loadRecordData(_ record: Record) {
        self.num = Int(record.no)
        self.time = record.t1
        self.time_far = record.t2
        self.desc = record.desc ?? ""
    }
    
    func save(_ uuid: String) {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        // save records
        var rtx: Record!
        rtx = NSEntityDescription.insertNewObject(forEntityName: "Record", into: context) as? Record
        rtx.no = Int32(self.num)
        rtx.uuid = uuid
        rtx.desc = self.desc
        rtx.t1 = self.time
        rtx.t2 = self.time_far ?? 0
        do {
            try context.save()
        } catch {
            print("save failed!")
        }
    }

}
