//
//  Property.swift
//  PropFinder
//
//  Created by Quynh Tran on 28/03/2016.
//  Copyright © 2016 Quynh. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Property : NSManagedObject {
    
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
    
    @NSManaged var auction_date : String?
    @NSManaged var bathroom_number : NSNumber?
    @NSManaged var bedroom_number : NSNumber?
    @NSManaged var car_spaces : NSNumber?
    @NSManaged var commission : String?
    @NSManaged var construction_year : String?
    @NSManaged var datasource_name : String?
    @NSManaged var floor : NSNumber?
    @NSManaged var guid : String?
    @NSManaged var img_url : String?
    @NSManaged var keywords : String?
    @NSManaged var latitude : NSNumber?
    @NSManaged var lister_name : String?
    @NSManaged var lister_url : String?
    @NSManaged var listing_type : String?
    @NSManaged var location_accuracy : String?
    @NSManaged var longitude : NSNumber?
    @NSManaged var price : NSNumber?
    @NSManaged var price_currency : String?
    @NSManaged var price_formatted : String?
    @NSManaged var price_type : String?
    @NSManaged var property_type : String?
    @NSManaged var summary : String?
    @NSManaged var title : String?
    @NSManaged var updated_in_days : String?
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
    }
    
    init( dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Property", inManagedObjectContext: context)!
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        auction_date = dictionary[Keys.AuctionDate] as? String
        keywords = dictionary[Keys.Keywords] as? String

        bathroom_number = dictionary[Keys.BathroomNumber] as? NSNumber
        
        bedroom_number = dictionary[Keys.BedroomNumber] as? NSNumber
        car_spaces = dictionary[Keys.CarSpaces] as? NSNumber
        commission = dictionary[Keys.Commission] as? String
        construction_year = dictionary[Keys.ConstructionYear] as? String
        datasource_name = dictionary[Keys.DatasourceName] as? String
        floor = dictionary[Keys.Floor] as? NSNumber
        guid = dictionary[Keys.Guid] as? String
        img_url = dictionary[Keys.ImgURL] as? String
        
        latitude = dictionary[Keys.Latitude] as? NSNumber
        lister_name = dictionary[Keys.ListerName] as? String
        lister_url = dictionary[Keys.ListerURL] as? String
        listing_type = dictionary[Keys.ListingType] as? String
        location_accuracy = dictionary[Keys.LocationAccuracy] as? String
        longitude = dictionary[Keys.Longitude] as? NSNumber
        price = dictionary[Keys.Price]! as? NSNumber
        price_currency = dictionary[Keys.PriceCurrency] as? String
        price_formatted = dictionary[Keys.PriceFormatted] as? String
        price_type = dictionary[Keys.PriceType] as? String
        property_type = dictionary[Keys.PropertyType] as? String
        summary = dictionary[Keys.Summary] as? String
        title = dictionary[Keys.Title] as? String
        updated_in_days = dictionary[Keys.UpdatedDays] as? String
        
    }
    
    var nestoriaImage: UIImage? {
        
        get {
            
            let imageURL = NSURL(fileURLWithPath: img_url!)
            let fileName = imageURL.lastPathComponent
            
            return NestoriaClient.Caches.imageCache.imageWithIdentifier(fileName)
        }
        
        set {
            
            let imageURL = NSURL(fileURLWithPath: img_url!)
            let fileName = imageURL.lastPathComponent
            
            NestoriaClient.Caches.imageCache.storeImage(newValue, withIdentifier: fileName!)
        }
    }
    
    
}