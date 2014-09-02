//
//  Cast_My_Videos.swift
//  Cast My Videos
//
//  Created by Sandeep Koirala on 21/07/14.
//  Copyright (c) 2014 caster. All rights reserved.
//

import Foundation
import CoreData



class Item: NSManagedObject {

    @NSManaged var url: String?
    @NSManaged var title: String?
    @NSManaged var duration: String?
    @NSManaged var content: String?
    @NSManaged var year: String?
    @NSManaged var favorite: Favorite?
    @NSManaged var userDefined: ObjCBool
  
  
}
