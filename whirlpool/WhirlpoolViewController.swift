//
//  DataViewController.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2019/1/3.
//  Copyright © 2019 Vincent.Tone. All rights reserved.
//

import UIKit
import Foundation

class WhirlpoolViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let TIMER_INIT_STR = "00:00.0"

    enum TIMER_STATE {
        case INIT
        case TIMING
        case PAUSING
    }
    
    enum SECONDS_LIMIT :Double{
        case DAY = 86400
        case HOUR = 3600
        case MINUTES = 60
    }
    
    enum BTN_TEXT :String {
        case START = "开始"
        case PAUSE = "暂停"
        case SPLIT = "计次"
        case GO_ON = "继续"
        case RESET = "重置"
        case SAVE = "保存"
    }
    
    var recordStore = WhirlpoolRecordStore()
    var current_record :WhirlpoolRecord?
    
    var current_state = TIMER_STATE.INIT
    var current_date :Date? = nil
    var pause_time :Date? = nil
    var split_time: Date? = nil
    var time_list: [TimeInterval?] = []
    var current_timer: Timer? = nil
    var split_count = 0
    
    @IBOutlet var startBtn: UIButton!
    @IBOutlet var splitBtn: UIButton!
    @IBOutlet var saveBtn: UIButton!
    
    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet weak var recordsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.reset()
        self.recordsTableView.dataSource = self
        self.recordsTableView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func startBtnTouched(_ sender: Any) {
        switch self.current_state {
        case TIMER_STATE.INIT:
            self.start()
        case TIMER_STATE.TIMING:
            self.pause()
        case TIMER_STATE.PAUSING:
            self.go_on()
        }
    }
    
    @IBAction func splitBtnTouched(_ sender: Any) {
        switch self.current_state {
        case TIMER_STATE.PAUSING:
            self.reset()
        case TIMER_STATE.TIMING:
            self.split()
        case TIMER_STATE.INIT:
            self.do_nothing()
        }
    }
    
    @IBAction func saveBtnTouched(_ sender: Any) {
        var records = self.recordStore.records
        if self.current_record != nil {
            records.append(self.current_record!)
        }
        var out_str = ""
        for r in records {
            out_str += r.description + "\n"
        }
        print(out_str)
        
        let modal = UIAlertController(title: "导出名称", message: "", preferredStyle: .alert)
        modal.addTextField(configurationHandler:{ (textField: UITextField) in
            textField.placeholder = "请输入导出的名称"
        })
        modal.addAction( UIAlertAction(title: "取消", style: .cancel, handler: nil))
        modal.addAction( UIAlertAction(title: "导出", style: .default, handler: { (_) in
            let tf = modal.textFields![0]
            let title = tf.text ?? "A record"
            let items = [title, out_str, "http://www.vii.red"]
            
            let avc = UIActivityViewController(activityItems: items, applicationActivities: nil)
            avc.completionWithItemsHandler = {act, success, items, error in print(error ?? "ok") }
            self.present(avc, animated: true)
        }))
        self.present(modal, animated: true, completion: { () in
            print("done")
        })
        
        
        
    }
    
    func refresh() {
        switch self.current_state {
        case TIMER_STATE.PAUSING:
            let pause_interval = self.pause_time?.timeIntervalSince(self.current_date ?? Date.init())
            self.timeLabel.text = self.format2ReadableTime(time: pause_interval ?? 0)
            
            self.current_record?.time = self.pause_time?.timeIntervalSince(self.split_time ?? Date.init())
            self.current_record?.time_far = pause_interval
        default:
            let time_far = self.current_date?.timeIntervalSinceNow ?? 0
            self.timeLabel.text = self.format2ReadableTime(time: time_far)
            
            self.current_record?.time = self.split_time?.timeIntervalSince(Date.init()) ?? 0
            self.current_record?.time_far = time_far
            self.recordsTableView.reloadRows(at: [IndexPath.init(row: 0, section: 0)], with: UITableView.RowAnimation.none)
        }
    }
    
    func start() {
        self.current_date = Date.init()
        self.current_state = TIMER_STATE.TIMING
        self.startBtn.setTitle(BTN_TEXT.PAUSE.rawValue, for: .normal)
        self.splitBtn.setTitle(BTN_TEXT.SPLIT.rawValue, for: .normal)
        self.splitBtn.isEnabled = true
        
        self.current_record = WhirlpoolRecord(num: 1, time: 0, time_far: 0)
        self.recordsTableView.reloadData()
        
        self.current_timer = Timer.scheduledTimer(
                withTimeInterval: 0.1,
                repeats: true,
                block: { (timer) in
                    self.refresh()
                }
            )
    }
    
    func go_on() {
        let c_date = Date.init()
        self.current_date = Date.init(timeInterval: c_date.timeIntervalSince(self.pause_time ?? c_date), since: self.current_date ?? c_date)
        self.split_time = Date.init(timeInterval: c_date.timeIntervalSince(self.pause_time ?? c_date), since: self.split_time ?? c_date)
        
        self.current_state = TIMER_STATE.TIMING
        self.startBtn.setTitle(BTN_TEXT.PAUSE.rawValue, for: .normal)
        self.splitBtn.setTitle(BTN_TEXT.SPLIT.rawValue, for: .normal)
        self.saveBtn.isHidden = true
        self.recordsTableView.reloadData()
    }

    func pause() {
        self.pause_time = Date.init()
        self.current_state = TIMER_STATE.PAUSING
        self.startBtn.setTitle(BTN_TEXT.GO_ON.rawValue, for: .normal)
        self.splitBtn.setTitle(BTN_TEXT.RESET.rawValue, for: .normal)
        self.saveBtn.isHidden = false
        self.recordsTableView.reloadData()
    }
    
    func reset() {
        self.current_state = TIMER_STATE.INIT
        self.timeLabel.text = self.TIMER_INIT_STR
        self.startBtn.setTitle(BTN_TEXT.START.rawValue, for: .normal)
        self.splitBtn.setTitle(BTN_TEXT.SPLIT.rawValue, for: .disabled)
        self.saveBtn.setTitle(BTN_TEXT.SAVE.rawValue, for: .normal)
        self.splitBtn.isEnabled = false
        self.saveBtn.isHidden = true
        self.current_timer?.invalidate()
        self.current_date = nil
        
        self.split_count = 0
        self.current_record = nil
        self.recordStore = WhirlpoolRecordStore()
        self.recordsTableView.reloadData()
    }
    
    func split() {
        self.split_count += 1
        let pre_split_time = self.split_time ?? (self.current_date ?? Date.init())
        self.split_time = Date.init()
        self.recordStore.append(record:
            WhirlpoolRecord(
                num: self.split_count,
                time: self.split_time?.timeIntervalSince(pre_split_time) ?? 0.0,
                time_far: self.split_time?.timeIntervalSince(self.current_date ?? Date.init()) ?? 0.0
            )
        )
        self.current_record?.num = self.split_count + 1 //self.recordStore.count()
        self.recordsTableView.reloadData()
    }
    
    func do_nothing() {
        
    }
    
    func format2ReadableTime(time: TimeInterval) -> String {
        if time == 0 {
            return TIMER_INIT_STR
        }
        let timed = fabs(Double(time))
        let day = Int(floor(timed / SECONDS_LIMIT.DAY.rawValue))
        let hours = Int(floor(timed / SECONDS_LIMIT.HOUR.rawValue))
        let minutes = Int(floor(timed.truncatingRemainder(dividingBy: SECONDS_LIMIT.HOUR.rawValue) / SECONDS_LIMIT.MINUTES.rawValue))
        let seconds = timed.truncatingRemainder(dividingBy: SECONDS_LIMIT.MINUTES.rawValue)
        if day > 0 {
            return String(format: "%d,%02d:%02d", day, hours, minutes)
        } else if hours > 0 {
            return String(format: "%02d:%02d:%04.1f", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%04.1f", minutes, seconds)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.recordsTableView.dequeueReusableCell(withIdentifier: "WhirlpoolRecordTableViewCell") as! WhirlpoolRecordTableViewCell
        var record :WhirlpoolRecord!
        if indexPath.row > 0 {
            record = self.recordStore.get_record(index: self.recordStore.count() - indexPath.row)
            cell.titleLabel.textColor = .gray
            cell.time1Label.textColor = .lightGray
            cell.time2Label.textColor = .lightGray
        } else {
            record = self.current_record
            cell.titleLabel.textColor = .red
            cell.time1Label.textColor = .darkGray
            cell.time2Label.textColor = .darkGray
        }
        cell.setRecord(record: record)
        //cell.updateData(num: record?.num ?? 0, t1: self.format2ReadableTime(time: record?.time ?? 0) , t2: self.format2ReadableTime(time: record?.time_far ?? 0))
        if self.current_state == TIMER_STATE.TIMING {
            cell.disableDescTextField()
        } else {
            cell.enableDescTextField()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.current_record == nil {
            return 0
        } else {
            return self.recordStore.count() + 1
        }
    }
    
}

