//
//  BoxViewController.swift
//  instacrate-ios
//
//  Created by Hakon Hanesand on 1/9/17.
//  Copyright © 2017 Instacrate. All rights reserved.
//

import UIKit
import RealmSwift
import Nuke

class BoxViewController: UIViewController {

    let boxPrimaryKey: Int

    @IBOutlet weak var boxImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var vendorNameLabel: UILabel!
    @IBOutlet weak var averageReviewScoreLabel: UILabel!
    @IBOutlet weak var briefLabel: UILabel!

    @IBOutlet weak var firstBulletPointLabel: UILabel!
    @IBOutlet weak var secondBulletPointLabel: UILabel!
    @IBOutlet weak var thirdBulletPointLabel: UILabel!
    @IBOutlet weak var fourthBulletPointLabel: UILabel!

    @IBOutlet weak var addToCartButton: UIButton!

    @IBOutlet weak var oneTimeView: UIView!
    @IBOutlet weak var subscribeView: UIView!

    init(boxPrimaryKey: Int) {
        self.boxPrimaryKey = boxPrimaryKey

        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Box"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let greenColor = addToCartButton.titleLabel?.textColor?.cgColor

        addToCartButton.layer.borderColor = greenColor
        oneTimeView.layer.borderColor = greenColor
        subscribeView.layer.borderColor = greenColor

        let oneTimeViewPath = UIBezierPath(roundedRect: oneTimeView.bounds, byRoundingCorners: [.topLeft], cornerRadii: CGSize(width: 10, height:  10))
        let subscribeViewPath = UIBezierPath(roundedRect: subscribeView.bounds, byRoundingCorners: [.topRight], cornerRadii: CGSize(width: 10, height:  10))
        let cartButtonViewPath = UIBezierPath(roundedRect: addToCartButton.bounds, byRoundingCorners: [.bottomRight, .bottomLeft], cornerRadii: CGSize(width: 10, height:  10))

        let maskLayer = CAShapeLayer()
        maskLayer.path = oneTimeViewPath.cgPath
        oneTimeView.layer.mask = maskLayer

        let maskLayer2 = CAShapeLayer()
        maskLayer2.path = subscribeViewPath.cgPath
        subscribeView.layer.mask = maskLayer2

        let maskLayer3 = CAShapeLayer()
        maskLayer3.path = cartButtonViewPath.cgPath
        addToCartButton.layer.mask = maskLayer3

        let borderLayer = CAShapeLayer()
        borderLayer.path = oneTimeViewPath.cgPath
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = greenColor
        borderLayer.lineWidth = 1
        borderLayer.frame = oneTimeView.bounds
        oneTimeView.layer.addSublayer(borderLayer)

        let borderLayer2 = CAShapeLayer()
        borderLayer2.path = subscribeViewPath.cgPath
        borderLayer2.fillColor = UIColor.clear.cgColor
        borderLayer2.strokeColor = greenColor
        borderLayer2.lineWidth = 1
        borderLayer2.frame = subscribeView.bounds
        subscribeView.layer.addSublayer(borderLayer2)

        let borderLayer3 = CAShapeLayer()
        borderLayer3.path = cartButtonViewPath.cgPath
        borderLayer3.fillColor = UIColor.clear.cgColor
        borderLayer3.strokeColor = greenColor
        borderLayer3.lineWidth = 1
        borderLayer3.frame = addToCartButton.bounds
        addToCartButton.layer.addSublayer(borderLayer3)

        if let _box = try? Realm().object(ofType: Box.self, forPrimaryKey: boxPrimaryKey), let box = _box {
            updateView(with: box)
        }
    }

    @IBAction func didPressBuyButton(_ sender: Any) {
        guard let _box = try? Realm().object(ofType: Box.self, forPrimaryKey: boxPrimaryKey), let box = _box else {
            return
        }
        
        let checkout = CheckoutViewController(product: box.name, price: Int(box.price * 100))
        self.navigationController?.pushViewController(checkout, animated: true)
    }
    
    func updateView(with box: Box) {

        if let string = box.pictures.first?.url, let url = URL(string: string) {
            nuke.loadImage(with: url, into: boxImageView)
        }

        titleLabel.text = box.name
        vendorNameLabel.text = box.vendor?.businessName
        averageReviewScoreLabel.text = "4.0"
        briefLabel.text = box.brief

        let bullets = box.splitBullets()

        firstBulletPointLabel.text = bullets[0]
        secondBulletPointLabel.text = bullets[1]
        thirdBulletPointLabel.text = bullets[2]
        fourthBulletPointLabel.text = bullets[3]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
