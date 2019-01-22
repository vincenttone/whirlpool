//
//  WhirlpoolHistoryViewController.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2019/1/10.
//  Copyright © 2019 Vincent.Tone. All rights reserved.
//

import UIKit
import CoreData
//import GoogleMobileAds

class WhirlpoolHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var historyTableView: UITableView!
    
    var fetchOffset = 0
    let fetchLimit = 30
    var histories: [Batch] = []
    var count = 0
    
    var choosedIndexPath: IndexPath? = nil
    //var bannerAdsView: GADBannerView?
    
    override func viewDidLoad() {
        self.historyTableView.delegate = self
        self.historyTableView.dataSource = self
        super.viewDidLoad()
        //self.addBannerAdsView()
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
        detailText += history.count.description + NSLocalizedString("RECORDS", comment: "条记录")
        if history.title?.count == 0 {
            cell?.textLabel?.text = NSLocalizedString("UNTITLED", comment: "未命名")
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
        self.choosedIndexPath = indexPath
        self.performSegue(withIdentifier: "showHistoryDetail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var title = ""
            if self.histories.count > indexPath.row {
                title = self.histories[indexPath.row].title ?? ""
            }
            let alert = UIAlertController(title: NSLocalizedString("DELETE_CONFIRM", comment: "confirm deletion"), message: title, preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: NSLocalizedString("CANCEL", comment: "取消"), style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "确认"), style: .default, handler: { (_ sender: Any?) in
                let target_history = self.histories[indexPath.row]
                if target_history.uuid == nil {
                    let alert_failed = UIAlertController(title: NSLocalizedString("DELETE_FAILED", comment: "删除失败"), message: title, preferredStyle: .alert)
                    alert_failed.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "确认"), style: .default, handler: nil))
                    self.present(alert_failed, animated: true, completion: nil)
                    return
                }
                do {
                    try WhirlpoolRecordStore.deleteHistory(uuid: target_history.uuid!)
                    self.histories.remove(at: indexPath.row)
                    self.count -= 1
                    tableView.deleteRows(at: [indexPath], with: .fade)
                } catch {
                    dump(error)
                    let alert_failed = UIAlertController(title: NSLocalizedString("DELETE_FAILED", comment: "删除失败"), message: title, preferredStyle: .alert)
                    alert_failed.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "确认"), style: .default, handler: nil))
                    self.present(alert_failed, animated: true, completion: nil)
                    return
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showHistoryDetail" {
            if self.choosedIndexPath == nil {
                return
            }
            let ta = segue.destination as! WhirlpoolHistoryDetailViewController
            ta.loadHistory(self.histories[self.choosedIndexPath!.row])
            ta.deletedCallback = {() in
                self.count -= 1
                self.histories.remove(at: self.choosedIndexPath!.row)
                self.historyTableView.deleteRows(at: [self.choosedIndexPath!], with: .fade)
            }
        }
    }
    
    func fetchHistoriesCount() {
        self.count = WhirlpoolRecordStoreManager.manager().fetchHistoriesCount()
    }

    func loadHistories() {
        let fetchedBatch = WhirlpoolRecordStoreManager.manager().loadHistories(limit: self.fetchLimit, offset: self.fetchOffset)
        if fetchedBatch.count > 0 {
            self.histories += fetchedBatch
            self.fetchOffset += fetchedBatch.count
        }
    }
    /*
    func addBannerAdsView() {
        self.bannerAdsView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerAdsView!.adUnitID = "ca-app-pub-7990545623014959/6998390521"
        bannerAdsView!.rootViewController = self
        view.addSubview(bannerAdsView!)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerAdsView!,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: view.safeAreaLayoutGuide,
                               attribute: .top,
                               multiplier: 1,
                               constant: 0),
             NSLayoutConstraint(item: bannerAdsView!,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
        bannerAdsView!.load(GADRequest())
    }
 */
}
