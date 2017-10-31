//
//  ThemeEntity+CoreDataProperties.swift
//  
//
//  Created by Robert Canton on 2017-10-23.
//
//

import Foundation
import CoreData


extension ThemeEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ThemeEntity> {
        return NSFetchRequest<ThemeEntity>(entityName: "ThemeEntity")
    }

    @NSManaged public var name: String?
    @NSManaged public var backgroundColor: NSObject?
    @NSManaged public var titleColor: NSObject?
    @NSManaged public var subtitleColor: NSObject?
    @NSManaged public var buttonColor: NSObject?
    @NSManaged public var buttonBackgroundColor: NSObject?
    @NSManaged public var detailPrimaryColor: NSObject?
    @NSManaged public var detailSecondaryColor: NSObject?
    @NSManaged public var musicBarBackgroundColor: NSObject?
    @NSManaged public var musicBarColorAlpha: Int16
    @NSManaged public var musicBarBlurIntensity: Int16

}
