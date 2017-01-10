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

    func apply(updates: [Int], in section: Int, for type: UpdateType) {
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

        title = "Instacrate"
        
        provider.request(.boxes(format: .long, curated: .all)) { result in }

        token = boxes.addNotificationBlock { (changes: RealmCollectionChange<Results<Box>>) in
            switch changes {
            case .initial(_):
                self.tableView.reloadData()

            case let .update(_, deletions, insertions, modifications):
                self.tableView.beginUpdates()
                self.tableView.apply(updates: deletions, in: 0, for: .delete)
                self.tableView.apply(updates: insertions, in: 0, for: .add)
                self.tableView.apply(updates: modifications, in: 0, for: .modify)
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
        let cell: BoxTableViewCell

        if indexPath.row % 2 == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "BoxTableViewCell", for: indexPath) as! BoxTableViewCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "BoxTableViewCellFlipped", for: indexPath) as! BoxTableViewCell
        }

        let box = boxes[indexPath.row]
        
        cell.boxNameLabel.text = box.name
        cell.boxDescriptionLabel.text = box.brief

        let rating: Double? = box.reviews.average(ofProperty: "rating")
        cell.ratingLabel.text = String(format: "%.1f", rating ?? 4.2)
        
        if let string = box.pictures.first?.url, let url = URL(string: string) {
            image.loadImage(with: url, into: cell.boxImageView)
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let box = boxes[indexPath.row]

        let boxViewController = BoxViewController(boxPrimaryKey: box.id)
        navigationController?.pushViewController(boxViewController, animated: true)
    }
}
