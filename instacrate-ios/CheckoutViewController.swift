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

class CheckoutViewController: UIViewController, STPPaymentContextDelegate {

    // These values will be shown to the user when they purchase with Apple Pay.
    let companyName = "Instacrate"
    let paymentCurrency = "usd"
    
    let box: Box
    
    let paymentContext: STPPaymentContext
    
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var paymentDescriptionLabel: UILabel!
    @IBOutlet weak var addressDescriptionLabel: UILabel!
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    let numberFormatter: NumberFormatter
    
    var paymentInProgress: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                if self.paymentInProgress {
                    self.activityIndicator.startAnimating()
                    self.activityIndicator.alpha = 1
                }
                else {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.alpha = 0
                }
            }, completion: nil)
        }
    }

    init?(boxKey: Int, oneTime: Bool) {
        guard let box: Box = Box.fetch(with: boxKey) else {
            return nil
        }
        
        self.box = box
        
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
        
        var localeComponents: [String: String] = [NSLocale.Key.currencyCode.rawValue: self.paymentCurrency]
        localeComponents[NSLocale.Key.languageCode.rawValue] = NSLocale.preferredLanguages.first
        
        let localeID = NSLocale.localeIdentifier(fromComponents: localeComponents)
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: localeID)
        numberFormatter.numberStyle = .currency
        numberFormatter.usesGroupingSeparator = true
        
        self.numberFormatter = numberFormatter
        
        super.init(nibName: nil, bundle: nil)
        
        self.paymentContext.delegate = self
        paymentContext.hostViewController = self
        
        self.title = "Checkout"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    func didTapBuy() {
        self.paymentInProgress = true
        self.paymentContext.requestPayment()
    }
    
    // MARK: STPPaymentContextDelegate
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        if let selectedPaymentMethod = paymentContext.selectedPaymentMethod {
            self.cardImageView.image = selectedPaymentMethod.image
            self.paymentDescriptionLabel.text = selectedPaymentMethod.label
        }
        
        if let selectedShippingAddress = paymentContext.shippingAddress {
            self.addressDescriptionLabel.text = selectedShippingAddress.line1
        }
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
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
    
    func paymentContext(_ paymentContext: STPPaymentContext, didUpdateShippingAddress address: STPAddress, completion: @escaping STPShippingMethodsCompletionBlock) {
        
    }
    
}
