//
//  BoxTableViewController.swift
//  instacrate-ios
//
//  Created by Hakon Hanesand on 10/31/16.
//  Copyright © 2016 Instacrate. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Nuke
import Moya
import Jay

let store = try! Realm()

extension Realm {
    
    var boxes: Results<Box> {
        return objects(Box.self)
    }
}

extension Moya.Response {

    func nativeMapJSON(shouldFailOnEmptyData: Bool = true, prettyPrint: Bool = false) throws -> JSON {
        let formatting: Jay.Formatting = prettyPrint ? .prettified : .minified
        return try Jay(formatting: formatting).jsonFromData([UInt8](data))
    }
}

class BoxTableViewController: UITableViewController {
    
    let boxes = store.boxes
    let provider = MoyaProvider<Boxes>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        provider.request(.all(format: .long)) { result in
            if case let .success(response) = result {
                let json = try! response.nativeMapJSON()
                let objects = try! parse(json: json, from: Boxes.all(format: .long))

                try! Realm().write {
                    for object in objects {
                        try! Realm().add(object, update: true)
                    }
                }
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return boxes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BoxTableViewCell", for: indexPath) as! BoxTableViewCell
        let box = boxes[indexPath.row]
        
        cell.boxNameLabel.text = box.name
        cell.boxDescriptionLabel.text = box.description
        
        if let string = box.pictures.first?.url, let url = URL(string: string) {
            image.loadImage(with: url, into: cell.boxImageView)
        }
        
        return cell
    }
    
}
