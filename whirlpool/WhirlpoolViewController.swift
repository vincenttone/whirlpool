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
    
    var uuid: String? = nil
    var timer_title = ""
    var begin_date: Date = Date()
    var end_date: Date? = nil
    
    var current_state = TIMER_STATE.INIT
    var current_date :Date? = nil
    var pause_time :Date? = nil
    var split_time: Date? = nil
    var time_list: [TimeInterval?] = []
    var current_timer: Timer? = nil
    var split_count = 0
    
    @IBOutlet var startBtn: UIButton!
    @IBOutlet var splitBtn: UIButton!
    
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
    
    func refresh() {
        switch self.current_state {
        case TIMER_STATE.PAUSING:
            let pause_interval = self.pause_time?.timeIntervalSince(self.current_date ?? Date.init())
            self.timeLabel.text = TimeHelper.format2ReadableTime(time: pause_interval ?? 0)
            
            self.current_record?.time = self.pause_time?.timeIntervalSince(self.split_time ?? Date.init())
            self.current_record?.time_far = pause_interval
        default:
            let time_far = self.current_date?.timeIntervalSinceNow ?? 0
            self.timeLabel.text = TimeHelper.format2ReadableTime(time: time_far)
            
            self.current_record?.time = self.split_time?.timeIntervalSince(Date.init()) ?? 0
            self.current_record?.time_far = time_far
            self.recordsTableView.reloadRows(at: [IndexPath.init(row: 0, section: 0)], with: UITableView.RowAnimation.none)
        }
    }
    
    func start() {
        self.uuid = NSUUID().uuidString
        self.current_date = Date.init()
        self.begin_date = self.current_date!
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
        self.recordsTableView.reloadData()
    }

    func pause() {
        self.pause_time = Date.init()
        self.end_date = self.pause_time
        self.current_state = TIMER_STATE.PAUSING
        self.startBtn.setTitle(BTN_TEXT.GO_ON.rawValue, for: .normal)
        self.splitBtn.setTitle(BTN_TEXT.RESET.rawValue, for: .normal)
        self.recordsTableView.reloadData()
    }
    
    func reset() {
        self.timer_title = ""
        self.end_date = nil
        self.current_state = TIMER_STATE.INIT
        self.timeLabel.text = self.TIMER_INIT_STR
        self.startBtn.setTitle(BTN_TEXT.START.rawValue, for: .normal)
        self.splitBtn.setTitle(BTN_TEXT.SPLIT.rawValue, for: .disabled)
        self.splitBtn.isEnabled = false
        self.splitBtn.setTitleColor(.gray, for: .disabled)
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var base = 0
        if self.current_state == .PAUSING {
            base = 1
            if indexPath.row == 0 {
                let tbCell = self.recordsTableView.dequeueReusableCell(withIdentifier: "WhirlPoolToolbarTableViewCell") as! WhirlpoolToolbarTableViewCell
                tbCell.basedViewController = self
                var records = self.recordStore.records
                if self.current_record != nil {
                    records.append(self.current_record!)
                }
                tbCell.records = records
                if self.uuid != tbCell.uuid {
                    tbCell.uuid = self.uuid
                    tbCell.nameTextField.text = ""
                }
                return tbCell
            }
        }
        let cell = self.recordsTableView.dequeueReusableCell(withIdentifier: "WhirlpoolRecordTableViewCell") as! WhirlpoolRecordTableViewCell
        var record :WhirlpoolRecord!
        if indexPath.row > base {
            record = self.recordStore.get_record(index: self.recordStore.count() + base - indexPath.row)
            cell.titleLabel.textColor = .gray
            cell.time1Label.textColor = .lightGray
            cell.time2Label.textColor = .lightGray
        } else if indexPath.row == base {
            record = self.current_record
            if base == 0 {
                cell.titleLabel.textColor = .red
                cell.time1Label.textColor = .darkGray
                cell.time2Label.textColor = .darkGray
            } else {
                cell.titleLabel.textColor = .gray
                cell.time1Label.textColor = .lightGray
                cell.time2Label.textColor = .lightGray
            }
        }
        cell.setRecord(record: record)
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
        } else if self.current_state == .PAUSING {
            return self.recordStore.count() + 2
        } else {
            return self.recordStore.count() + 1
        }
    }
    
}

