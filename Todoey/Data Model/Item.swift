//
//  Item.swift
//  Todoey
//
//  Created by Toan Nguyen on 16.01.18.
//  Copyright © 2018 Toan Nguyen. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title = ""
    @objc dynamic var done = false
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
