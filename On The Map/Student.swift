//
//  Student.swift
//  On The Map
//
//  Created by Gershy Lev on 6/16/15.
//  Copyright (c) 2015 Gershy Lev. All rights reserved.
//

import Foundation
import MapKit

struct Student {
    
    var firstName: String!
    var lastName: String!
    var locationCoordinate: CLLocationCoordinate2D!
    var mediaURL: NSURL?
    var locationDescription: String!
    var fullName: String!
    
    init(studentInfoDictionary: NSDictionary) {
        var coordinate: CLLocationCoordinate2D?
        var firstName: String!
        var lastName: String!
        var mediaURL: NSURL?
        
        if let fName = studentInfoDictionary["firstName"] as? String {
            if let lName = studentInfoDictionary["lastName"] as? String {
                var lat = studentInfoDictionary["latitude"]! as! NSNumber
                var long = studentInfoDictionary["longitude"]! as! NSNumber
                
                coordinate = CLLocationCoordinate2DMake(lat.doubleValue, long.doubleValue)
                firstName = fName
                lastName = lName
            }
        }
        
        if let studentURL = studentInfoDictionary["mediaURL"] as? String {
            mediaURL = self.URLlinkFromString(studentURL)
        }
        
        self.firstName = firstName
        self.lastName = lastName
        self.locationCoordinate = coordinate
        self.mediaURL = mediaURL
        self.fullName = firstName + " " + lastName
    }
    
    private func URLlinkFromString(urlString: String) -> NSURL? {
        var returnString = urlString
        if urlString.rangeOfString(" ") != nil {
            return nil
        }
        if urlString.rangeOfString("http") == nil {
            returnString = "http://" + urlString
        }
        return NSURL(string: returnString)
    }
}
