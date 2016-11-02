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

let store = try! Realm()

extension Realm {
    
    var boxes: Results<Box> {
        return objects(Box.self)
    }
}

class BoxTableViewController: UITableViewController {
    
    let boxes = store.boxes
    let provider = MoyaProvider<Boxes>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        provider.request(.all) { result in
            if case let .success(response) = result {
                let json = try! response.mapJSON()
                
                try! collectResultsFrom(json: json, forEndpoint: Boxes.all.responseType).forEach {
                    print($0)
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
