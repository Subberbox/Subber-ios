//
//  BoxTableViewCell.swift
//  instacrate-ios
//
//  Created by Hakon Hanesand on 10/31/16.
//  Copyright © 2016 Instacrate. All rights reserved.
//

import Foundation
import UIKit
import Nuke

class BoxTableViewCell: UITableViewCell {
    
    @IBOutlet weak var boxNameLabel: UILabel!
    @IBOutlet weak var vendorNameLabel: UILabel!

    @IBOutlet weak var ratingLabel: UILabel!

    @IBOutlet weak var boxDescriptionLabel: UILabel!
    @IBOutlet weak var boxImageView: UIImageView!
    
    func configure(with box: Box) {
        boxNameLabel.text = box.name
        boxDescriptionLabel.text = box.brief
        
        let rating: Double? = box.reviews.average(ofProperty: "rating")
        ratingLabel.text = String(format: "%.1f", rating ?? 4.2)
        
        if let string = box.pictures.first?.url, let url = URL(string: string) {
            nuke.loadImage(with: url, into: boxImageView)
        }
    }
}
