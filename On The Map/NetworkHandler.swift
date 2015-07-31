//
//  NetworkHandler.swift
//  
//
//  Created by Gershy Lev on 6/6/15.
//
//

import Foundation
import FBSDKLoginKit
import MapKit

extension String {
    var length: Int {
        return count(self)
    }
}

class NetworkHandler {
    
    let parseAppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    let apiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    
    private var objectID: String!
    
    func loginWithFacebook(completion: (success: Bool, error: NSError?) -> ()) {
        var login = FBSDKLoginManager()
        login.logInWithReadPermissions(nil, handler: { (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
            if let fbAccessToken = FBSDKAccessToken.currentAccessToken() {
                print(result)
                let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
                request.HTTPMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.HTTPBody = "{\"facebook_mobile\": {\"access_token\": \"\(fbAccessToken.tokenString)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
                let session = NSURLSession.sharedSession()
                let task = session.dataTaskWithRequest(request) { data, response, error in
                    if error != nil {
                        completion(success: false, error: nil)
                        return
                    }
                    let parsedResult = self.parsedUdacityJSONData(data)
                    if parsedResult["account"] == nil {
                        var newError = NSError(domain: "com.gershylev.onthemap", code: 100, userInfo: ["error" : "Looks like you need to connect your Facebook account to udacity."])
                        completion(success: false, error: newError)
                    } else {
                        if let studentID = parsedResult.valueForKeyPath("account.key") as? String {
                            self.saveUserID(studentID)
                            completion(success: true, error: nil)
                        }
                    }
                }
                task.resume()
            } else {
                var newError = NSError(domain: "com.gershylev.onthemap", code: 101, userInfo: ["error" : "Something went wrong.  Check your network connection and try again."])
                completion(success: false, error: newError)
            }
        })
    }
    
    func loginWithUdacity(email: String, password: String, completion: (success: Bool, error: NSError?) -> ()) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                if error.code == -1009 {
                    completion(success: false, error: error)
                }
                return
            }
            let parsedResult = self.parsedUdacityJSONData(data)
            if let studentID = parsedResult.valueForKeyPath("account.key") as? String {
                self.saveUserID(studentID)
                completion(success: true, error: nil)
            }
            if let errorString = parsedResult["error"] as? String {
                var newError = NSError(domain: "com.gershylev.onthemap", code: -1010, userInfo: ["error" : errorString])
                completion(success: false, error: newError)
            }
        }
        task.resume()
    }
    
    private func getStudentName(userID: String, completion: (firstName: String, lastName: String) -> ()) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(userID)")!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            var parsedData = self.parsedUdacityJSONData(data)
            var firstName: String
            var lastName: String
            if let first = parsedData.valueForKeyPath("user.nickname") as? String {
                firstName = first
            } else {
                firstName = "udacity"
            }
            if let last = parsedData.valueForKeyPath("user.last_name") as? String {
                lastName = last
            } else {
                lastName = "student"
            }
            completion(firstName: firstName, lastName: lastName)
        }
        task.resume()
    }
    
    func logoutOfUdacity(completion: (success: Bool, error: NSError?) -> ()) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-Token")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                completion(success: false, error: error)
                return
            } else {
                completion(success: true, error: nil)
            }
        }
        task.resume()
    }
    
    func requestStudents(completion: (students: [Student]?, error: NSError?) -> ()) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.addValue(parseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(apiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                completion(students: nil, error: error)
                return
            }
            var students = [Student]()
            var parsingError: NSError? = nil
            let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
            var studentLocationDictionaries = parsedResult["results"] as! [AnyObject]
            for dictionary in studentLocationDictionaries {
                var student = Student(studentInfoDictionary: dictionary as! NSDictionary)
                students.append(student)
            }
            
            completion(students: students, error: nil)
        }
        task.resume()
    }
    
    func requestMapPinForLocation(location: String, completion: (mapPin: MKPointAnnotation?, error: NSError?) -> ()) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location, completionHandler: { (result: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                completion(mapPin: nil, error: error)
            } else {
                if let placemark = result[0] as? CLPlacemark {
                    var pin = MKPointAnnotation()
                    pin.coordinate = placemark.location.coordinate
                    pin.title = placemark.name
                    completion(mapPin: pin, error: nil)
                }
            }
            
        })
    }
    
    func postStudentLocation(mapString: String, coordinate: CLLocationCoordinate2D, mediaURL: String, shouldReplace: Bool, completion: (student: Student?, error: NSError?) -> ()) {
        if let userID = self.retrieveUserID() {
            self.getStudentName(userID, completion: { (firstName, lastName) -> () in
                let urlString = shouldReplace ? "https://api.parse.com/1/classes/StudentLocation/\(self.objectID)" : "https://api.parse.com/1/classes/StudentLocation"
                print(urlString)
                let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
                request.HTTPMethod = shouldReplace ? "PUT" : "POST"
                request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
                request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.HTTPBody = "{\"uniqueKey\": \"\(userID)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(coordinate.latitude), \"longitude\": \(coordinate.longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
                print(request.HTTPBody)
                let session = NSURLSession.sharedSession()
                let task = session.dataTaskWithRequest(request) { data, response, error in
                    if error != nil { // Handle error…
                        completion(student: nil, error: error)
                        return
                    }
                    var parsingError: NSError? = nil
                    let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                    print(parsedResult)
                    
                    if parsedResult["createdAt"] != nil || parsedResult["updatedAt"] != nil {
                        let student = Student(firstName: firstName, lastName: lastName, locationCoordinate: coordinate, mediaURL: self.URLlinkFromString(mediaURL))
                        
                        if let objectID = parsedResult["objectId"] as? String {
                            self.objectID = objectID
                        }
                        completion(student: student, error: nil)
                    } else {
                        let newError = NSError(domain: "com.gershylev.onthemap", code: 41, userInfo: ["error" : "Something went wrong.  Please try again."])
                        completion(student: nil, error: newError)
                    }
                }
                task.resume()
            })
        }
    }
    
    private func parsedUdacityJSONData(data: NSData) -> NSDictionary {
        let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
        var parsingError: NSError? = nil
        return NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
    }
    
    private func mapItemFromMKLocalSearchResponse(response: MKLocalSearchResponse) -> MKMapItem? {
        var mapItem: MKMapItem!
        if let mapItems: Array = response.mapItems {
            mapItem = mapItems[0] as! MKMapItem
        } else {
            return nil
        }
        return mapItem
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
    
    private func saveUserID(userID: String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(userID, forKey: "userID")
        defaults.synchronize()
    }
    
    private func retrieveUserID() -> String? {
        let defaults = NSUserDefaults.standardUserDefaults()
        var userIDString: String?
        if let userID = defaults.objectForKey("userID") as? String {
            userIDString = userID
        } else {
            userIDString = nil
        }
        return userIDString
    }
}