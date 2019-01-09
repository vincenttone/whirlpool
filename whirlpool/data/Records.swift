//
//  Records+CoreDataClass.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2019/1/9.
//  Copyright © 2019 Vincent.Tone. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Records)
public class Records: NSManagedObject {

    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        uuid = NSUUID().UUIDStrin
        date = Date()
        record = ""
    }
}
