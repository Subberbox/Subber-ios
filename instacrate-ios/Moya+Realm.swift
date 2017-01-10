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

final class NetworkRequestObjectRealmSerializer: PluginType {

    func willSendRequest(_ request: RequestType, target: TargetType) {

    }

    func didReceiveResponse(_ result: Result<Moya.Response, Moya.Error>, target: TargetType) {

        if case let .success(response) = result {

            do {
                let node = try response.mapNode()
                let objects = try parse(node: node, from: Boxes.boxes(format: .long, curated: .all))

                objects.forEach { $0.link(with: objects) }

                let realm = try Realm()
                try realm.write { objects.forEach { realm.add($0, update: true) } }

                print("wrote \(objects.count) to realm")
            } catch {
                print("error while paring request from target \(target). error \(error)")
            }
        }
    }
}

extension MoyaProvider {

    convenience init() {
        self.init(plugins: [NetworkRequestObjectRealmSerializer()])
    }
}
