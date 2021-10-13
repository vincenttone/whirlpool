//
//  WhirlpoolRecordStroe.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2019/1/8.
//  Copyright © 2019 Vincent.Tone. All rights reserved.
//
import Foundation
import UIKit
import CoreData

class WhirlpoolRecordStore: NSObject, NSCoding, ObservableObject {
    
    // status
    enum STATE :Int{
        case INIT = 0;
        case TIMING = 1;
        case PAUSING = 2;
    }
    
    struct EncodeError: Error {
        let reason: String
        var context: String = ""
        init(reason: String) {
            self.reason = reason
        }
    }
    
    var uuid: String = NSUUID().uuidString
    
    @Published
    var title: String = ""
    
    @Published
    var state = STATE.INIT
    
    var real_start_time: Date? = nil
    var finish_time: Date? = nil
    
    var start_time: Date? = nil
    var last_pause_time: Date? = nil
    var split_time: Date? = nil
    
    var current_record :WhirlpoolRecord!

    @Published
    var records :[WhirlpoolRecord] = []
    
    func isTiming() -> Bool {
        return self.state == STATE.TIMING
    }
    
    func isPausing() -> Bool {
        return self.state == STATE.PAUSING
    }
    
    func isWaiting() -> Bool {
        return self.state == STATE.INIT
    }
    
