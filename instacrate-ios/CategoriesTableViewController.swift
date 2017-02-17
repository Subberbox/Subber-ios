//
//  CategoriesTableViewController.swift
//  instacrate-ios
//
//  Created by Hakon Hanesand on 2/7/17.
//  Copyright © 2017 Instacrate. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Nuke
import Moya

extension Realm {
    
    var categories: Results<Category> {
        return objects(Category.self)
    }
}

class CategoriesTableViewController: UITableViewController {
    
    let categories = try! Realm().categories
    let provider = MoyaProvider<Categories>()
    var token: NotificationToken?
    
    deinit {
        token?.stop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "\(CategoryTableViewCell.self)", bundle: nil), forCellReuseIdentifier: "\(CategoryTableViewCell.self)")
        
        navigationController?.tabBarItem = UITabBarItem(title: "Categories", image: nil, selectedImage: nil)
        
        provider.request(.categories) { response in
            switch response {
            case let .success(result):
                // TODO : error handling
                try! result.updateRealmAsRequest(from: Categories.categories)
            
            case let .failure(error):
                print("error on categories \(error)")
            }
        }
        
        token = categories.addNotificationBlock { changes in
            self.tableView.handle(changes: changes)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "\(CategoryTableViewCell.self)", for: indexPath) as! CategoryTableViewCell
        tableViewCell.configure(with: categories[indexPath.row])
        return tableViewCell
    }
}
