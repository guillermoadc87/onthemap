//
//  UdacityLogin.swift
//  OnTheMap
//
//  Created by Guillermo Diaz on 1/22/17.
//  Copyright © 2017 Guillermo Diaz. All rights reserved.
//

import Foundation

class UdacityLogin : RequestMethods {
    
    // MARK: Properties
    static var accountKey: String? = nil
    
    // MARK: Constants
    struct Constants {
        static let SessionURL = "https://www.udacity.com/api/session"
        static let UserURL = "https://www.udacity.com/api/users"
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        // Public User Data
        static let User = "user"
        static let firstName = "first_name"
        static let lastName = "last_name"
        
        // Session
        static let Account = "account"
        static let Session = "session"
        static let AccountKey = "key"
        static let Expiration = "expiration"
    }
    
    func getUserID(username: String, password: String, _ completionHandlerForGetUserID: @escaping (_ result: AnyObject?, _ errorString: String?) -> Void) -> Void {
        
        let headerFields = [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
        
        let jsonBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        
        let _ = taskForPOSTMethod(urlString: Constants.SessionURL, headerFields: headerFields, jsonBody: jsonBody) { (results, error) in
            if let error = error {
                print(error.localizedDescription)
                completionHandlerForGetUserID(nil, error.localizedDescription)
            }
            if let account = results?[JSONResponseKeys.Account] as? NSDictionary {
                if let userID = account[JSONResponseKeys.AccountKey] as? String{
                    completionHandlerForGetUserID(userID as AnyObject, nil)
                }
                
            } else {
                print("Could not find \(JSONResponseKeys.AccountKey) in \(results)")
                completionHandlerForGetUserID(nil, "Could not login.")
            }
        }
    }
    
    func getUserData(completionHandlerForGetUserData: @escaping (_ result: Bool, _ errorString: String?) -> Void) -> Void {
        let urlString = Constants.UserURL + "/\(StudentDataModel.accountKey)"
        let headerFields = [String:String]()
        
        let _ = taskForGETMethod(urlString: urlString, headerFields: headerFields, client: "udacity") { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                print(error.localizedDescription)
                completionHandlerForGetUserData(false, "There was an error getting user data.")
            } else {
                if let user = results?[JSONResponseKeys.User] as? NSDictionary {
                    if let userFirstName = user[JSONResponseKeys.firstName] as? String, let userLastName = user[JSONResponseKeys.lastName] as? String {
                        StudentDataModel.firstName = userFirstName
                        StudentDataModel.lastName = userLastName
                        completionHandlerForGetUserData(true, nil)
                    }
                    
                } else {
                    print("Could not find \(JSONResponseKeys.User) in \(results)")
                    completionHandlerForGetUserData(false,"Could not get the user data.")
                }
            }
        }
        
    }
    
    func udacityLogout(_ completionHandlerForLogout: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        let urlString = Constants.SessionURL
        let request = NSMutableURLRequest(url:URL(string:urlString)!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        /* Make the request */
        let _ = taskForDELETEMethod(request as URLRequest) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                print(error.localizedDescription)
                completionHandlerForLogout(false, "There was an error with logout.")
            } else {
                if let session = results?[JSONResponseKeys.Session] as? NSDictionary {
                    if let expiration = session[JSONResponseKeys.Expiration] as? String{
                        print("logged out: \(expiration)")
                        completionHandlerForLogout(true, nil)
                    }
                    
                } else {
                    print("Could not find \(JSONResponseKeys.Session) in \(results)")
                    completionHandlerForLogout(false,"Could not logout.")
                }
            }
        }
    }
    
    // MARK: Shared Instance
    class func sharedInstance() -> UdacityLogin {
        struct Singleton {
            static var sharedInstance = UdacityLogin()
        }
        return Singleton.sharedInstance
    }
}
