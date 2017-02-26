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

extension Sequence where Iterator.Element : Object {

    func find<T: Object>(primaryKey: Int) -> T? {
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

final class Customer: Object, ObjectNodeInitializable {
    
    dynamic var id: Int = 0
    
    dynamic var name: String = ""
    dynamic var email: String = ""
    dynamic var stripe_id: String?
    dynamic var defaultShipping: Shipping? = nil

    var defaultShippingId: Int?
    
    let reviews = LinkingObjects(fromType: Review.self, property: "customer")
    let sessions = LinkingObjects(fromType: Session.self, property: "customer")
    let addresses = LinkingObjects(fromType: Shipping.self, property: "customer")

    convenience init(node: Node, in context: Context) throws {
        self.init()

        id = try node.extract("id")
        email = try node.extract("email")
        name = try node.extract("name")
        stripe_id = try? node.extract("stripe_id")
        defaultShippingId = try? node.extract("default_shipping")
    }

    override class func primaryKey() -> String? {
        return "id"
    }
    
    func realmObject() -> Object {
        return self
    }
}
