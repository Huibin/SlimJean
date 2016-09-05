//
//  Record+CoreDataProperties.swift
//  SlimJean
//
//  Created by huibin on 2016-09-04.
//  Copyright © 2016 huibin. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Record {

    @NSManaged var weight: NSNumber?
    @NSManaged var created_on: String?
    @NSManaged var created_at: NSDate?

}
