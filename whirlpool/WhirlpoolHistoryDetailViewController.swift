//
//  WhirlpoolHistoryDetailViewController.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2019/1/11.
//  Copyright © 2019 Vincent.Tone. All rights reserved.
//

import UIKit

class WhirlpoolHistoryDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var recordStore = WhirlpoolRecordStore()
    var history: Batches!
    var records: [WhirlpoolRecord] = []
    
    @IBOutlet weak var detailTableView: UITableView!
    
    override func viewDidLoad() {
        self.detailTableView.delegate = self
        self.detailTableView.dataSource = self
        super.viewDidLoad()
    }
    
    func load_records() {
        let records = self.recordStore.getHistoryRecords(uuid: self.history.uuid!, count: Int(self.history.count), offset: 0)
        var record: WhirlpoolRecord!
        for r in records {
            record = WhirlpoolRecord(num: Int(r.no) , time: r.t1, time_far: r.t2, desc: r.desc ?? "")
            self.records.append(record)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        let record = self.records[indexPath.row]
        cell!.textLabel?.textColor = .darkGray
        cell!.textLabel?.font = UIFont.init(name: "Helvetica neue", size: 20)
        if record.desc.count > 0 {
            cell!.textLabel?.text = String(format: "#%d %@", record.num, record.desc)
        } else {
            cell!.textLabel?.text = String(format: "#%d", record.num)
        }
        cell!.detailTextLabel?.textColor = .gray
        cell!.detailTextLabel?.font = UIFont.init(name: "Helvetica neue", size: 20)
        cell!.detailTextLabel?.text = String(format: "%@ \t%@", TimeHelper.format2ReadableTime(time: record.time!), TimeHelper.format2ReadableTime(time: record.time_far!))
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.records.count
    }
}
