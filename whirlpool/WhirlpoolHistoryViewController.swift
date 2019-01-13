//
//  WhirlpoolHistoryViewController.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2019/1/10.
//  Copyright © 2019 Vincent.Tone. All rights reserved.
//

import UIKit
import CoreData

class WhirlpoolHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var historyTableView: UITableView!
    
    var fetchOffset = 0
    let fetchLimit = 30
    var histories: [Batches] = []
    var count = 0
    
    var choosedHistory: Batches? = nil
    
    override func viewDidLoad() {
        self.historyTableView.delegate = self
        self.historyTableView.dataSource = self
        super.viewDidLoad()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        while self.histories.count <= indexPath.row {
            self.loadHistories()
        }
        let history = self.histories[indexPath.row]
        cell?.textLabel?.text = history.title
        let dateFmter = DateFormatter()
        dateFmter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        var detailText = ""
        if history.date != nil {
           detailText = dateFmter.string(from: history.date!) + "\t"
        }
        detailText += history.count.description + "条记录"
        if history.title?.count == 0 {
            cell?.textLabel?.text = "暂无标题"
            cell?.textLabel?.textColor = .gray
        } else {
            cell?.textLabel?.textColor = .gray
        }
        cell?.detailTextLabel?.text = detailText
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.count == 0 {
            self.fetchHistoriesCount()
        }
        return self.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let vc = WhirlpoolHistoryRecordTableViewController()
        //vc.view.addSubview(UITableViewCell())
        self.choosedHistory = self.histories[indexPath.row]
        //vc.load_records()
        self.performSegue(withIdentifier: "showHistoryDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showHistoryDetail" {
            let ta = segue.destination as! WhirlpoolHistoryDetailViewController
            ta.history = self.choosedHistory!
            ta.load_records()
            print(ta.records)
        }
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
        fbr.sortDescriptors = [NSSortDescriptor.init(key: "date", ascending: false)]
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
