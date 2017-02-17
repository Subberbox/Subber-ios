//
//  Moya+Realm.swift
//  instacrate-ios
//
//  Created by Hakon Hanesand on 1/9/17.
//  Copyright © 2017 Instacrate. All rights reserved.
//

import Foundation
import Moya
import Result
import RealmSwift

extension Response {
    
    static let noModifications: (BaseObject) -> (BaseObject) = { object in
        return object
    }
    
    func updateRealmAsRequest(from endpoint: ResponseTargetType, modify: ((BaseObject) -> BaseObject) = noModifications) throws {
        let node = try mapNode()
        let objects = try parse(node: node, from: endpoint)
        
        let prepared = objects.map { (object: BaseObject) -> (BaseObject) in
            object.link(with: objects)
            return modify(object)
        }
        
        print("writing \(objects.count) objects from endpoint \(endpoint.string)")
        
        DispatchQueue.main.async {
            let realm = try! Realm()
            try! realm.write { prepared.forEach { realm.add($0, update: true) } }
        }
    }
}
