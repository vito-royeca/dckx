//
//  Comic+CoreDataProperties.swift
//  dckx
//
//  Created by Vito Royeca on 2/22/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//
//

import Foundation
import CoreData


extension Comic {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Comic> {
        return NSFetchRequest<Comic>(entityName: "Comic")
    }

    @NSManaged public var alt: String?
    @NSManaged public var day: Int16
    @NSManaged public var img: String?
    @NSManaged public var link: String?
    @NSManaged public var month: Int16
    @NSManaged public var news: String?
    @NSManaged public var num: Int32
    @NSManaged public var safeTitle: String?
    @NSManaged public var title: String?
    @NSManaged public var transcript: String?
    @NSManaged public var year: Int16
    @NSManaged public var isFavorite: Bool

}
