//
//  UserConfig+CoreDataProperties.swift
//  
//
//  Created by Robert Canton on 2017-10-23.
//
//

import Foundation
import CoreData


extension UserConfig {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserConfig> {
        return NSFetchRequest<UserConfig>(entityName: "UserConfig")
    }

    @NSManaged public var currenttheme: String?

}
