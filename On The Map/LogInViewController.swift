//
//  ViewController.swift
//  On The Map
//
//  Created by Gershy Lev on 5/21/15.
//  Copyright (c) 2015 Gershy Lev. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class ViewController: UIViewController {

    @IBOutlet weak var verticalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginToUdacityLabel: UILabel!
    
    var userID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.text = "gbay9855@yahoo.com"
        passwordTextField.text = "..."
        updateVerticalSpacingConstraintConstant()
    }
    
    override func viewDidAppear(animated: Bool) {
        if FBSDKAccessToken.currentAccessToken() != nil {
            self.performSegueWithIdentifier("segueToTabBar", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateVerticalSpacingConstraintConstant() {
        let sizeClassesToConstants:Dictionary<UIUserInterfaceSizeClass, CGFloat> = [.Compact : 50, .Regular : 120, .Unspecified : 50]
        self.verticalSpacingConstraint.constant = sizeClassesToConstants[self.traitCollection.verticalSizeClass]!
    }
    
    @IBAction func loginButtonTapped(sender: UIButton) {
        if emailTextField.text.isEmpty || passwordTextField.text.isEmpty {
            var alert = UIAlertView(title: nil, message: "Please enter an email address and password", delegate: self, cancelButtonTitle: "Okay")
            alert.show()
        } else {
            NetworkHandler().loginWithUdacity(emailTextField.text, password: passwordTextField.text, completion: { (success, error) -> () in
                if error != nil { // Handle error…
                    if error!.code == -1009 {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            var alert = UIAlertView(title: "No network connection", message: "Please connect to a network and try again", delegate: self, cancelButtonTitle: "Okay")
                            alert.show()
                        })
                    }
                    if error!.code == -1010 {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            var alert = UIAlertView(title: nil, message: error?.domain, delegate: self, cancelButtonTitle: "Okay")
                            alert.show()
                        })
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.performSegueWithIdentifier("segueToTabBar", sender: self)
                    })
                }
            })
        }
    }

    @IBAction func facebookLoginButtonTapped(sender: UIButton) {
        NetworkHandler().loginWithFacebook { (success, error) -> () in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    var alert = UIAlertView(title: nil, message: error?.domain, delegate: self, cancelButtonTitle: "Okay")
                    alert.show()
                    return
                })
            }
            if success {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.performSegueWithIdentifier("segueToTabBar", sender: self)
                })
            }
        }
    }
    
    @IBAction func signUpButtonTapped(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "segueToTabBar" {
//            let mapVC = segue.destinationViewController as! MapViewController
//        }
//    }
}

