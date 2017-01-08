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

final class FeaturedBox: BaseObject {
    
    dynamic var id = 0
    dynamic var box: Box? = nil
    
    convenience required init(node: Node, in context: Context = EmptyNode) throws {
        self.init()
        
        id = try node.extract("id")
        box = try node.extract("box")
    }

    override func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: [
            "id" : id,
            "box" : box
        ])
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
