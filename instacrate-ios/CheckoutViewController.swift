//
//  CheckoutViewController.swift
//  instacrate-ios
//
//  Created by Hakon Hanesand on 2/16/17.
//  Copyright © 2017 Instacrate. All rights reserved.
//

import Foundation
import Stripe
import Alamofire
import AvePurchaseButton
import Static
import PromiseKit
import Moya

class CheckoutViewController: UITableViewController, STPPaymentContextDelegate {
    
    let shipping = MoyaProvider<Shippings>()
    let subscription = MoyaProvider<Subscriptions>()
    
    static func instance() -> CheckoutViewController {
        let storyboard = UIStoryboard(name: "CheckoutViewController", bundle: nil)
        return storyboard.instantiateInitialViewController() as! CheckoutViewController
    }

    // These values will be shown to the user when they purchase with Apple Pay.
    let companyName = "Instacrate"
    let paymentCurrency = "usd"
    
    var box: Box!
    var oneTime: Bool!
    
    @IBOutlet weak var checkoutButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let paymentContext: STPPaymentContext
    
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var paymentDescriptionLabel: UILabel!
    @IBOutlet weak var addressDescriptionLabel: UILabel!
    
    var shippingAddressPromise: Promise<Response>?
    
    var paymentValid = false
    var addressValid = false {
        didSet {
            if !oldValue && addressValid {
                guard let address = paymentContext.shippingAddress else {
                    addressValid = false
                    return
                }
                
                shippingAddressPromise = Promise { fulfill, reject in
                
                    shipping.request(.create(address: address)) { result in
                        switch result {
                        case let .success(response):
                            fulfill(response)
                            
                        case let .failure(error):
                            reject(error)
                        }
                    }
                }
            }
        }
    }
    
    var paymentInProgress: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                if self.paymentInProgress {
                    self.checkoutButton.alpha = 0
                    self.activityIndicator.startAnimating()
                    self.activityIndicator.alpha = 1
                }
                else {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.alpha = 0
                    self.checkoutButton.alpha = 1
                }
            }, completion: nil)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        assert(STPPaymentConfiguration.shared().publishableKey.hasPrefix("pk_"), "You must set your Stripe publishable key at the top of CheckoutViewController.swift to run this app.")
        
        // This code is included here for the sake of readability, but in your application you should set up your configuration and theme earlier, preferably in your App Delegate.
        let config = STPPaymentConfiguration.shared()
        config.companyName = self.companyName
        config.requiredBillingAddressFields = .zip
        config.requiredShippingAddressFields = .postalAddress
        config.shippingType = .shipping
        
        let paymentContext = STPPaymentContext(apiAdapter: StripeVaporBackendAdapter(), configuration: config, theme: STPTheme.default())
        paymentContext.paymentCurrency = self.paymentCurrency
        
        self.paymentContext = paymentContext
        
        super.init(coder: aDecoder)
        
        self.paymentContext.delegate = self
        paymentContext.hostViewController = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cardImageView.image = STPImageLibrary.unknownCardCardImage()
    }
    
    @IBAction func didTapUpdatePaymentMethod(_ sender: Any) {
        paymentContext.pushPaymentMethodsViewController()
    }
    
    @IBAction func didTapUpdateShippingMethod(_ sender: Any) {
        paymentContext.pushShippingViewController()
    }
    
    @IBAction func startPurchase(_ sender: Any) {
        self.paymentInProgress = true
        self.paymentContext.requestPayment()
    }
    
    // MARK: STPPaymentContextDelegate
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        
        if let selectedPaymentMethod = paymentContext.selectedPaymentMethod {
            self.cardImageView.image = selectedPaymentMethod.image
            self.paymentDescriptionLabel.text = selectedPaymentMethod.label
            paymentValid = true
        }
        
        if let selectedShippingAddress = paymentContext.shippingAddress, selectedShippingAddress.containsRequiredFields(.full) {
            self.addressDescriptionLabel.text = selectedShippingAddress.line1
            addressValid = true
        }
        
        checkoutButton.isEnabled = addressValid && paymentValid
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        shippingAddressPromise!.then { response in
            let box_id = box.id
            let shipping_id =z
            return subscription.promised(.create())
        }
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Swift.Error?) {
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Swift.Error) {
        let alertController = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            // Need to assign to _ because optional binding loses @discardableResult value
            // https://bugs.swift.org/browse/SR-1681
            _ = self.navigationController?.popViewController(animated: true)
        })
        
        let retry = UIAlertAction(title: "Retry", style: .default, handler: { action in
            self.paymentContext.retryLoading()
        })
        
        alertController.addAction(cancel)
        alertController.addAction(retry)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
