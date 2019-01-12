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
    var records: [WhirlpoolRecord] = []
    
    @IBOutlet var historyRecordTableView: UITableView!
    
    func load_records() {
        let records = self.recordStore.getHistoryRecords(uuid: self.history.uuid!, count: Int(self.history.count), offset: 0)
        var record: WhirlpoolRecord!
        for r in records {
            record = WhirlpoolRecord(num: Int(r.no) , time: r.t1, time_far: r.t2, desc: r.desc ?? "")
            self.records.append(record)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        if cell == nil {
            cell = UITableViewCell(style: .value2, reuseIdentifier: "UITableViewCell")
        }
        let record = self.records[indexPath.row]
        cell!.textLabel?.text = record.num.description
        cell!.detailTextLabel?.text = TimeHelper.format2ReadableTime(time: record.time!) + "\t" + TimeHelper.format2ReadableTime(time: record.time_far!) + "\t" + record.desc
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.records.count
    }
}
