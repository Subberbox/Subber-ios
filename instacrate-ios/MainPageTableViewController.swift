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

extension UITableView {
    
    func handle<T: Object>(changes: RealmCollectionChange<Results<T>>, in section: Int = 0) {
        print(section)
        switch changes {
        case .initial(_):
            return
            
        case let .update(_, deletions, insertions, modifications):
            beginUpdates()
            insertRows(at: insertions.map { IndexPath(row: $0, section: section) }, with: .automatic)
            deleteRows(at: deletions.map { IndexPath(row: $0, section: section) }, with: .automatic)
            reloadRows(at: modifications.map { IndexPath(row: $0, section: section) }, with: .automatic)
            endUpdates()
            
        case let .error(error):
            print("Error \(error)")
        }
    }
}

class MainPageTableViewController: UITableViewController {
    
    var dataSource: MainPageDatasource!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Instacrate"
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 144
        
        navigationController?.tabBarItem = UITabBarItem(title: "Boxes", image: nil, selectedImage: nil)
        
        dataSource = MainPageDatasource(tableView: tableView)
        tableView.dataSource = dataSource
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let box = dataSource.object(for: indexPath)
        
        guard let boxViewController = BoxViewController(box: box.id) else {
            return
        }
        
        self.navigationController?.pushViewController(boxViewController, animated: true)
    }
}
