//
//  WhirlpoolRecordStoreManager.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2019/1/14.
//  Copyright © 2019 Vincent.Tone. All rights reserved.
//
import UIKit
import CoreData

class WhirlpoolRecordStoreManager {
    static let instance = WhirlpoolRecordStoreManager()
    
    var stores: [WhirlpoolRecordStore] = []
    
    var currentStore: WhirlpoolRecordStore? = nil
    var currentTimer: Timer? = nil
    
    var timerVC: WhirlpoolViewController!
    
    var timerDisptachQueue = DispatchQueue(label: "soda.blue.dispatch.queue.timer")
    
    var archiveUrl: URL {
        let docDirs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docDir = docDirs.first!
        return docDir.appendingPathComponent("record.snapshoot.plist", isDirectory: false)
    }
    
    class func manager() -> WhirlpoolRecordStoreManager {
        return instance
    }
    
    func generateNewCurrentStore() -> WhirlpoolRecordStore {
        self.currentStore = WhirlpoolRecordStore()
        return self.currentStore!
    }
    
    func setCurrentStore(_ store: WhirlpoolRecordStore) {
        self.currentStore = store
    }
    
    func getCurrentStore() -> WhirlpoolRecordStore? {
        return self.currentStore
    }
    
    func fetchHistoriesCount() -> Int {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        let fbr = NSFetchRequest<Batch>(entityName: "Batch")
        var count = 0
        do {
            count = try context.count(for: fbr)
        } catch {
            print("fetch failed!")
        }
        return count
    }
    
    func loadHistories(limit: Int, offset: Int) -> [Batch] {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        
        let fbr = NSFetchRequest<Batch>(entityName: "Batch")
        fbr.fetchLimit = limit
        fbr.fetchOffset = offset
        fbr.sortDescriptors = [NSSortDescriptor.init(key: "date", ascending: false)]
        do {
            let fetchedBatch = try context.fetch(fbr)
            if fetchedBatch.count > 0 {
                return fetchedBatch
            }
        } catch {
            print("fetch batch info failed!")
        }
        return []
    }
    
    func saveSnapshoot() {
        if self.currentStore == nil || self.currentStore!.isWaiting() {
            return
        }
        do {
            try NSKeyedArchiver.archivedData(withRootObject: self.currentStore!, requiringSecureCoding: false).write(to: archiveUrl)
            print("save snapshoot archive to " + archiveUrl.absoluteString)
        } catch {
            print("save snapshoot archive failed! ")
        }
    }
    
    func recoverSnapshoot() -> Bool {
        if FileManager.default.fileExists(atPath: archiveUrl.path) == false {
            return false
        }
        var snapshoot_data: Data!
        do {
            snapshoot_data = try Data(contentsOf: archiveUrl)
        } catch {
            dump(error)
            print("get snapshoot data failed!")
            return false
        }
        do {
            let store = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(snapshoot_data) as? WhirlpoolRecordStore
            if store?.isWaiting() == false {
                self.currentStore = store
            }
            try FileManager.default.removeItem(at: archiveUrl)
        } catch {
            dump(error)
            print("recover snapshoot failed!")
            if FileManager.default.fileExists(atPath: archiveUrl.path) {
                do {
                    try FileManager.default.removeItem(at: archiveUrl)
                } catch {
                    print("remove archive file failed!")
                }
            }
            return false
        }
        return true
    }
    
    func tryRemoveSnapshot() {
        if FileManager.default.fileExists(atPath: archiveUrl.path) {
            do {
                try FileManager.default.removeItem(at: archiveUrl)
            } catch {
                dump(error)
                print("remove archive file failed!")
            }
        }
    }
    
    func loadLastHistory() -> Batch? {
        let history = self.loadHistories(limit: 1, offset: 0)
        if history.count > 0 {
            return history.first
        }
        return nil
    }
    
    func resetTimer(_ block: @escaping (_ timer: Timer) -> Void) {
        timerDisptachQueue.sync {
            self.currentTimer = Timer.scheduledTimer(
                withTimeInterval: 0.07,
                repeats: true,
                block: block
            )
            print("process start", ProcessInfo.processInfo.processIdentifier)
        }
    }
    
    func invalidateTimer() {
        timerDisptachQueue.sync {
            self.currentTimer?.invalidate()
            print("process stop", ProcessInfo.processInfo.processIdentifier)
        }
    }
    
    class func deleteHistory(uuid: String) throws {
        try WhirlpoolRecordStore.deleteRecords(uuid: uuid)
        try WhirlpoolRecordStore.deleteHistory(uuid: uuid)
    }
}
