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

extension Realm {
    
    var boxes: Results<Box> {
        return objects(Box.self)
    }
}

extension Moya.Response {

    func mapNode(shouldFailOnEmptyData: Bool = true, prettyPrint: Bool = false) throws -> Node {
        return try JSON(serialized: [UInt8](data)).node
    }
}

enum UpdateType {
    case delete
    case modify
    case add

    func apply(changes: [IndexPath], on tableView: UITableView) {
        switch self {
        case .delete:
            tableView.deleteRows(at: changes, with: .automatic)
        case .modify:
            tableView.reloadRows(at: changes, with: .automatic)
        case .add:
            tableView.insertRows(at: changes, with: .automatic)
        }
    }
}

extension Sequence where Iterator.Element == Int {

    func indexPaths(for section: Int) -> [IndexPath] {
        return self.map {
            return IndexPath(row: $0, section: section)
        }
    }
}

extension UITableView {

    func process(updates: [Int], in section: Int, for type: UpdateType) {
        let indexPaths = updates.indexPaths(for: section)
        type.apply(changes: indexPaths, on: self)
    }
}

class BoxTableViewController: UITableViewController {
    
    let boxes = try! Realm().boxes
    let provider = MoyaProvider<Boxes>()
    var token: NotificationToken?

    deinit {
        token?.stop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        provider.request(.boxes(format: .long, curated: .all)) { result in
            if case let .success(response) = result {
                let node = try! response.mapNode()
                let objects = try! parse(node: node, from: Boxes.boxes(format: .long, curated: .all))

                for object in objects {
                    object.link(with: objects)
                }

                let realm = try! Realm()

                try! realm.write {
                    for object in objects {
                        realm.add(object, update: true)
                    }
                }
            }
        }

        token = boxes.addNotificationBlock { (changes: RealmCollectionChange<Results<Box>>) in
            switch changes {
            case .initial(_):
                self.tableView.reloadData()

            case let .update(_, deletions, insertions, modifications):
                self.tableView.beginUpdates()
                self.tableView.process(updates: deletions, in: 0, for: .delete)
                self.tableView.process(updates: insertions, in: 0, for: .add)
                self.tableView.process(updates: modifications, in: 0, for: .modify)
                self.tableView.endUpdates()

            case let .error(error):
                print("Error \(error)")
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
