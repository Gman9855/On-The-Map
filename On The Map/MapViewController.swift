//
//  MapViewController.swift
//  On The Map
//
//  Created by Gershy Lev on 5/21/15.
//  Copyright (c) 2015 Gershy Lev. All rights reserved.
//

import UIKit
import MapKit

@objc protocol MapViewControllerDelegate {
    optional func mapViewDidAnnotateMap()
}

class MapViewController: UIViewController, MKMapViewDelegate {
    
    let parseAppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    let apiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    let reuseIdentifier = "reuseIdentifier"
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager = CLLocationManager()
    var students: NSArray!
    var delegate: MapViewControllerDelegate! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        self.mapView.delegate = self
        fetchStudentDataAndDropPins()
    }
    
    func fetchStudentDataAndDropPins() {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.addValue(parseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(apiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            
            var students = [Student]()
            
            var parsingError: NSError? = nil
            let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
            var studentLocationDictionaries = parsedResult["results"] as! [AnyObject]
            for dictionary in studentLocationDictionaries {
                var student = Student(dictionary: dictionary as! Dictionary<String, AnyObject>)
                students.append(student)
            }
            let object = UIApplication.sharedApplication().delegate
            let appDelegate = object as! AppDelegate
            appDelegate.students = students
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.mapView.addAnnotations(students)
                self.mapView.selectAnnotation(students[0], animated: true)
            })
        }
        task.resume()
    }
    
    @IBAction func pinButtonTapped(sender: UIBarButtonItem) {

    }
    
    @IBAction func refreshButtonTapped(sender: UIBarButtonItem) {
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
