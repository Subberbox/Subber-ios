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

extension Sequence where Iterator.Element : BaseObject {

    func find<T: BaseObject>(primaryKey: Int) -> T? {
        for object in self {
            guard let object = object as? T else {
                continue
            }

            guard let objectPrimaryKey = object.value(forKey: T.primaryKey() ?? "id") as? Int else {
                continue
            }

            if objectPrimaryKey == primaryKey {
                return object
            }
        }

        return nil
    }
}

final class Customer: BaseObject {
    
    dynamic var id: Int = 0
    
    dynamic var name: String = ""
    dynamic var email: String = ""
    dynamic var stripe_id: String?
    dynamic var defaultShipping: Shipping? = nil

    var defaultShippingId: Int?
    
    let reviews = LinkingObjects(fromType: Review.self, property: "customer")
    let sessions = LinkingObjects(fromType: Session.self, property: "customer")
    let addresses = LinkingObjects(fromType: Shipping.self, property: "customer")

    convenience required init(node: Node, in context: Context) throws {
        self.init()

        id = try node.extract("id")
        email = try node.extract("email")
        name = try node.extract("name")
        stripe_id = try? node.extract("stripe_id")
        defaultShippingId = try? node.extract("default_shipping")
    }

    override func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "name" : .string(name),
            "email" : .string(email),
            "id" : .number(.int(id))
            ]).add(objects: ["stripe_id" : stripe_id,
                             "default_shipping" : defaultShipping?.makeNode()])
    }

    override func link(with objects: [BaseObject]) {
        if let defaultShippingId = defaultShippingId {
            defaultShipping = objects.find(primaryKey: defaultShippingId)
        }
    }

    override class func primaryKey() -> String? {
        return "id"
    }
}
