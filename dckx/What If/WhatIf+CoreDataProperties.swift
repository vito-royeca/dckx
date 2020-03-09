//
//  WhatIf+CoreDataProperties.swift
//  dckx
//
//  Created by Vito Royeca on 2/28/20.
//  Copyright © 2020 Vito Royeca. All rights reserved.
//
//

import Foundation
import CoreData


extension WhatIf {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WhatIf> {
        return NSFetchRequest<WhatIf>(entityName: "WhatIf")
    }

    @NSManaged public var answer: String?
    @NSManaged public var date: Date?
    @NSManaged public var thumbnail: String?
    @NSManaged public var link: String?
    @NSManaged public var question: String?
    @NSManaged public var questioner: String?
    @NSManaged public var title: String?
    @NSManaged public var num: Int32
    @NSManaged public var isFavorite: Bool
    @NSManaged public var isRead: Bool

}
