//
//  NetworkHandler.swift
//  
//
//  Created by Gershy Lev on 6/6/15.
//
//

import Foundation
import FBSDKLoginKit

class NetworkHandler {
    
    let parseAppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    let apiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    
    func loginWithFacebook(completion: (success: Bool, error: NSError?) -> ()) {
        var login = FBSDKLoginManager()
        login.logInWithReadPermissions(nil, handler: { (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
            if let fbAccessToken = FBSDKAccessToken.currentAccessToken() {
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
                        var newError = NSError(domain: "Looks like you need to connect your Facebook account to udacity.", code: 100, userInfo: nil)
                        completion(success: false, error: newError)
                    } else {
                        completion(success: true, error: nil)
                    }
                }
                task.resume()
            } else {
                var newError = NSError(domain: "Something went wrong.  Check your network connection and try again.", code: 101, userInfo: nil)
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
            if parsedResult.valueForKeyPath("account.key") != nil {
                completion(success: true, error: nil)
            }
            if let errorString = parsedResult["error"] as? String {
                var newError = NSError(domain: errorString, code: -1010, userInfo: nil)
                completion(success: false, error: newError)
            }
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
    
    func requestStudentInfo(completion: (students: [Student]) -> ()) {
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
            
            completion(students: students)
        }
        task.resume()
    }

    
    func parsedUdacityJSONData(data: NSData) -> NSDictionary {
        let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
        var parsingError: NSError? = nil
        return NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
    }
}