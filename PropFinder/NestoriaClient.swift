//
//  NestoriaClient.swift
//  PropFinder
//
//  Created by Quynh Tran on 30/03/2016.
//  Copyright © 2016 Quynh. All rights reserved.
//

import Foundation
import UIKit

class NestoriaClient : NSObject {
    
    var session: NSURLSession
    
    typealias CompletionHander = (result: AnyObject!, error: NSError?) -> Void
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> NestoriaClient {
        
        struct Singleton {
            static var sharedInstance = NestoriaClient()
        }
        
        return Singleton.sharedInstance
    }
    
    func taskForSearchListing(methodArguments: [String : AnyObject], completionHandler : CompletionHander) -> NSURLSessionDataTask {
        
        let urlString = Constants.BASE_URL + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)
        print(url)
        
        let request = NSURLRequest(URL: url!)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                completionHandler(result: nil, error: error)
            } else {
                print("taskForSearchListing completionHandler is invoked.")
                NestoriaClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }
        
        task.resume()
        
        return task
        
    }
    
    func taskForDownloadImage(urlString: String, competionHandler: (image: UIImage?, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let url = NSURL(string: urlString)
        let request = NSURLRequest(URL: url!)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                
                competionHandler(image: nil, error: error)
            } else {
                
                let imageData = NSData(data: data!)
                let image : UIImage = UIImage(data: imageData)!
                print("taskForDownloadImage is invoked")
                competionHandler(image: image, error: nil)
            }
        }
        
        task.resume()
        
        return task
        
    }

    
    func methodArgumentsWithPlaceName(placeName : String) -> [String : AnyObject]{
        
        let methodArguments : [String : AnyObject] = [
        
            JSONKeys.Method : Constants.SEARCH_LISTINGS,
            JSONKeys.Country : Constants.COUNTRY,
            JSONKeys.Endoding : Constants.ENCODING,
            JSONKeys.Pretty : Constants.PRETTY,
            JSONKeys.Listing_Type : Constants.LISTINGTYPE,
            JSONKeys.Place_Name : placeName
        ]
        
        return methodArguments
        
    }
    
    func methodArgumentsWithExtendedParams(placeName : String?, latitude: String?, longitude: String?,bedroom: String?, price: String?, pref: String?) -> [String : AnyObject]{
        
        var methodArguments : [String : AnyObject] = [
            JSONKeys.Method : Constants.SEARCH_LISTINGS,
            JSONKeys.Country : Constants.COUNTRY,
            JSONKeys.Endoding : Constants.ENCODING,
            JSONKeys.Pretty : Constants.PRETTY,
            JSONKeys.Listing_Type : Constants.LISTINGTYPE,
        ]
        
        if let placeName = placeName {
            methodArguments[JSONKeys.Place_Name] = placeName
        }
        
        if let _ = latitude {
            if let _ = longitude {
                let centre_point = latitude! + "," + longitude!
                methodArguments[JSONKeys.CentrePoint] = centre_point
            }
        }
        
        if let bedroom = bedroom {
            methodArguments[JSONKeys.BedroomMin] = bedroom
        }
        
        if let bedroom = bedroom {
            methodArguments[JSONKeys.BedroomMin] = bedroom
        }
        
        if let price = price {
            methodArguments[JSONKeys.PriceMax] = price
        }
        
        if let pref = pref {
            methodArguments[JSONKeys.Sort] = pref
        }
        
        return methodArguments
    }

    
    // Parsing the JSON
    
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: CompletionHander) {
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        } catch {
            parsingError = nil //do something else here
            parsedResult = nil
        }
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            print("parseJSONWithCompletionHandler is invoked.")
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    
    //Construct request
    
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
        
    }
    
    //Image Cache
    
    struct Caches {
        static let imageCache = ImageCache()
    }
    
    
}