    func start() {
        self.real_start_time = Date()
        self.start_time = self.real_start_time
        self.split_time = self.real_start_time
        self.state = STATE.TIMING
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func pause() {
        self.last_pause_time = Date()
        self.finish_time = self.last_pause_time
        self.state = STATE.PAUSING
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func goOn() { // compute and reset overtime
        let current_date = Date.init()
        self.start_time = Date.init(timeInterval: current_date.timeIntervalSince(self.last_pause_time!), since: self.start_time!)
        self.split_time = Date.init(timeInterval: current_date.timeIntervalSince(self.last_pause_time!), since: self.split_time!)
        self.last_pause_time = Date.init(timeInterval: current_date.timeIntervalSince(self.last_pause_time!), since: self.last_pause_time!)
        self.state = STATE.TIMING
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func split() {
        let pre_split_time = self.split_time ?? self.start_time!
        self.split_time = Date.init()
        self.records.append(
            WhirlpoolRecord(
                num: self.records.count + 1,
                time: self.split_time!.timeIntervalSince(pre_split_time),
                time_far: self.split_time!.timeIntervalSince(self.start_time!),
                desc: self.current_record.desc,
                uuid: self.uuid
            )
        )
        self.current_record.desc = ""
        self.current_record.num = self.records.count + 1
    }
    
    func getPausingTimeInterval() -> TimeInterval {
        return self.last_pause_time!.timeIntervalSince(self.start_time!)
    }
    
    func getTimingTimeInterval() -> TimeInterval {
        return Date().timeIntervalSince(self.start_time ?? Date())
    }
    
//    func getTimingInterval() -> TimeInterval {
//        switch self.state {
//        case .INIT:
//            return TimeInterval(0)
//        case .PAUSING:
//            return self.getPausingTimeInterval()
//        case .TIMING:
//            return self.getTimingInterval()
//        }
//    }
    
    func flushCurrentRecord() {
        if self.isPausing() {
            self.current_record.time = self.last_pause_time!.timeIntervalSince(self.split_time!)
            self.current_record.time_far = self.last_pause_time!.timeIntervalSince(self.start_time!)
        } else if !self.isWaiting() {
            self.current_record.time = Date().timeIntervalSince(self.split_time!)
            self.current_record.time_far = Date().timeIntervalSince(self.start_time!)
        }
    }
    
    func remove(at indexSet: IndexSet) {
        for i in indexSet {
            let _ = self.remove(index: i)
        }
    }
    
    func remove(index: Int) -> Bool {
        if self.records.count < index {
            return false
        } else if index == 0 {
            self.state = .INIT
            if self.records.isEmpty {
                self.current_record = WhirlpoolRecord(num: 1,  uuid: self.uuid)
            } else {
                self.current_record = self.records.popLast()
            }
            return true
        } else {
            self.records.remove(at: index - 1)
            return true
        }
    }
    
    func get_record(index: Int) -> WhirlpoolRecord? {
        if self.isWaiting() {
            return nil
        }
        if self.count() <= index {
            return nil
        } else if index == self.records.count {
            return self.current_record
        } else {
            return self.records[index]
        }
    }
    
    func count() -> Int {
        if self.isWaiting() {
            return 0
        }
        return self.records.count + 1
    }
    
    func loadHistory(_ history: Batch) {
        self.uuid = history.uuid!
        self.state = WhirlpoolRecordStore.STATE(rawValue: Int(history.state)) ?? STATE.INIT
        self.title = history.title ?? ""
        self.start_time = history.start_time ?? Date()
        self.real_start_time = history.real_start_time
        self.finish_time = history.finish_time
        self.split_time = history.split_time ?? self.start_time
        self.last_pause_time = history.last_pause_time
        
        let rs = self.getHistoryRecords(uuid: self.uuid, count: Int(history.count), offset: 0)
        self.records = []
        for rd in rs {
            self.records.append(WhirlpoolRecord(num: Int(rd.no), time: rd.t1, time_far: rd.t2, desc: rd.desc ?? "", uuid: rd.uuid!))
        }
        if self.records.count > 0 {
            self.current_record = self.records.popLast()!
        }
    }
    
    func getAllRecords() -> [WhirlpoolRecord] {
        if self.isWaiting() {
            return []
        }
        var records = self.records
        records.append(self.current_record)
        return records
    }
    
    func save() {
        if self.isWaiting() {
            return
        }
        
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        
        var saved_count = 0
        let fbr = NSFetchRequest<Batch>(entityName: "Batch")
        do {
            let fbp = NSPredicate(format: "uuid=\"\(self.uuid)\"", "")
            fbr.predicate = fbp
            let fetchedBatch = try context.fetch(fbr)
            if fetchedBatch.count > 0 {
                for _b in fetchedBatch {
                    saved_count = Int(_b.count) > saved_count ? Int(_b.count) : saved_count
                    _b.title = self.title
                    _b.date = Date()
                    _b.count = Int32(self.count())
                    _b.state = Int16(self.state.rawValue)
                    _b.start_time = self.start_time
                    _b.real_start_time = self.real_start_time
                    _b.finish_time = self.finish_time
                    _b.split_time = self.split_time
                    _b.last_pause_time = self.last_pause_time
                    
                }
                try context.save()
            } else {
                self.createHistory()
            }
        } catch {
            print("fetch and up batch info failed!")
        }
        
        if saved_count > 0 { // remove old records
            // update saved batch
            do {
                try WhirlpoolRecordStore.deleteRecords(uuid: self.uuid, context: context)
            } catch {
                dump(error)
                print("delete records failed!")
            }
        }
        // save records
        for r in self.getAllRecords() {
            do {
                try r.save(context: context)
            } catch {
                dump(error)
            }
        }
    }
    
    func share(vc: UIViewController, shareItem: UIBarButtonItem) {
        if self.isWaiting() {
            return
        }
        let items = [self.description]
        
        let avc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        avc.completionWithItemsHandler = {act, success, items, error in print(error ?? "ok") }
        avc.popoverPresentationController?.barButtonItem = shareItem
        vc.present(avc, animated: true)
    }
    
    override var description: String {
        if self.isWaiting() {
            return ""
        }
        let dateFmter = DateFormatter()
        dateFmter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        var out_str = self.title
        if out_str != "" { out_str += "\n"}
        out_str +=  dateFmter.string(from: self.start_time!)
        for r in self.getAllRecords() {
            out_str += "\n" + r.description
        }
        return out_str
    }
    
    func createHistory() {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        
        let b = NSEntityDescription.insertNewObject(forEntityName: "Batch", into: context) as! Batch
        b.title = self.title
        b.date = Date()
        b.count = Int32(self.count())
        b.state = Int16(self.state.rawValue)
        b.start_time = self.start_time
        b.real_start_time = self.real_start_time
        b.finish_time = self.finish_time
        b.split_time = self.split_time
        b.last_pause_time = self.last_pause_time
        b.uuid = self.uuid
        do {
            try context.save()
        } catch {
            print("save failed!")
        }
    }
    
    func updateHistory(history: WhirlpoolRecordStore) {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        
        let fbr = NSFetchRequest<Batch>(entityName: "Batch")
        do {
            let fbp = NSPredicate(format: "uuid=\"\(history.uuid)\"", "")
            fbr.predicate = fbp
            let fetchedBatch = try context.fetch(fbr)
            if fetchedBatch.count > 0 {
                for _b in fetchedBatch {
                    _b.title = history.title
                    _b.date = Date()
                    _b.count = Int32(history.count())
                    _b.state = Int16(history.state.rawValue)
                    _b.start_time = history.start_time
                    _b.real_start_time = history.real_start_time
                    _b.finish_time = history.finish_time
                    _b.split_time = history.split_time
                    _b.last_pause_time = history.last_pause_time
                }
                try context.save()
            }
        } catch {
            print("fetch and up batch info failed!")
        }
    }
    
    func getHistoryRecords(uuid: String, count: Int, offset: Int) -> [Record] {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        
        let fbr = NSFetchRequest<Record>(entityName: "Record")
        fbr.fetchLimit = count
        fbr.fetchOffset = offset
        fbr.sortDescriptors = [NSSortDescriptor(key: "no", ascending: true)]
        let fbp = NSPredicate(format: "uuid=\"\(uuid)\"", "")
        fbr.predicate = fbp
        do {
            let rs: [Record] = try context.fetch(fbr)
            return rs
        } catch {
            print("fetch batch info failed!")
        }
        return []
    }
    
    class func deleteHistory(uuid: String) throws {
        try WhirlpoolRecordStore.deleteRecords(uuid: uuid)
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Batch>(entityName: "Batch")
        do {
            let predicate = NSPredicate(format: "uuid=\"\(uuid)\"", "")
            fetchRequest.predicate = predicate
            let fetchObjects = try context.fetch(fetchRequest)
            if fetchObjects.count > 0 {
                for i in fetchObjects {
                    context.delete(i)
                }
            }
            try context.save()
        } catch {
            print("delete failed!!!")
            throw error
        }
    }
    
    class func deleteRecords(uuid: String, context: NSManagedObjectContext) throws {
        let fetchRequest = NSFetchRequest<Record>(entityName: "Record")
        do {
            let predicate = NSPredicate(format: "uuid=\"\(uuid)\"", "")
            fetchRequest.predicate = predicate
            let fetchObjects = try context.fetch(fetchRequest)
            if fetchObjects.count > 0 {
                for i in fetchObjects {
                    context.delete(i)
                }
            }
            try context.save()
        } catch {
            print("delete failed!!!")
            throw error
        }
    }
    
    class func deleteRecords(uuid: String) throws {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        try WhirlpoolRecordStore.deleteRecords(uuid: uuid, context: context)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.start_time, forKey: "start_time")
        aCoder.encode(self.real_start_time, forKey: "real_start_time")
        aCoder.encode(self.finish_time, forKey: "finish_time")
        aCoder.encode(self.last_pause_time, forKey: "pause_time")
        aCoder.encode(self.split_time, forKey: "split_time")
        aCoder.encode(self.getAllRecords(), forKey: "records")
        aCoder.encode(self.state.rawValue, forKey: "state")
        aCoder.encode(self.title, forKey: "title")
        aCoder.encode(self.uuid, forKey: "uuid")
    }
    
    override init() {
        super.init()
        self.current_record = WhirlpoolRecord(num: 1,  uuid: self.uuid)
    }
    
    required init?(coder aDecoder: NSCoder) {
        var rs = aDecoder.decodeObject(forKey: "records") as! [WhirlpoolRecord]
        if rs.count == 0 {
            return
        }
        self.current_record = rs.popLast()!
        self.records = rs
        start_time = (aDecoder.decodeObject(forKey: "start_time") as! Date)
        split_time = (aDecoder.decodeObject(forKey: "split_time") as! Date)
        real_start_time = (aDecoder.decodeObject(forKey: "real_start_time") as! Date)
        finish_time = aDecoder.decodeObject(forKey: "finish_time") as! Date?
        last_pause_time = aDecoder.decodeObject(forKey: "pause_time") as! Date?
        state = STATE.init(rawValue: aDecoder.decodeInteger(forKey: "state"))!
        title = aDecoder.decodeObject(forKey: "title") as! String
        uuid = aDecoder.decodeObject(forKey: "uuid") as! String
    }
    
}
