//
//  Student.swift
//  On The Map
//
//  Created by Gershy Lev on 5/24/15.
//  Copyright (c) 2015 Gershy Lev. All rights reserved.
//

import Foundation
import MapKit

class StudentPin: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String
    var subtitle: String?
    
    init(student: Student) {
        self.coordinate = student.locationCoordinate
        self.title = student.firstName + " " + student.lastName
        self.subtitle = student.mediaURL?.absoluteString
    }
}
