//
//  Server.swift
//  instacrate-ios
//
//  Created by Hakon Hanesand on 10/31/16.
//  Copyright © 2016 Instacrate. All rights reserved.
//

import Foundation
import Moya

import UIKit.UIImage

enum Login {
    
    case login(username: String, password: String)
}

enum Creation {
    
    case box(box: Box)
    case vendor(vendor: Vendor)
    case review(review: Review)
    case category(category: Category)
}

enum Upload {
    
    case image(image: UIImage)
    case contract(text: String)
}
