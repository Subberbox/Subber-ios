//
//  BoxAdvertisingBannerTableViewCell.swift
//  instacrate-ios
//
//  Created by Hakon Hanesand on 2/8/17.
//  Copyright © 2017 Instacrate. All rights reserved.
//

import UIKit

class BoxAdvertisingBannerTableViewCell: UITableViewHeaderFooterView {

    @IBOutlet weak var boxNameLabel: UILabel!
    @IBOutlet weak var boxDescriptionLabel: UILabel!
    @IBOutlet weak var subscribeToBoxButton: UIButton!
    
    func configure(with box: Box) {
        boxNameLabel.text = box.name
        boxDescriptionLabel.text = box.short_desc
    }
}
