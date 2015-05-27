//
//  Student.swift
//  On The Map
//
//  Created by Gershy Lev on 5/24/15.
//  Copyright (c) 2015 Gershy Lev. All rights reserved.
//

import Foundation
import MapKit

class Student: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String
    var subtitle: String
    
    init(dictionary: Dictionary<String, AnyObject>) {
        var coordinate: CLLocationCoordinate2D?
        var title: String?
        var subtitle: String?
        
        if let firstName = dictionary["firstName"] as? String {
            if let lastName = dictionary["lastName"] as? String {
                coordinate = CLLocationCoordinate2DMake(dictionary["latitude"] as! Double, dictionary["longitude"] as! Double)
                title = firstName + " " + lastName
            } else {
                title = firstName
            }
        }
        if let mediaURL = dictionary["mediaURL"] as? String {
            subtitle = mediaURL
        }
        
        self.coordinate = coordinate!
        self.title = title!
        self.subtitle = subtitle!
    }
}
