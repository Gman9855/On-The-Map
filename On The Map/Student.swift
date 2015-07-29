//
//  Student.swift
//  On The Map
//
//  Created by Gershy Lev on 6/16/15.
//  Copyright (c) 2015 Gershy Lev. All rights reserved.
//

import Foundation
import MapKit

class Student {
    
    var firstName: String!
    var lastName: String!
    var locationCoordinate: CLLocationCoordinate2D!
    var mediaURL: NSURL?
    var locationDescription: String!
    var fullName: String!
    
    init(firstName: String, lastName: String, locationCoordinate: CLLocationCoordinate2D, mediaURL: NSURL?) {
        self.firstName = firstName
        self.lastName = lastName
        self.locationCoordinate = locationCoordinate
        self.mediaURL = mediaURL
        self.fullName = firstName + " " + lastName
    }
}
