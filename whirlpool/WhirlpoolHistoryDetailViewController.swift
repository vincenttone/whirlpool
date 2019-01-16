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
    var history: Batch!
    
    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var shareBtn: UIBarButtonItem!
    
    @IBAction func shareBtnTouched(_ sender: Any) {
        self.recordStore.share(vc: self)
    }
    
    override func viewDidLoad() {
        self.detailTableView.delegate = self
        self.detailTableView.dataSource = self
        self.navigationItem.title = self.history.title
        super.viewDidLoad()
        self.detailTableView.register(UINib(nibName: "WhirlpoolTimerTableViewCell", bundle: nil), forCellReuseIdentifier: "WhirlpoolTimerTableViewCell")
    }
    
    func loadHistory(_ history: Batch) {
        self.history = history
        self.recordStore.loadHistory(history)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WhirlpoolTimerTableViewCell") as! WhirlpoolTimerTableViewCell
        let record = self.recordStore.get_record(index: indexPath.row)!
        cell.setRecord(record)
        cell.prepareSwitchBar(tableView: tableView, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recordStore.count()
    }
}
