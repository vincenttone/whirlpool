//
//  DataViewController.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2019/1/3.
//  Copyright © 2019 Vincent.Tone. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class WhirlpoolViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let TIMER_INIT_STR = "00:00.00"
    
    enum BTN_TEXT :String {
        case START = "开始"
        case PAUSE = "暂停"
        case SPLIT = "计次"
        case GO_ON = "继续"
        case RESET = "重置"
        case SAVE = "保存"
    }
    
    @IBOutlet var startBtn: UIButton!
    @IBOutlet var splitBtn: UIButton!
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBOutlet weak var shareBtn: UIBarButtonItem!
    
    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet weak var recordsTableView: UITableView!
    
    override func viewDidLoad() {
        self.recordsTableView.dataSource = self
        self.recordsTableView.delegate = self
        super.viewDidLoad()
        self.reset()
        if (WhirlpoolRecordStoreManager.manager().recoverSnapshoot()) {
            if WhirlpoolRecordStoreManager.manager().currentStore!.isTiming() {
                self.setTimingStyle()
            } else {
                self.setPausingStyle()
            }
            self.splitBtn.isEnabled = true
            self.recordsTableView.reloadData()
            self.resetTimer()
        }
        WhirlpoolRecordStoreManager.manager().timerVC = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func startBtnTouched(_ sender: Any) {
        if WhirlpoolRecordStoreManager.manager().currentStore!.isWaiting() {
            self.start()
        } else if WhirlpoolRecordStoreManager.manager().currentStore!.isTiming() {
            self.pause()
        } else if WhirlpoolRecordStoreManager.manager().currentStore!.isPausing() {
            self.goOn()
        }
    }
    
    @IBAction func splitBtnTouched(_ sender: Any) {
        if WhirlpoolRecordStoreManager.manager().currentStore!.isPausing() {
            self.reset()
        } else if WhirlpoolRecordStoreManager.manager().currentStore!.isTiming() {
            self.split()
        } else if WhirlpoolRecordStoreManager.manager().currentStore!.isWaiting() {
            self.do_nothing()
        }
    }
    
    @IBAction func saveBtnTouched(_ sender: Any) {
        let alert = UIAlertController(title: "名称", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "请输入记录名称"
            if WhirlpoolRecordStoreManager.manager().currentStore!.title.count > 0 {
                textField.text = WhirlpoolRecordStoreManager.manager().currentStore!.title
            }
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "保存", style: .default, handler: { (_) in
            let title_tf = alert.textFields!.first!
            WhirlpoolRecordStoreManager.manager().currentStore!.title = title_tf.text ?? ""
            WhirlpoolRecordStoreManager.manager().currentStore!.save()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func shareBtnTouched(_ sender: Any) {
        WhirlpoolRecordStoreManager.manager().currentStore!.share(vc: self)
    }
    
    func refresh_data() {
        if WhirlpoolRecordStoreManager.manager().currentStore!.isPausing() {
            self.timeLabel.text = TimeHelper.format2ReadableTime(time: WhirlpoolRecordStoreManager.manager().currentStore!.getPausingTimeInterval())
            WhirlpoolRecordStoreManager.manager().currentStore!.flushCurrentRecord()
        } else {
            self.timeLabel.text = TimeHelper.format2ReadableTime(time: WhirlpoolRecordStoreManager.manager().currentStore!.getTimingTimeInterval())
            WhirlpoolRecordStoreManager.manager().currentStore!.flushCurrentRecord()
            self.recordsTableView.reloadRows(at: [IndexPath.init(row: 0, section: 0)], with: UITableView.RowAnimation.none)
        }
    }
    
    func resetTimer() {
        WhirlpoolRecordStoreManager.manager().resetTimer( {(timer) in
            self.refresh_data()})
    }
    
    func setTimingStyle() {
        self.startBtn.setTitle(BTN_TEXT.PAUSE.rawValue, for: .normal)
        self.splitBtn.setTitle(BTN_TEXT.SPLIT.rawValue, for: .normal)
        self.splitBtn.isEnabled = true
    }
    
    func start() {
        WhirlpoolRecordStoreManager.manager().currentStore!.start()
        self.setTimingStyle()
        self.recordsTableView.reloadData()
        
        self.resetTimer()
    }
    
    func goOn() {
        self.saveBtn.isEnabled = false
        self.shareBtn.isEnabled = false
        
        WhirlpoolRecordStoreManager.manager().currentStore!.goOn()

        self.startBtn.setTitle(BTN_TEXT.PAUSE.rawValue, for: .normal)
        self.splitBtn.setTitle(BTN_TEXT.SPLIT.rawValue, for: .normal)
        self.recordsTableView.reloadData()
    }
    
    func setPausingStyle() {
        self.saveBtn.isEnabled = true
        self.shareBtn.isEnabled = true
        
        self.startBtn.setTitle(BTN_TEXT.GO_ON.rawValue, for: .normal)
        self.splitBtn.setTitle(BTN_TEXT.RESET.rawValue, for: .normal)
    }

    func pause() {
        WhirlpoolRecordStoreManager.manager().currentStore!.pause()
        self.setPausingStyle()
        self.timeLabel.text = TimeHelper.format2ReadableTime(time: WhirlpoolRecordStoreManager.manager().currentStore!.getTimingTimeInterval())
        WhirlpoolRecordStoreManager.manager().currentStore!.flushCurrentRecord()
        self.recordsTableView.reloadData()
    }
    
    func reset() {
        WhirlpoolRecordStoreManager.manager().currentStore! = WhirlpoolRecordStoreManager.manager().generateNewCurrentStore()
        
        self.timeLabel.text = self.TIMER_INIT_STR
        self.startBtn.setTitle(BTN_TEXT.START.rawValue, for: .normal)
        self.splitBtn.setTitle(BTN_TEXT.SPLIT.rawValue, for: .disabled)
        self.splitBtn.isEnabled = false
        
        self.saveBtn.isEnabled = false
        self.shareBtn.isEnabled = false
        
        WhirlpoolRecordStoreManager.manager().currentTimer?.invalidate()
        
        self.recordsTableView.reloadData()
    }
    
    func split() {
        WhirlpoolRecordStoreManager.manager().currentStore!.split()
        self.recordsTableView.reloadData()
    }
    
    func do_nothing() {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.recordsTableView.dequeueReusableCell(withIdentifier: "WhirlpoolRecordTableViewCell") as! WhirlpoolRecordTableViewCell
        let record :WhirlpoolRecord? = WhirlpoolRecordStoreManager.manager().currentStore!.get_record(index: WhirlpoolRecordStoreManager.manager().currentStore!.count() - indexPath.row - 1) ?? nil
        if indexPath.row > 0 {
            cell.titleLabel.textColor = .gray
            cell.time1Label.textColor = .lightGray
            cell.time2Label.textColor = .lightGray
        } else if indexPath.row == 0 {
            cell.titleLabel.textColor = .red // UIColor(displayP3Red: 0.27, green: 0.74, blue: 0.6, alpha: 1.0)
            cell.time1Label.textColor = .darkGray
            cell.time2Label.textColor = .darkGray
        }
        if record != nil {
            cell.setRecord(record: record!)
        }
        if WhirlpoolRecordStoreManager.manager().currentStore!.isTiming() && indexPath.row == 0 {
            cell.disableDescTextField()
        } else {
            cell.enableDescTextField()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WhirlpoolRecordStoreManager.manager().currentStore!.count()
    }
    
}

