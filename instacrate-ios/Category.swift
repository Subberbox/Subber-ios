//
//  Category.swift
//  subber-api
//
//  Created by Hakon Hanesand on 9/27/16.
//
//

import Foundation
import Node
import RealmSwift

final class Category: BaseObject {
    
    dynamic var id = 0
    dynamic var name = ""
    
    let boxes = LinkingObjects(fromType: Box.self, property: "categories")

    convenience required init(node: Node, in context: Context) throws {
        self.init()
        
        id = try node.extract("id")
        name = try node.extract("name")
    }

    override func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id" : .number(.int(id)),
            "name" : .string(name)
        ])
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
