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

class WhirlpoolRecord :NSObject, NSCoding, ObservableObject {
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(num, forKey: "num")
        aCoder.encode(time, forKey: "time")
        aCoder.encode(time_far, forKey: "time_far")
        aCoder.encode(desc, forKey: "desc")
        aCoder.encode(uuid, forKey: "uuid")
    }
    
    required init?(coder aDecoder: NSCoder) {
        num = aDecoder.decodeInteger(forKey: "num")
        time = aDecoder.decodeDouble(forKey: "time") as TimeInterval
        time_far = aDecoder.decodeDouble(forKey: "time_far") as TimeInterval
        desc = aDecoder.decodeObject(forKey: "desc") as! String
        uuid = aDecoder.decodeObject(forKey: "uuid") as? String
    }
    
    // 标号
    @Published
    var num = 0
    
    // 计时开始时间
    @Published
    var time :TimeInterval = 0
    
    // 计时结束时间
    @Published
    var time_far :TimeInterval = 0
    
    // 简介
    @Published
    var desc :String = ""
    
    @Published
    var uuid: String!
    
    init(num: Int, uuid: String) {
        super.init()
        self.num = num
        self.uuid = uuid
    }
    
    init(_ record: Record) {
        super.init()
        self.uuid = record.uuid
        self.num = Int(record.no)
        self.time = record.t1
        self.time_far = record.t2
        self.desc = record.desc ?? ""
    }
    
    init(num :Int, time :TimeInterval, time_far :TimeInterval) {
        super.init()
        self.num = num
        self.time = time
        self.time_far = time_far
    }
    
    init(num :Int, time :TimeInterval, time_far :TimeInterval, desc :String, uuid: String) {
        super.init()
        self.num = num
        self.time = time
        self.time_far = time_far
        self.desc = desc
        self.uuid = uuid
    }

    func set_desc(desc :String) {
        self.desc = desc
    }
    
    func encodedString() -> String {
        return String(format: "%d\t%@\t%@\t%@", self.num, TimeHelper.format2ReadableTime(time: self.time), TimeHelper.format2ReadableTime(time: self.time_far), self.desc)
    }
    
    override var description: String{
        return String(format: "#%d\t%@\t%@\t%@", self.num, TimeHelper.format2ReadableTime(time: self.time), TimeHelper.format2ReadableTime(time: self.time_far), self.desc)
    }
    
    var isSaved: Bool {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        // save records
        let request = NSFetchRequest<Record>(entityName: "Record")
        let predicate = NSPredicate(format: "uuid = \"\(self.uuid!)\" AND %K = %d", "no", self.num)
        request.predicate = predicate
        do {
            let records = try context.fetch(request)
            return !records.isEmpty
        } catch {
            NSLog("get record failed! error: %@", error.localizedDescription)
            return false
        }
    }
    
    func update() throws {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        // save records
        let request = NSFetchRequest<Record>(entityName: "Record")
        let predicate = NSPredicate(format: "uuid = \"\(self.uuid!)\" AND %K = %d", "no", self.num)
        request.predicate = predicate
        do {
            let records = try context.fetch(request)
            for r in records {
                r.desc = self.desc
            }
            try context.save()
        } catch {
            print("update failed!")
            throw error
        }
    }
    
    func save(context: NSManagedObjectContext) throws {
        // save records
        var record: Record!
        record = NSEntityDescription.insertNewObject(forEntityName: "Record", into: context) as? Record
        self.warpToRecord(record: record)
        do {
            try context.save()
        } catch {
            print("save failed!")
            throw error
        }
    }
    
    func save() throws {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        try self.save(context: context)
    }
    
    func warpToRecord(record: Record) {
        record.no = Int32(self.num)
        record.uuid = self.uuid
        record.desc = self.desc
        record.t1 = self.time
        record.t2 = self.time_far
    }

}
