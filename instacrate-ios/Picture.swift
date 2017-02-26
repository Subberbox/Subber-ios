//
//  Picture.swift
//  subber-api
//
//  Created by Hakon Hanesand on 9/27/16.
//
//

import Foundation
import Node
import RealmSwift

final class Picture: Object, ObjectNodeInitializable {
    
    dynamic var id = 0
    
    dynamic var url = ""
    dynamic var box: Box? = nil
    dynamic var box_id: Int = 0
    
    convenience required init(node: Node, in context: Context = EmptyNode) throws {
        self.init()

        id = try node.extract("id")

        url = try node.extract("url")
        box_id = try node.extract("box_id")
    }

    override class func primaryKey() -> String? {
        return "id"
    }
    
    func realmObject() -> Object {
        return self
    }
}
