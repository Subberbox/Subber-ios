//
//  File.swift
//  subber-api
//
//  Created by Hakon Hanesand on 9/27/16.
//
//

import Foundation
import Node
import RealmSwift

final class Customer: BaseObject {
    
    dynamic var id: Int = 0
    
    dynamic var name: String = ""
    dynamic var email: String = ""
    dynamic var stripe_id: String?
    dynamic var defaultShipping: Shipping? = nil

    let defaultShippingId: Int? = 0
    
    let reviews = LinkingObjects(fromType: Review.self, property: "user")
    let sessions = LinkingObjects(fromType: Session.self, property: "user")
    let addresses = LinkingObjects(fromType: Shipping.self, property: "user")

    convenience required init(node: Node, in context: Context) throws {
        self.init()

        id = try node.extract("id")
        defaultShipping = try? node.extract("default_shipping")
        email = try node.extract("email")
        name = try node.extract("name")
        stripe_id = try? node.extract("stripe_id")
    }

    override func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "name" : .string(name),
            "email" : .string(email),
            "id" : .number(.int(id))
            ]).add(objects: ["stripe_id" : stripe_id,
                             "default_shipping" : defaultShipping?.makeNode()])
    }

    override func link() throws {
        if let defaultShippingId = defaultShippingId {
            defaultShipping = try Realm().object(ofType: Shipping.self, forPrimaryKey: defaultShippingId)
        }
    }

    override class func primaryKey() -> String? {
        return "id"
    }
}
