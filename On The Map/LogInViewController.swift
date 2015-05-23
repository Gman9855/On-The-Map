//
//  ViewController.swift
//  On The Map
//
//  Created by Gershy Lev on 5/21/15.
//  Copyright (c) 2015 Gershy Lev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var userID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginButtonTapped(sender: UIButton) {
        if emailTextField.text.isEmpty || passwordTextField.text.isEmpty {
            //make label and alert user
        } else {
            let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
            request.HTTPMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = "{\"udacity\": {\"username\": \"\(emailTextField.text)\", \"password\": \"\(passwordTextField.text)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { data, response, error in
                if error != nil { // Handle error…
                    if error.code == -1009 {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            var alert = UIAlertView(title: "No network connection", message: "Please connect to a network and try again", delegate: self, cancelButtonTitle: "Okay")
                            alert.show()
                        })
                    }
                    return
                }
                
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                if let userID = parsedResult.valueForKeyPath("account.key") as? String {
                    self.userID = userID
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.performSegueWithIdentifier("segueToTabBar", sender: self)
                    })
                }
                if let error = parsedResult["error"] as? String {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        var alert = UIAlertView(title: nil, message: error, delegate: self, cancelButtonTitle: "Okay")
                        alert.show()
                    })
                }
            }
            task.resume()
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

