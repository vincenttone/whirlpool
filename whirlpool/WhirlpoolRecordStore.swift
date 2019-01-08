//
//  WhirlpoolRecordStroe.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2019/1/8.
//  Copyright © 2019 Vincent.Tone. All rights reserved.
//
import Foundation

class WhirlpoolRecordStore {
    var records :[WhirlpoolRecord] = []
    
    func append(record :WhirlpoolRecord) {
        self.records.append(record)
    }
    
    func remove(index: Int) -> Bool {
        if self.records.count < index {
            return false
        } else {
            self.records.remove(at: index - 1)
            return true
        }
    }
    
    func get_record(index: Int) -> WhirlpoolRecord? {
        if self.records.count < index {
            return nil
        } else {
            return self.records[index]
        }
    }
    
    func count() -> Int {
        return self.records.count
    }
    
    func clear() {
        records.removeAll()
    }
}
