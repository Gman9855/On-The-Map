//
//  MapViewController.swift
//  On The Map
//
//  Created by Gershy Lev on 5/21/15.
//  Copyright (c) 2015 Gershy Lev. All rights reserved.
//

import UIKit
import MapKit
import FBSDKLoginKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    let reuseIdentifier = "reuseIdentifier"
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager = CLLocationManager()
    
    var postedPin: StudentPin?
    var studentPins: [StudentPin]!
    lazy var networkHandler = NetworkHandler()

    var infoPostingVC: InfoPostingViewController { return self.storyboard?.instantiateViewControllerWithIdentifier("infoPostingVC") as! InfoPostingViewController }
    
    var appDelegate: AppDelegate {
        let object = UIApplication.sharedApplication().delegate
        return object as! AppDelegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var pinButton = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "pinButtonTapped:")
        var refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshButtonTapped:")
        navigationItem.rightBarButtonItems = [refreshButton, pinButton]
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "postStudentLocationToMap:", name: "didSubmitStudentLocationNotification", object: nil)
        self.mapView.delegate = self
        locationManager.requestWhenInUseAuthorization()
        getStudentDataAndDropPins()
    }
    
    func getStudentDataAndDropPins() {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        networkHandler.requestStudents { (students) -> () in
            self.appDelegate.students = students
            self.studentPins = students.map({ (student: Student) -> StudentPin in
                return StudentPin(student: student)
            })
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.mapView.addAnnotations(self.studentPins)
                MBProgressHUD.hideHUDForView(self.view, animated: true)
            })
        }
    }
    
    func postStudentLocationToMap(notification: NSNotification) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        var shouldReplace = false
        if postedPin != nil {
            mapView.removeAnnotation(postedPin)
            for (var i = appDelegate.students.count - 1; i > 0; i--) {
                let studentAtIndex: Student = appDelegate.students[i]
                if studentAtIndex.fullName == postedPin?.title {
                    appDelegate.students.removeAtIndex(i)
                    break
                }
            }
            shouldReplace = true
        }
        let userInfoDict: NSDictionary = notification.userInfo!
        let submittedPin = userInfoDict["submittedPin"] as! SubmittedPin
        
        networkHandler.postStudentLocation(submittedPin.mapString, coordinate: submittedPin.coordinate, mediaURL: submittedPin.mediaURL, shouldReplace: shouldReplace) { (student, error) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                MBProgressHUD.hideHUDForView(self.view, animated: true)
            })
            if (error != nil) {
                let errorDict = error?.userInfo as! [String: String]
                if let errorMessage = errorDict["error"] {
                    let alertController = UIAlertController(title: errorMessage, message: nil, preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "Okay", style: .Default, handler: { (action: UIAlertAction!) -> Void in
                        self.presentViewController(self.infoPostingVC, animated: true, completion: nil)
                    }))
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            } else {
                self.appDelegate.students.append(student!)
                let studentPin: StudentPin = StudentPin(student: student!)
                let coordinateSpan = MKCoordinateSpanMake(0.3, 0.3)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.mapView.setRegion(MKCoordinateRegionMake(studentPin.coordinate, coordinateSpan), animated: true)
                    self.mapView.addAnnotation(studentPin)
                    self.mapView.selectAnnotation(studentPin, animated: true)
                })
                self.postedPin = studentPin
            }
        }
    }
    
    // MARK: Bar Button Action Methods
    
    func pinButtonTapped(sender: UIBarButtonItem) {
        if postedPin != nil {
            let alertController = UIAlertController(title: "You have already posted a student location.  Would you like to overwrite your location?", message: nil, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive, handler: nil))
            alertController.addAction(UIAlertAction(title: "Overwrite", style: .Default, handler: { (action: UIAlertAction!) -> Void in
                self.infoPostingVC.shouldReplace = true
                print(self.infoPostingVC)
                self.tabBarController!.presentViewController(self.infoPostingVC, animated: true, completion: nil)
            }))
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            self.tabBarController!.presentViewController(self.infoPostingVC, animated: true, completion: nil)
            print(self.infoPostingVC)
        }
    }
    
    func refreshButtonTapped(sender: UIBarButtonItem) {
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.mapView.removeAnnotations(self.studentPins)
        })
        getStudentDataAndDropPins()
    }
    
    @IBAction func logoutButtonTapped(sender: UIBarButtonItem) {
        if let accessToken = FBSDKAccessToken.currentAccessToken() {
            FBSDKLoginManager().logOut()
            var loginVC = storyboard?.instantiateViewControllerWithIdentifier("loginVC") as! UIViewController
            presentViewController(loginVC, animated: true, completion: nil)
        } else {
            networkHandler.logoutOfUdacity({ (success, error) -> () in
                if error != nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let alertView = UIAlertView(title: nil, message: "Something went wrong.  Check your network connection and try again.", delegate: self, cancelButtonTitle: "Okay")
                        alertView.show()
                    })
                    
                } else {
                    var loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("loginVC") as! UIViewController
                    self.presentViewController(loginVC, animated: true, completion: nil)
                }
            })
        }
    }
    
    // MARK: MapView Delegate
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if let annotation = annotation as? StudentPin {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIView
                view.animatesDrop = true
            }
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if let studentMediaURL = view.annotation.subtitle {
            UIApplication.sharedApplication().openURL(NSURL(string: studentMediaURL)!)
        }
    }
}
