//
//  CoreDataStack.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2019/1/9.
//  Copyright © 2019 Vincent.Tone. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    let managedObjectModeName: String
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle
    }
    
    required init(modelName: String) {
        managedObjectModeName = modelName
    }
}
