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

final class Picture: BaseObject {
    
    dynamic var id = 0
    dynamic var url = ""
    
    dynamic var box: Box? = nil

    var box_id: Int?
    
    convenience required init(node: Node, in context: Context = EmptyNode) throws {
        self.init()

        id = try node.extract("id")

        url = try node.extract("url")
        box_id = try node.extract("box_id")
    }

    override func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id" : .number(.int(id)),
            "url" : .string(url),
            "box_id" : .number(.int(box_id!))
        ])
    }

    override func link(with objects: [BaseObject]) {
        if let box_id = box_id {
            box = objects.find(primaryKey: box_id)
        }
    }

    override class func primaryKey() -> String? {
        return "id"
    }
}
