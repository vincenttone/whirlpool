//
//  WhirlpoolCurrentRecordsTableViewController.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2019/1/8.
//  Copyright © 2019 Vincent.Tone. All rights reserved.
//

import UIKit

class WhirlpoolRecordsTableViewController : UITableViewController {
    var recordStore = WhirlpoolRecordStore()
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .value1, reuseIdentifier: "UITableViewCell")
        let record = self.recordStore.get_record(index: indexPath.row)
        cell.textLabel?.text = "#" + (record?.num.description ?? "")
        cell.detailTextLabel?.text = record?.time?.description ?? "None for now"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recordStore.count()
    }
}
