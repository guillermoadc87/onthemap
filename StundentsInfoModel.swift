//
//  StundentsInfoModel.swift
//  OnTheMap
//
//  Created by Guillermo Diaz on 3/26/17.
//  Copyright © 2017 Guillermo Diaz. All rights reserved.
//

import Foundation


struct StudentInfoModel {
    
    // MARK: Properties
    //var objectId: String!
    //var uniqueKey: String!
    var firstName = ""
    var lastName = ""
    var location = ""
    var website = ""
    var latitude = 0.0
    var longitude = 0.0
    
    // MARK: Initializers
    init(dictionary: [String:AnyObject]) {
        //objectId = dictionary[ParseClient.JSONResponseKeys.ObjectId] as? String
        //uniqueKey = dictionary[ParseClient.JSONResponseKeys.UniqueKey] as? String
        if let first = dictionary[ParsedLogin.JSONResponseKeys.FirstName] as? String {
            firstName = first
        }
        if let last = dictionary[ParsedLogin.JSONResponseKeys.LastName] as? String {
            lastName = last
        }
        if let mapString = dictionary[ParsedLogin.JSONResponseKeys.Location] as? String {
            location = mapString
        }
        if let mediaURL = dictionary[ParsedLogin.JSONResponseKeys.Website] as? String {
            website = mediaURL
        }
        if let lat = dictionary[ParsedLogin.JSONResponseKeys.Latitude] as? Double {
            latitude = lat
        }
        if let lon = dictionary[ParsedLogin.JSONResponseKeys.Longitude] as? Double {
            longitude = lon
        }
    }
    
    static func studentInfoFromResults(_ results: [[String:AnyObject]]) -> [StudentInfoModel] {
        
        var studentInfoDictionary = [StudentInfoModel]()
        
        // iterate through array of dictionaries, each StudentInfo is a dictionary
        for result in results {
            studentInfoDictionary.append(StudentInfoModel(dictionary: result))
        }
        
        return studentInfoDictionary
    }
    
}
