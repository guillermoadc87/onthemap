//
//  ParsedLogin.swift
//  OnTheMap
//
//  Created by Guillermo Diaz on 3/8/17.
//  Copyright © 2017 Guillermo Diaz. All rights reserved.
//

import Foundation

class ParsedLogin: RequestMethods {
    
    // MARK: Properties
    let parseAppID:String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    let apiKey:String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    
    // MARK: Constants
    struct Constants {
        static let StudentLocationURL = "https://parse.udacity.com/parse/classes/StudentLocation"
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        static let Where = "where"
        static let Limit = "limit"
        static let Skip = "skip"
        static let Order = "order"
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        static let Results = "results"
        static let ObjectId = "objectId"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Location = "mapString"
        static let Website = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
    
    func getStudentLocation(_ completionHandlerForStudentLocation: @escaping (_ result: [StudentInfoModel]?, _ error: NSError?) -> Void) {
        let methodParameters = [
            ParameterKeys.Limit : 100,
            ParameterKeys.Order : "-updatedAt"
            ] as [String : Any]
        /* Make the request */
        let urlString = Constants.StudentLocationURL + escapedParameters(methodParameters as [String:AnyObject])
        
        let headerFields = [
            "X-Parse-Application-Id": parseAppID,
            "X-Parse-REST-API-Key": apiKey
        ]
        
        let _ = taskForGETMethod(urlString:urlString, headerFields:headerFields, client:"parse") { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForStudentLocation(nil, error)
            } else {
                if let results = results?[JSONResponseKeys.Results] as? [[String:AnyObject]] {
                    let studentInfo = StudentInfoModel.studentInfoFromResults(results)
                    completionHandlerForStudentLocation(studentInfo, nil)
                } else {
                    completionHandlerForStudentLocation(nil, NSError(domain: "getStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocation"]))
                }
            }
        }
    }
    
    func haveSetALocation() {
        
        let methodParameters = [
            ParameterKeys.Where : "{\"\(JSONResponseKeys.FirstName)\": \"\(StudentDataModel.firstName)\"}"
            ] as [String : Any]
        
        let urlString = Constants.StudentLocationURL + escapedParameters(methodParameters as [String:AnyObject])
        
        let headerFields = [
            "X-Parse-Application-Id": parseAppID,
            "X-Parse-REST-API-Key": apiKey
        ]
        
        let _ = taskForGETMethod(urlString:urlString, headerFields:headerFields, client:"parse") { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if error != nil {
                return
                //completionHandlerForHaveSetALocation(false, error)
            } else {
                if let results = results?[JSONResponseKeys.Results] as? [[String:AnyObject]] {
                    if results.isEmpty == false {
                        print(results[0])
                        StudentDataModel.objectId = results[0][JSONResponseKeys.ObjectId] as! String
                        print(StudentDataModel.objectId)
                        return//completionHandlerForHaveSetALocation(true, error)
                    }
                    return
                    //completionHandlerForHaveSetALocation(false, error)
                }
                
            }
        }
    }
    
    func updateMyStudantLocation() -> Void {
        let methodParameters = [
            ParameterKeys.Where : "{\"\(JSONResponseKeys.FirstName)\": \"adam\"}"
            ] as [String : Any]
    }
    
    override func escapedParameters(_ parameters: [String:AnyObject]) -> String {
        
        if parameters.isEmpty {
            return ""
        } else {
            var keyValuePairs = [String]()
            
            for (key, value) in parameters {
                
                // make sure that it is a string value
                let stringValue = "\(value)"
                
                // escape it
                let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
                // append it
                keyValuePairs.append(key + "=" + "\(escapedValue!)")
                
            }
            
            return "?\(keyValuePairs.joined(separator: "&"))"
        }
    }
    
    func submitLocation(_ completionHandlerForSubmitLocation: @escaping (_ success: Bool, _ error: NSError?) -> Void) -> Void {
        let urlString = (StudentDataModel.objectId.isEmpty == false) ? ParsedLogin.Constants.StudentLocationURL + "/\(StudentDataModel.objectId)" : ParsedLogin.Constants.StudentLocationURL
        print(urlString)
        
        let jsonBody = "{\"uniqueKey\": \"\(StudentDataModel.accountKey)\", \"firstName\": \"\(StudentDataModel.firstName)\", \"lastName\": \"\(StudentDataModel.lastName)\",\"mapString\": \"\(StudentDataModel.mapString)\", \"mediaURL\": \"\(StudentDataModel.website)\",\"latitude\": \(StudentDataModel.latitude), \"longitude\": \(StudentDataModel.longitude)}"
        print(jsonBody)
        
        let headerFields = [
            "X-Parse-Application-Id": parseAppID,
            "X-Parse-REST-API-Key": apiKey,
            "Content-Type": "application/json"
        ]
        
        let request = (StudentDataModel.objectId.isEmpty == false) ? taskForPUTMethod : taskForPOSTMethod
        let _ = request(urlString, headerFields, jsonBody) { (result, error) in
            if error != nil {
                completionHandlerForSubmitLocation(false, error)
            } else {
                if StudentDataModel.objectId.isEmpty == true {
                    if let objectId = result?[JSONResponseKeys.ObjectId] as? String {
                        StudentDataModel.objectId = objectId
                        print(objectId)
                    }
                }
                print(result)
                completionHandlerForSubmitLocation(true, error)
                
            }
            
        }
    }
    
    // MARK: Shared Instance
    class func sharedInstance() -> ParsedLogin {
        struct Singleton {
            static var sharedInstance = ParsedLogin()
        }
        return Singleton.sharedInstance
    }
    

}
