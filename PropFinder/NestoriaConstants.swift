//
//  NestoriaConstants.swift
//  PropFinder
//
//  Created by Quynh Tran on 02/04/2016.
//  Copyright © 2016 Quynh. All rights reserved.
//

import Foundation

extension NestoriaClient {
    
    struct Constants {
        
        static let BASE_URL = "http://api.nestoria.co.uk/api"
        static let SEARCH_LISTINGS = "search_listings"
        static let ENCODING = "json"
        static let LISTINGTYPE = "buy"
        static let COUNTRY = "uk"
        static let PRETTY = 1
        
    }
    
    
    struct JSONKeys {
        static let Method = "action"
        static let Country = "country"
        static let Endoding = "encoding"
        static let Listing_Type = "listing_type"
        static let Place_Name = "place_name"
        static let SouthWest = "south_west"
        static let NorthEast = "north_east"
        static let CentrePoint = "centre_point"
        static let PriceMin = "price_min"
        static let PriceMax = "price_max"
        static let BedroomMin = "bedroom_min"
        static let BedroomMax = "bedroom_max"
        static let Sort = "sort"
        static let Pretty = "pretty"
    }
    
    
    struct SortResult {
        
        static let Relevancy = "relevancy"
        static let Bedroom_LowHigh = "bedroom_lowhigh"
        static let Bedroom_HighLow = "bedroom_highlow"
        static let Price_LowHigh = "price_lowhigh"
        static let Price_HighLow = "price_highlow"
        static let Newest = "newest"
        static let Oldest = "oldest"
        static let Random = "random"
        static let Distance = "distance"
        
    }
    
}