//
//  FeaturedBox.swift
//  subber-api
//
//  Created by Hakon Hanesand on 10/12/16.
//
//

import Foundation
import RealmSwift
import Node

final class FeaturedBox: Object, ObjectNodeInitializable {
    
    dynamic var id = 0
    dynamic var box: Box? = nil
    
    convenience init(node: Node, in context: Context = EmptyNode) throws {
        self.init()
        
        id = try node.extract("id")
        box = try node.extract("box")
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    func realmObject() -> Object {
        return self
    }
}
