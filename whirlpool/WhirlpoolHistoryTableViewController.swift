//
//  WhirlpoolHistoryTableViewController.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2019/1/10.
//  Copyright © 2019 Vincent.Tone. All rights reserved.
//

import UIKit
import CoreData

class WhirlpoolHistoryTableViewController: UITableViewController {
    
    var fetchOffset = 0
    let fetchLimit = 30
    var histories: [Batches] = []
    var count = 0
    
    @IBOutlet weak var historiesTableView: UITableView!
    
    func cellForRow(at indexPath: IndexPath) -> UITableViewCell? {
        let cell = self.historiesTableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        while self.histories.count <= indexPath.row {
            self.loadHistories()
        }
        let history = self.histories[indexPath.row]
        cell?.textLabel?.text = history.title
        let dateFmter = DateFormatter()
        dateFmter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        var detailText = ""
        if history.date != nil {
           detailText = "@ " + dateFmter.string(from: history.date!) + "\t"
        }
        detailText += history.count.description + "条记录"
        cell?.detailTextLabel?.text = detailText
        return cell
    }
    
    func numberOfRows(inSection section: Int) -> Int {
        if self.count == 0 {
            self.fetchHistoriesCount()
        }
        return self.count
    }

    func fetchHistoriesCount() {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        let fbr = NSFetchRequest<Batches>(entityName: "Batches")
        do {
            self.count = try context.count(for: fbr)
        } catch {
            print("fetch failed!")
        }
    }

    func loadHistories() {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        
        let fbr = NSFetchRequest<Batches>(entityName: "Batches")
        fbr.fetchLimit = self.fetchLimit
        fbr.fetchOffset = self.fetchOffset
        do {
            let fetchedBatch = try context.fetch(fbr)
            if fetchedBatch.count > 0 {
                self.histories += fetchedBatch
                self.fetchOffset += fetchedBatch.count
            }
        } catch {
            print("fetch batch info failed!")
        }
    }
}
