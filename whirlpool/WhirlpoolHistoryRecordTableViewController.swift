//
//  WhirlpoolHistoryRecordTableViewController.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2019/1/11.
//  Copyright © 2019 Vincent.Tone. All rights reserved.
//

import UIKit

class WhirlpoolHistoryRecordTableViewController: UITableViewController {
    var recordStore = WhirlpoolRecordStore()
    var history: Batches!
    var records: [WhirlpoolRecord]? = nil
    
    func load_records() {
        let records = self.recordStore.getHistoryRecords(uuid: self.history.uuid!, count: Int(self.history.count), offset: 0)
        var record: WhirlpoolRecord!
        for r in records {
            record = WhirlpoolRecord(num: Int(r.no) , time: r.t1, time_far: r.t2, desc: r.desc ?? "")
            self.records?.append(record)
        }
    }
}
