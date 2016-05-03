//
//  PropDetailViewController.swift
//  PropFinder
//
//  Created by Quynh Tran on 13/04/2016.
//  Copyright © 2016 Quynh. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PropDetailViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var summaryLabel: UITextView!
    @IBOutlet var detailMapView: MKMapView!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var propTypeLabel: UILabel!
    @IBOutlet var bedroomLabel: UILabel!
    @IBOutlet var bathroomLabel: UILabel!
    @IBOutlet var parkingLabel: UILabel!
    @IBOutlet var fullHeartButton: UIButton!
    @IBOutlet var emptyHeartButton: UIButton!
    
    
    var thisProperty : Property?
    var saved : Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailMapView.delegate = self
        
        configMap()
        
        summaryLabel.text = thisProperty?.summary
        priceLabel.text = thisProperty?.price_formatted
        propTypeLabel.text = thisProperty?.property_type
        bedroomLabel.text = thisProperty?.bedroom_number?.stringValue
        bathroomLabel.text = thisProperty?.bathroom_number?.stringValue
        parkingLabel.text = thisProperty?.car_spaces?.stringValue
        
        if (saved == true) {
            setSaved()
        } else {
           setUnsaved()
        }
        
    }
    
    func configMap() {
        //add pin
        let annotation = PropAnnotation()
        annotation.coordinate = (thisProperty?.coordinate!)!
        detailMapView.addAnnotation(annotation)
        
        //config span
        var span = MKCoordinateSpan()
        span.latitudeDelta = 0.01
        span.longitudeDelta = 0.01
        var region = MKCoordinateRegion()
        let lat = annotation.coordinate.latitude
        let lon = annotation.coordinate.longitude
        region.center = CLLocationCoordinate2D(latitude: lat + 0.005, longitude: lon)
        region.span = span
        
        detailMapView.setRegion(region, animated: true)
        
        
    }
    
    @IBAction func didPushUnsave(sender: AnyObject) {
        setUnsaved()
        
        //fetch pin entity from core data
        let fetchPin = NSFetchRequest(entityName: "Property")
        fetchPin.sortDescriptors = [NSSortDescriptor(key: "guid", ascending: true)]
        let pred = NSPredicate(format: "guid == %@", (thisProperty?.guid!)!)
        fetchPin.predicate = pred
        
        let fetchedPinResultsController = NSFetchedResultsController(fetchRequest: fetchPin,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        // Fetch
        do {
            try fetchedPinResultsController.performFetch()
        } catch {}
        
        if (fetchedPinResultsController.fetchedObjects!.count > 0) {
            sharedContext.deleteObject(fetchedPinResultsController.fetchedObjects![0] as! Property)
        }
        CoreDataStackManager.sharedInstance().saveContext()

    }
    
    @IBAction func didPushSave(sender: AnyObject) {
        setSaved()
        
        //persist in core data
        let image = thisProperty?.nestoriaImage
        
        let dict : [String: AnyObject?] = [
            NestoriaClient.Keys.AuctionDate : thisProperty?.auction_date,
            NestoriaClient.Keys.Keywords : thisProperty?.keywords,
            NestoriaClient.Keys.BathroomNumber : thisProperty?.bathroom_number,
            NestoriaClient.Keys.BedroomNumber : thisProperty?.bedroom_number,
            NestoriaClient.Keys.CarSpaces : thisProperty?.car_spaces,
            NestoriaClient.Keys.Commission : thisProperty?.commission,
            NestoriaClient.Keys.ConstructionYear : thisProperty?.construction_year,
            NestoriaClient.Keys.DatasourceName : thisProperty?.datasource_name,
            NestoriaClient.Keys.Floor : thisProperty?.floor,
            NestoriaClient.Keys.Guid : thisProperty?.guid,
            NestoriaClient.Keys.ImgURL : thisProperty?.img_url,
            NestoriaClient.Keys.Latitude : thisProperty?.latitude,
            NestoriaClient.Keys.ListerName : thisProperty?.lister_name,
            NestoriaClient.Keys.ListerURL : thisProperty?.lister_url,
            NestoriaClient.Keys.ListingType : thisProperty?.listing_type,
            NestoriaClient.Keys.LocationAccuracy : thisProperty?.location_accuracy,
            NestoriaClient.Keys.Longitude : thisProperty?.longitude,
            NestoriaClient.Keys.Price : thisProperty?.price,
            NestoriaClient.Keys.PriceCurrency : thisProperty?.price_currency,
            NestoriaClient.Keys.PriceFormatted : thisProperty?.price_formatted,
            NestoriaClient.Keys.PriceType : thisProperty?.price_type,
            NestoriaClient.Keys.PropertyType : thisProperty?.property_type,
            NestoriaClient.Keys.Summary : thisProperty?.summary,
            NestoriaClient.Keys.Title : thisProperty?.title,
            NestoriaClient.Keys.UpdatedDays : thisProperty?.updated_in_days
        ]

        
        self.sharedContext.performBlockAndWait {
            let prop = Property(dictionary: dict, context: self.sharedContext)
            prop.nestoriaImage = image
        }
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    func setSaved() {
        fullHeartButton.hidden = false
        emptyHeartButton.hidden = true
    }
    
    func setUnsaved() {
        fullHeartButton.hidden = true
        emptyHeartButton.hidden = false

    }
    
    // %%%%%%%%%%%%%%%        Core Data variables       %%%%%%%%%%%%%%
    
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Property")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "guid", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        var reuseId = "propertyPin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        
        if pinView == nil {
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            if #available(iOS 9.0, *) {
                pinView!.image = UIImage(named:"pin")!

            } else {
                // Fallback on earlier versions
            }
            
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
}