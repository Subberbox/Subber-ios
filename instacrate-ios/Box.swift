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

final class Box: Object, ObjectNodeInitializable {

    static let boxBulletSeparator = "<<<>>>"
    
    dynamic var id = 0

    dynamic var name = ""
    dynamic var brief = ""
    dynamic var long_desc = ""
    dynamic var short_desc = ""
    dynamic var bullets = ""
    dynamic var freq = ""
    dynamic var price = 0.0
    dynamic var publish_date = Date()
    dynamic var plan_id: String?
    dynamic var type: String?
    dynamic var vendor_id = 0
    
    dynamic var curatedRaw = Curated.all.rawValue
    
    var curated: Curated {
        get {
            return Curated(rawValue: curatedRaw) ?? .all
        }
        
        set {
            curatedRaw = newValue.rawValue
        }
    }
    
    let categories = List<Category>()
    
    lazy var vendor: Vendor? = { [unowned self] in
        return Vendor.fetch(with: self.vendor_id)
    }()
    
    let pictures = LinkingObjects(fromType: Picture.self, property: "box")
    let reviews = LinkingObjects(fromType: Review.self, property: "box")
    let subscriptions = LinkingObjects(fromType: Subscription.self, property: "box")

    func splitBullets() -> [String] {
        return bullets.components(separatedBy: "<<<>>>")
    }
    
    convenience init(node: Node, in context: Context) throws {
        self.init()
        
        id = try node.extract("id")
        name = try node.extract("name")
        brief = try node.extract("brief")
        long_desc = try node.extract("long_desc")
        short_desc = try node.extract("short_desc")

        bullets = try node.extract("bullets")

        price = try node.extract("price")

        publish_date = (try? node.extract("publish_date") { (value: String) in
            try Date(ISO8601String: value)
        }) ?? Date()

        vendor_id = try node.extract("vendor_id")
        plan_id = try? node.extract("plan_id")
        type = try? node.extract("type")
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "int" : .number(.int(id)),
            "name" : .string(name),
            "brief" : .string(brief),
            "long_desc" : .string(long_desc),
            "short_desc" : .string(short_desc),
            "bullets" : .string(bullets),
            "price" : .number(.double(price)),
            "vendor_id" : .number(.int(vendor_id)),
            "publish_date" : .string(publish_date.ISO8601String),
        ]).add(objects: [
            "plan_id" : plan_id,
            "type" : type
        ])
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    func realmObject() -> Object {
        return self
    }
}
