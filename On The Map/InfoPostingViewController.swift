//
//  InfoPostingViewController.swift
//  On The Map
//
//  Created by Gershy Lev on 6/2/15.
//  Copyright (c) 2015 Gershy Lev. All rights reserved.
//

import UIKit
import MapKit

class InfoPostingViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var whereAreYouStudyingView: UIView!
    @IBOutlet weak var findOnMapView: UIView!
    @IBOutlet weak var enterLocationView: UIView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var sharingLinkTextField: UITextField!
    @IBOutlet weak var whereAreYouLabel: UILabel!
    @IBOutlet weak var studyingLabel: UILabel!
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var findOnTheMapButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    private var mapPin: MKPointAnnotation!
    private lazy var networkHandler = NetworkHandler()
    var shouldReplace: Bool!
    
    override func viewDidLoad() {
        findOnTheMapButton.layer.cornerRadius = 10
        findOnTheMapButton.clipsToBounds = true
        submitButton.layer.cornerRadius = 10
        submitButton.clipsToBounds = true
        locationTextField.attributedPlaceholder = NSAttributedString(string: "Enter your location here", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        sharingLinkTextField.attributedPlaceholder = NSAttributedString(string: "Enter a link to share here", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        sharingLinkTextField.hidden = true
        var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboardFromTap:")
        tapGestureRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGestureRecognizer)
    }
        
    @IBAction func cancelButtonTapped(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func findOnTheMapButtonTapped(sender: UIButton) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        networkHandler.requestMapPinForLocation(locationTextField.text, completion: { (mapPin, error) -> () in
            if mapPin != nil {
                self.mapPin = mapPin
                self.findOnTheMapButton.hidden = true
                self.submitButton.hidden = false
                
                self.whereAreYouStudyingView.backgroundColor = UIColor(red: 0.443, green: 0.620, blue: 0.886, alpha: 1.000)
                self.whereAreYouStudyingTodayLabelHidden(true)
                self.sharingLinkTextField.hidden = false
                
                UIView.animateWithDuration(0.8, animations: { () -> Void in  //hide views to show mapView
                    self.enterLocationView.alpha = 0.0
                    self.findOnMapView.alpha = 0.0
                })
                let coordinateSpan = MKCoordinateSpanMake(0.3, 0.3)
                self.mapView.setRegion(MKCoordinateRegionMake(mapPin!.coordinate, coordinateSpan), animated: true)
                self.mapView.addAnnotation(mapPin!)
                self.mapView.selectAnnotation(mapPin!, animated: true)
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    UIAlertView(title: nil, message: "Couldn't find your location.  Try again.", delegate: self, cancelButtonTitle: "Okay").show()
                })
                self.locationTextField.text = ""
            }
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        })
    }
    
    @IBAction func submitButtonTapped(sender: UIButton) {
        if sharingLinkTextField.text == "" {
            UIAlertView(title: nil, message: "Please enter a link to share.", delegate: self, cancelButtonTitle: "Okay").show()
        } else {
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                var userInfoDict = ["submittedPin" : SubmittedPin(mapString: self.locationTextField.text, coordinate: self.mapPin.coordinate, mediaURL: self.sharingLinkTextField.text)]
                NSNotificationCenter.defaultCenter().postNotificationName("didSubmitStudentLocationNotification", object: self, userInfo: userInfoDict)
            })
        }
    }
    
    func dismissKeyboardFromTap(gestureRecognizer: UIGestureRecognizer) {
        locationTextField.resignFirstResponder()
        sharingLinkTextField.resignFirstResponder()
    }
    
    func whereAreYouStudyingTodayLabelHidden(hidden: Bool) {
        whereAreYouLabel.hidden = hidden
        studyingLabel.hidden = hidden
        todayLabel.hidden = hidden
    }
}