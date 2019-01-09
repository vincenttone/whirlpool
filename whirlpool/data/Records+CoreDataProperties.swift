//
//  Records+CoreDataProperties.swift
//  whirlpool
//
//  Created by Vincent.Tone on 2019/1/9.
//  Copyright © 2019 Vincent.Tone. All rights reserved.
//
//

import Foundation
import CoreData

extension Records {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Records> {
        return NSFetchRequest<Records>(entityName: "Records")
    }

    @NSManaged public var uuid: String
    @NSManaged public var record: String
    @NSManaged public var date: NSDate

}
