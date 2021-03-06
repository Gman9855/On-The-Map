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
    
    var userID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateVerticalSpacingConstraintConstant()
    }
    
    override func viewDidAppear(animated: Bool) {
        if FBSDKAccessToken.currentAccessToken() != nil {
            self.performSegueWithIdentifier("segueToTabBar", sender: self)
        }
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
                            let userInfoDict = error!.userInfo as! [String: String]
                            let errorMessage = userInfoDict["error"]
                            var alert = UIAlertView(title: nil, message: errorMessage, delegate: self, cancelButtonTitle: "Okay")
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
            if success {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.performSegueWithIdentifier("segueToTabBar", sender: self)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let userInfoDict = error!.userInfo as! [String: String]
                    let errorMessage = userInfoDict["error"]
                    var alert = UIAlertView(title: nil, message: errorMessage, delegate: self, cancelButtonTitle: "Okay")
                    alert.show()
                })
            }
        }
    }
    
    @IBAction func signUpButtonTapped(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
    }
}