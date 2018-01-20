//
//  Category.swift
//  Todoey
//
//  Created by Toan Nguyen on 16.01.18.
//  Copyright © 2018 Toan Nguyen. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name = ""
    @objc dynamic var dateAdded = Date()
    @objc dynamic var color = ""
    let items = List<Item>()
    
}
