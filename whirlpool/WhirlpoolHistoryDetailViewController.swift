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
    var editingIndexPath: IndexPath?
    var deletedCallback: (() -> Void)?
    
    var selectedIndexPath: IndexPath?
    
    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var shareBtn: UIBarButtonItem!
    
    @IBAction func shareBtnTouched(_ sender: Any) {
        self.recordStore.share(vc: self, shareItem: shareBtn)
    }
    
    @IBAction func deleteBtnTouched(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("DELETE_CONFIRM", comment: "confirm deletion"), message: self.recordStore.title, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: NSLocalizedString("CANCEL", comment: "取消"), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "确认"), style: .default, handler: { (_ sender: Any?) in
            do {
                try WhirlpoolRecordStoreManager.deleteHistory(uuid: self.recordStore.uuid)
                self.navigationController?.popViewController(animated: true)
                self.deletedCallback?()
            } catch {
                dump(error)
                let alert_failed = UIAlertController(title: NSLocalizedString("DELETE_FAILED", comment: "删除失败"), message: self.recordStore.title, preferredStyle: .alert)
                alert_failed.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "确认"), style: .default, handler: nil))
                self.present(alert_failed, animated: true, completion: nil)
                return
            }
        }))
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        self.detailTableView.delegate = self
        self.detailTableView.dataSource = self
        self.navigationItem.title = self.history.title
        super.viewDidLoad()
        self.detailTableView.register(UINib(nibName: "WhirlpoolTimerTableViewCell", bundle: nil), forCellReuseIdentifier: "WhirlpoolTimerTableViewCell")
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(note:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(note:)), name: UIResponder.keyboardDidHideNotification, object: nil)
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
        cell.beginEditingCallback = { () in
            self.editingIndexPath = indexPath
        }
        /*
        if cell.commentTextField.text == "" {
            cell.commentTextField.placeholder = NSLocalizedString("ADD_COMMENT", comment: "add comment")
        }
        */
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recordStore.count()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        let cell = tableView.cellForRow(at: indexPath) as! WhirlpoolTimerTableViewCell
        cell.commentTextField.becomeFirstResponder()
    }
    
    @objc func keyboardWillShow(note: NSNotification) {
        let info = note.userInfo!
        let kbSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
        self.detailTableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: kbSize.height, right: 0)
        if self.editingIndexPath != nil {
            UIView.animate(withDuration: 0.2, animations: {() in
                self.detailTableView.scrollToRow(at: self.editingIndexPath!, at: .middle, animated: false)
            })
        }
    }
    
    @objc func keyboardWillHide(note: NSNotification) {
        if self.selectedIndexPath != nil {
            self.detailTableView.deselectRow(at: self.selectedIndexPath!, animated: true)
            self.selectedIndexPath = nil
        }
        UIView.animate(withDuration: 0.5, animations: {() in
            self.detailTableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        })
    }
}
