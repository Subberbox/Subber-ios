//
//  CategoryTableViewCell.swift
//  instacrate-ios
//
//  Created by Hakon Hanesand on 2/7/17.
//  Copyright © 2017 Instacrate. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var categoryNameLabel: UILabel!
    
    func configure(with category: Category) {
        categoryNameLabel.text = category.name
    }
}
