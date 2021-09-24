//
//  WhirlpoolHistoryController.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2021/9/24.
//  Copyright © 2021 Vincent.Tone. All rights reserved.
//

import UIKit
import CoreData
import PolarShadowData


class WhirlpoolHistoryController: EzPage<Batch>, ObservableObject {
    static let shared = WhirlpoolHistoryController()
    
    @Published
    var stores: [WhirlpoolRecordStore] = []
    
    init() {
        let app = UIApplication.shared.delegate as! AppDelegate
        super.init(context: app.persistentContainer.viewContext,
                   request: NSFetchRequest<Batch>(entityName: "Batch"),
                   predicate: nil,
                   sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)])
    }
    
    func reload() {
        do {
            self.stores.removeAll()
            self.currentPage = 1
            let batches = try self.list()
            self.convertAndAppendHistories(batches: batches)
        } catch {
            NSLog("load data failed! error: %@", error.localizedDescription)
        }
    }
    
    func deleteHistory(_ store: WhirlpoolRecordStore) {
        do {
            try WhirlpoolRecordStoreManager.deleteHistory(uuid: store.uuid)
            let limit = self.limit
            let page = self.currentPage
            self.limit = self.currentPage * self.limit
            self.reload()
            self.currentPage = page
            self.limit = limit
        }  catch {
            NSLog("load data failed! error: %@", error.localizedDescription)
        }
    }
    
    private func nextPage() {
        do {
            let batches = try nextList()
            self.convertAndAppendHistories(batches: batches)
        } catch {
            NSLog("load data failed! error: %@", error.localizedDescription)
        }
    }
    
    private func convertAndAppendHistories(batches: [Batch]) {
        for b in batches {
            let store = WhirlpoolRecordStore()
            store.loadHistory(b)
            self.stores.append(store)
        }
    }
}
