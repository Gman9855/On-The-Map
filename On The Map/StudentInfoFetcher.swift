//
//  StudentInfoFetcher.swift
//  On The Map
//
//  Created by Gershy Lev on 6/4/15.
//  Copyright (c) 2015 Gershy Lev. All rights reserved.
//

import UIKit

class StudentInfoFetcher {
    
    let parseAppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    let apiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    
    func requestStudentInfo(completionClosure: (students: [Student]) -> ()) {
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
            
            completionClosure(students: students)
        }
        task.resume()

    }
}
