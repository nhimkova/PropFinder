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
    
    struct Keys {
        
        static let AuctionDate = "auction_date"
        static let BathroomNumber = "bathroom_number"
        static let BedroomNumber = "bedroom_number"
        static let CarSpaces = "car_spaces"
        static let Commission = "commission"
        static let ConstructionYear = "construction_year"
        static let DatasourceName = "datasource_name"
        static let Floor = "floor"
        static let Guid = "guid"
        static let ImgURL = "img_url"
        static let Keywords = "keywords"
        static let Latitude = "latitude"
        static let ListerName = "lister_name"
        static let ListerURL = "lister_url"
        static let ListingType = "listing_type"
        static let LocationAccuracy = "location_accuracy"
        static let Longitude = "longitude"
        static let Price = "price"
        static let PriceCurrency = "price_currency"
        static let PriceFormatted = "price_formatted"
        static let PriceType = "price_type"
        static let PropertyType = "property_type"
        static let Summary = "summary"
        static let Title = "title"
        static let UpdatedDays = "updated_in_days"
        
    }
    
}