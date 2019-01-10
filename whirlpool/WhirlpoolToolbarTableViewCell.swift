//
//  WhirlpoolToolbarTableViewCell.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2019/1/10.
//  Copyright © 2019 Vincent.Tone. All rights reserved.
//

import UIKit
import CoreData

class WhirlpoolToolbarTableViewCell: UITableViewCell {
    
    var uuid: String? = nil
    var records: [WhirlpoolRecord]? = nil
    var basedViewController: WhirlpoolViewController!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    
    @IBAction func didEndEditing(_ sender: Any) {
        self.nameTextField.resignFirstResponder()
    }
    @IBAction func editChanged(_ sender: Any) {
        self.basedViewController.timer_title = self.nameTextField.text ?? ""
    }
    
    @IBAction func shareBtnTouched(_ sender: Any) {
        if self.records == nil || self.records?.count == 0 {
            return
        }
        let dateFmter = DateFormatter()
        dateFmter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        var out_str = self.nameTextField.text ?? ""
        if out_str != "" { out_str += "\n"}
        out_str +=  dateFmter.string(from: self.basedViewController.begin_date)
        for r in self.records! {
            out_str += "\n" + r.description 
        }
        /*
        if self.basedViewController.end_date != nil {
            out_str += "\n" + dateFmter.string(from: self.basedViewController.end_date!)
        }
         */
        let items = [out_str]
        
        let avc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        avc.completionWithItemsHandler = {act, success, items, error in print(error ?? "ok") }
        self.basedViewController.present(avc, animated: true)
    }
    
    @IBAction func saveBtnTouched(_ sender: Any) {
        if self.records == nil || self.records?.count == 0 {
            return
        }
        let uuid = self.basedViewController.uuid
        if uuid == nil {
            return
        }
        
        let name = self.nameTextField.text ?? ""
        
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        
        
        var saved = false
        let fbr = NSFetchRequest<Batches>(entityName: "Batches")
        fbr.fetchLimit = 1
        fbr.fetchOffset = 0
        do {
            let fbp = NSPredicate(format: "uuid=\"\(uuid!)\"", "")
            fbr.predicate = fbp
            let fetchedBatch = try context.fetch(fbr)
            if fetchedBatch.count > 0 {
                saved = true
                print("batch saved before!", fetchedBatch)
            }
        } catch {
            print("fetch batch info failed!")
        }
        
        
        if saved { // remove old records
            let fetchRequest = NSFetchRequest<Records>(entityName: "Records")
            // fetchRequest.fetchLimit = 300
            // fetchRequest.fetchOffset = 0
            do {
                let predicate = NSPredicate(format: "uuid=\"\(uuid!)\"", "")
                fetchRequest.predicate = predicate
                let fetchObjects = try context.fetch(fetchRequest)
                if fetchObjects.count > 0 {
                    for i in fetchObjects {
                        context.delete(i)
                    }
                }
            } catch {
                print("fetch failed!!!")
            }
        } else { // insert batches
            let b = NSEntityDescription.insertNewObject(forEntityName: "Batches", into: context) as! Batches
            b.uuid = uuid
            b.title = name
            b.date = Date()
            b.count = Int32(self.records?.count ?? 0)
            
            do {
                try context.save()
                print("saved ok!!!")
            } catch {
                print("save failed!")
            }
        }
        // save records
        let rtx = NSEntityDescription.insertNewObject(forEntityName: "Records", into: context) as! Records
        if self.records != nil {
            for r in self.records! {
                rtx.uuid = uuid
                rtx.desc = r.desc
                rtx.t1 = r.time
                rtx.t2 = r.time_far ?? 0
            }
        }
    }
}
