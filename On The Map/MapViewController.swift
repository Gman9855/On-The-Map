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

@objc protocol MapViewControllerDelegate {
    optional func mapViewDidAnnotateMap()
}

class MapViewController: UIViewController, MKMapViewDelegate {
    
    let parseAppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    let apiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    let reuseIdentifier = "reuseIdentifier"
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager = CLLocationManager()
    var students = [Student]()
    var delegate: MapViewControllerDelegate! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var pinButton = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "pinButtonTapped:")
        var refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshButtonTapped:")
        navigationItem.rightBarButtonItems = [refreshButton, pinButton]
        locationManager.requestWhenInUseAuthorization()
        self.mapView.delegate = self
        getStudentDataAndDropPins()
    }
    
    func getStudentDataAndDropPins() {
        var fetcher = StudentInfoFetcher()
        fetcher.requestStudentInfo { (students) -> () in
            let object = UIApplication.sharedApplication().delegate
            let appDelegate = object as! AppDelegate
            appDelegate.students = students
            self.students = students
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.mapView.addAnnotations(students)
            })
        }
    }
    
    // MARK: Bar Button Action Methods
    
    func pinButtonTapped(sender: UIBarButtonItem) {
        var infoPostingVC = storyboard?.instantiateViewControllerWithIdentifier("infoPostingVC") as! UIViewController
        presentViewController(infoPostingVC, animated: true, completion: nil)
    }
    
    func refreshButtonTapped(sender: UIBarButtonItem) {
        self.mapView.removeAnnotations(self.students)
        getStudentDataAndDropPins()
    }
    
    @IBAction func logoutButtonTapped(sender: UIBarButtonItem) {
        FBSDKLoginManager().logOut()
        var loginVC = storyboard?.instantiateViewControllerWithIdentifier("loginVC") as! UIViewController
        presentViewController(loginVC, animated: true, completion: nil)
    }
    
    // MARK: MapView Delegate
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if let annotation = annotation as? Student {
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
        } else {
            return
        }
    }
}
