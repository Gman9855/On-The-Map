//
//  SubmittedPin.swift
//  On The Map
//
//  Created by Gershy Lev on 7/15/15.
//  Copyright (c) 2015 Gershy Lev. All rights reserved.
//

import Foundation
import MapKit

class SubmittedPin {
    
    var mapString: String!
    var coordinate: CLLocationCoordinate2D!
    var mediaURL: String!
    
    init(mapString: String, coordinate: CLLocationCoordinate2D, mediaURL: String) {
        self.mapString = mapString
        self.coordinate = coordinate
        self.mediaURL = mediaURL
    }
}