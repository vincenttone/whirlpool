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
    
    let TIMER_INIT_STR = "00:00.0"
    
    enum BTN_TEXT :String {
        case START = "开始"
        case PAUSE = "暂停"
        case SPLIT = "计次"
        case GO_ON = "继续"
        case RESET = "重置"
        case SAVE = "保存"
    }
    
    var recordStore: WhirlpoolRecordStore!
    
    var current_timer: Timer? = nil
    
    @IBOutlet var startBtn: UIButton!
    @IBOutlet var splitBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    
    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet weak var recordsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reset()
        self.recordsTableView.dataSource = self
        self.recordsTableView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func startBtnTouched(_ sender: Any) {
        if self.recordStore.isWaiting() {
            self.start()
        } else if self.recordStore.isTiming() {
            self.pause()
        } else if self.recordStore.isPausing() {
            self.goOn()
        }
    }
    
    @IBAction func splitBtnTouched(_ sender: Any) {
        if self.recordStore.isPausing() {
            self.reset()
        } else if self.recordStore.isTiming() {
            self.split()
        } else if self.recordStore.isWaiting() {
            self.do_nothing()
        }
    }
    @IBAction func saveBtnTouched(_ sender: Any) {
        let alert = UIAlertController(title: "名称", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "请输入记录名称"
            if self.recordStore.title.count > 0 {
                textField.text = self.recordStore.title
            }
        }
        alert.addAction(UIAlertAction(title: "分享", style: .default, handler: { (_) in
            let title_tf = alert.textFields!.first!
            self.recordStore.title = title_tf.text ?? ""
            self.recordStore.share(vc: self)
            
        }))
        alert.addAction(UIAlertAction(title: "保存", style: .default, handler: { (_) in
            let title_tf = alert.textFields!.first!
            self.recordStore.title = title_tf.text ?? ""
            self.recordStore.save()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func refresh_data() {
        if self.recordStore.isPausing() {
            self.timeLabel.text = TimeHelper.format2ReadableTime(time: self.recordStore.getPausingTimeInterval())
            self.recordStore.flushCurrentRecord()
        } else {
            self.timeLabel.text = TimeHelper.format2ReadableTime(time: self.recordStore.getTimingTimeInterval())
            self.recordStore.flushCurrentRecord()
            self.recordsTableView.reloadRows(at: [IndexPath.init(row: 0, section: 0)], with: UITableView.RowAnimation.none)
        }
    }
    
    func start() {
        self.recordStore.start()
        
        self.startBtn.setTitle(BTN_TEXT.PAUSE.rawValue, for: .normal)
        self.splitBtn.setTitle(BTN_TEXT.SPLIT.rawValue, for: .normal)
        self.splitBtn.isEnabled = true
        self.splitBtn.isHidden = false
        
        self.recordsTableView.reloadData()
        
        self.current_timer = Timer.scheduledTimer(
                withTimeInterval: 0.1,
                repeats: true,
                block: { (timer) in
                    self.refresh_data()
                }
            )
    }
    
    func goOn() {
        self.saveBtn.isEnabled = false
        self.saveBtn.isHidden = true
        
        self.recordStore.goOn()

        self.startBtn.setTitle(BTN_TEXT.PAUSE.rawValue, for: .normal)
        self.splitBtn.setTitle(BTN_TEXT.SPLIT.rawValue, for: .normal)
        self.recordsTableView.reloadData()
    }

    func pause() {
        self.recordStore.pause()
        self.saveBtn.isEnabled = true
        self.saveBtn.isHidden = false

        self.startBtn.setTitle(BTN_TEXT.GO_ON.rawValue, for: .normal)
        self.splitBtn.setTitle(BTN_TEXT.RESET.rawValue, for: .normal)
        self.recordsTableView.reloadData()
    }
    
    func reset() {
        self.recordStore = WhirlpoolRecordStore()
        
        self.timeLabel.text = self.TIMER_INIT_STR
        self.startBtn.setTitle(BTN_TEXT.START.rawValue, for: .normal)
        self.splitBtn.setTitle(BTN_TEXT.SPLIT.rawValue, for: .disabled)
        self.splitBtn.isEnabled = false
        self.splitBtn.isHidden = true
        self.saveBtn.isEnabled = false
        self.saveBtn.isHidden = true
        
        self.current_timer?.invalidate()
        
        self.recordsTableView.reloadData()
    }
    
    func split() {
        self.recordStore.split()
        self.recordsTableView.reloadData()
    }
    
    func do_nothing() {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.recordsTableView.dequeueReusableCell(withIdentifier: "WhirlpoolRecordTableViewCell") as! WhirlpoolRecordTableViewCell
        let record :WhirlpoolRecord? = self.recordStore.get_record(index: self.recordStore.count() - indexPath.row - 1) ?? nil
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
        if self.recordStore.isTiming() {
            cell.disableDescTextField()
        } else {
            cell.enableDescTextField()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recordStore.count()
    }
    
}

