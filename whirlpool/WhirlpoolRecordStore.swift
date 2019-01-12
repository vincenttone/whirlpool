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

class WhirlpoolRecordStore {
    
    // status
    enum STATE {
        case INIT
        case TIMING
        case PAUSING
    }
    
    var uuid: String = NSUUID().uuidString
    var title: String = ""
    
    var state = STATE.INIT
    
    var real_start_time: Date? = nil
    var finish_time: Date? = nil
    
    var start_time: Date? = nil
    var last_pause_time: Date? = nil
    var split_time: Date? = nil
    
    var current_record :WhirlpoolRecord = WhirlpoolRecord(num: 1, time: 0, time_far: 0)
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
    }
    
    func pause() {
        self.last_pause_time = Date()
        self.finish_time = self.last_pause_time
        self.state = STATE.PAUSING
    }
    
    func goOn() { // compute and reset overtime
        let current_date = Date.init()
        self.start_time = Date.init(timeInterval: current_date.timeIntervalSince(self.last_pause_time!), since: self.start_time!)
        self.split_time = Date.init(timeInterval: current_date.timeIntervalSince(self.last_pause_time!), since: self.split_time!)
        self.last_pause_time = Date.init(timeInterval: current_date.timeIntervalSince(self.last_pause_time!), since: self.last_pause_time!)
        self.state = STATE.TIMING
    }
    
    func split() {
        let pre_split_time = self.split_time ?? self.start_time!
        self.split_time = Date.init()
        self.records.append(
            WhirlpoolRecord(
                num: self.records.count + 1,
                time: self.split_time!.timeIntervalSince(pre_split_time),
                time_far: self.split_time!.timeIntervalSince(self.start_time!)
            )
        )
        self.current_record.num = self.records.count + 1
    }
    
    func getPausingTimeInterval() -> TimeInterval {
        return self.last_pause_time!.timeIntervalSince(self.start_time!)
    }
    
    func getTimingTimeInterval() -> TimeInterval {
        return Date().timeIntervalSince(self.start_time!)
    }
    
    func flushCurrentRecord() {
        if self.isPausing() {
            self.current_record.time = self.last_pause_time!.timeIntervalSince(self.split_time!)
            self.current_record.time_far = self.last_pause_time!.timeIntervalSince(self.start_time!)
        } else {
            self.current_record.time = self.split_time!.timeIntervalSince(Date())
            self.current_record.time_far = self.start_time!.timeIntervalSince(Date())
        }
    }
    
    func remove(index: Int) -> Bool {
        if self.records.count < index {
            return false
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
        let fbr = NSFetchRequest<Batches>(entityName: "Batches")
        fbr.fetchLimit = 1
        fbr.fetchOffset = 0
        do {
            let fbp = NSPredicate(format: "uuid=\"\(self.uuid)\"", "")
            fbr.predicate = fbp
            let fetchedBatch = try context.fetch(fbr)
            if fetchedBatch.count > 0 {
                saved_count = fetchedBatch.count
                print("batch saved before!", fetchedBatch)
            }
        } catch {
            print("fetch batch info failed!")
        }
        
        if saved_count > 0 { // remove old records
            let fetchRequest = NSFetchRequest<Records>(entityName: "Records")
            fetchRequest.fetchLimit = saved_count
            fetchRequest.fetchOffset = 0
            do {
                let predicate = NSPredicate(format: "uuid=\"\(self.uuid)\"", "")
                fetchRequest.predicate = predicate
                let fetchObjects = try context.fetch(fetchRequest)
                if fetchObjects.count > 0 {
                    for i in fetchObjects {
                        context.delete(i)
                    }
                }
            } catch {
                print("delete failed!!!")
            }
        } else { // insert batches
            let b = NSEntityDescription.insertNewObject(forEntityName: "Batches", into: context) as! Batches
            b.uuid = self.uuid
            b.title = self.title
            b.date = Date()
            b.count = Int32(self.count())
            
            do {
                try context.save()
                print("saved ok!!!")
            } catch {
                print("save failed!")
            }
        }
        // save records
        var rtx: Records!
        for r in self.getAllRecords() {
            rtx = NSEntityDescription.insertNewObject(forEntityName: "Records", into: context) as? Records
            rtx.no = Int32(r.num)
            rtx.uuid = self.uuid
            rtx.desc = r.desc
            rtx.t1 = r.time
            rtx.t2 = r.time_far ?? 0
            do {
                try context.save()
            } catch {
                print("save failed!")
            }
        }
    }
    
    func share(vc: UIViewController) {
        if self.isWaiting() {
            return
        }
        let items = [self.description]
        
        let avc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        avc.completionWithItemsHandler = {act, success, items, error in print(error ?? "ok") }
        vc.present(avc, animated: true)
    }
    
    var description: String {
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
    
    func getHistoryRecords(uuid: String, count: Int, offset: Int) -> [Records] {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        
        let fbr = NSFetchRequest<Records>(entityName: "Records")
        fbr.fetchLimit = count
        fbr.fetchOffset = offset
        fbr.sortDescriptors = [NSSortDescriptor(key: "no", ascending: true)]
        let fbp = NSPredicate(format: "uuid=\"\(uuid)\"", "")
        fbr.predicate = fbp
        do {
            let rs: [Records] = try context.fetch(fbr)
            return rs
        } catch {
            print("fetch batch info failed!")
        }
        return []
    }
}
