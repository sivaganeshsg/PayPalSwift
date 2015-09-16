//
//  ViewController.swift
//  PayPal Test
//
//  Created by Siva Ganesh on 14/09/15.
//  Copyright (c) 2015 Siva Ganesh. All rights reserved.
//

import UIKit

class ViewController: UIViewController, PayPalPaymentDelegate{

    // For PayPal integration, we need to follow these steps
    // 1. Add Paypal config. in AppDelegate
    // 2. Create PayPal object
    // 3. Declare payment configurations
    // 4. Implement PayPalPaymentDelegate
    // 5. Add payment items and related details
    
    
    var payPalConfig = PayPalConfiguration()
    
    var environment:String = PayPalEnvironmentNoNetwork {
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnectWithEnvironment(newEnvironment)
            }
        }
    }
    
    var acceptCreditCards: Bool = true {
        didSet {
            payPalConfig.acceptCreditCards = acceptCreditCards
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        payPalConfig.acceptCreditCards = acceptCreditCards;
        payPalConfig.merchantName = "Siva Ganesh Inc."
        payPalConfig.merchantPrivacyPolicyURL = NSURL(string: "https://www.sivaganesh.com/privacy.html")
        payPalConfig.merchantUserAgreementURL = NSURL(string: "https://www.sivaganesh.com/useragreement.html")
        payPalConfig.languageOrLocale = NSLocale.preferredLanguages()[0] as! String
        payPalConfig.payPalShippingAddressOption = .PayPal;
        
        PayPalMobile.preconnectWithEnvironment(environment)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    // PayPalPaymentDelegate
    
    func payPalPaymentDidCancel(paymentViewController: PayPalPaymentViewController!) {
        println("PayPal Payment Cancelled")
        paymentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func payPalPaymentViewController(paymentViewController: PayPalPaymentViewController!, didCompletePayment completedPayment: PayPalPayment!) {
        
        println("PayPal Payment Success !")
        paymentViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            // send completed confirmaion to your server
            println("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
        })
    }

    
    
    @IBAction func payPressed(sender: AnyObject) {
        
        // Process Payment once the pay button is clicked.
        
        var item1 = PayPalItem(name: "Siva Ganesh Test Item", withQuantity: 1, withPrice: NSDecimalNumber(string: "9.99"), withCurrency: "USD", withSku: "SivaGanesh-0001")
        
        let items = [item1]
        let subtotal = PayPalItem.totalPriceForItems(items)
        
        // Optional: include payment details
        let shipping = NSDecimalNumber(string: "0.00")
        let tax = NSDecimalNumber(string: "0.00")
        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
        
        let total = subtotal.decimalNumberByAdding(shipping).decimalNumberByAdding(tax)
        
        let payment = PayPalPayment(amount: total, currencyCode: "USD", shortDescription: "Siva Ganesh Test", intent: .Sale)
        
        payment.items = items
        payment.paymentDetails = paymentDetails
        
        if (payment.processable) {
            
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
            presentViewController(paymentViewController, animated: true, completion: nil)
        }
        else {
            
            println("Payment not processalbe: \(payment)")
        }
        
    }
}

