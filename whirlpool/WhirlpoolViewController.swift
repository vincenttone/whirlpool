//
//  DataViewController.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2019/1/3.
//  Copyright © 2019 Vincent.Tone. All rights reserved.
//

import UIKit
import Foundation

class WhirlpoolViewController: UIViewController {
    
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
    
    var current_state = TIMER_STATE.INIT
    var current_date :Date? = nil
    var pause_time :Date? = nil
    var time_list: [TimeInterval?] = []
    var current_timer: Timer? = nil
    var split_count = 0
    
    
    @IBOutlet var startBtn: UIButton!
    @IBOutlet var splitBtn: UIButton!
    @IBOutlet var saveBtn: UIButton!
    
    @IBOutlet var timeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.reset()
        
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
        
    }
    
    func showLabel() {
        switch self.current_state {
        case TIMER_STATE.PAUSING:
            let pause_interval = self.pause_time?.timeIntervalSince(self.current_date ?? Date.init())
            self.timeLabel.text = self.format2ReadableTime(time: pause_interval ?? 0)
        default:
            self.timeLabel.text = self.format2ReadableTime(time: self.current_date?.timeIntervalSinceNow ?? 0)
        }
        
    }
    
    func start() {
        self.current_date = Date.init()
        self.current_state = TIMER_STATE.TIMING
        self.startBtn.setTitle(BTN_TEXT.PAUSE.rawValue, for: .normal)
        self.splitBtn.setTitle(BTN_TEXT.SPLIT.rawValue, for: .normal)
        self.splitBtn.isEnabled = true
        
        self.current_timer = Timer.scheduledTimer(
                withTimeInterval: 0.1,
                repeats: true,
                block: { (timer) in
                    self.showLabel()
                }
            )
    }
    
    func go_on() {
        let c_date = Date.init()
        self.current_date = Date.init(timeInterval: c_date.timeIntervalSince(self.pause_time ?? c_date), since: self.current_date ?? c_date)
        
        self.current_state = TIMER_STATE.TIMING
        self.startBtn.setTitle(BTN_TEXT.PAUSE.rawValue, for: .normal)
        self.splitBtn.setTitle(BTN_TEXT.SPLIT.rawValue, for: .normal)
        self.saveBtn.isHidden = true
    }

    func pause() {
        self.pause_time = Date.init()
        self.current_state = TIMER_STATE.PAUSING
        self.startBtn.setTitle(BTN_TEXT.GO_ON.rawValue, for: .normal)
        self.splitBtn.setTitle(BTN_TEXT.RESET.rawValue, for: .normal)
        self.saveBtn.isHidden = false
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
    }
    
    func split() {
        self.split_count += 1
        self.timeLabel.text = "split " + self.split_count.description
    }
    
    func do_nothing() {
        
    }
    
    func format2ReadableTime(time: TimeInterval) -> String {
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

}

