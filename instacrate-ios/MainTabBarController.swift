//
//  MainTabBarController.swift
//  instacrate-ios
//
//  Created by Hakon Hanesand on 2/7/17.
//  Copyright © 2017 Instacrate. All rights reserved.
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewControllers = defaultViewControllers()
    }
    
    func defaultViewControllers() -> [UIViewController] {
        let boxTableViewController = MainPageTableViewController()
        let categoriesTableViewController = CategoriesTableViewController()
        
        return [UINavigationController(rootViewController: boxTableViewController), UINavigationController(rootViewController: categoriesTableViewController)]
    }
}
