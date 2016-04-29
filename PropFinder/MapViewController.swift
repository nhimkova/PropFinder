//
//  ViewController.swift
//  PropFinder
//
//  Created by Quynh Tran on 28/03/2016.
//  Copyright © 2016 Quynh. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class imageAnnotation : MKPointAnnotation {
    
    var propertyImage : UIImage?
    var guid : String?
    var saved : Bool?

    
}

class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet var mapView: MKMapView!
    var searchResult = [Property]() //To display only the current search results
    //var searchResultPins = [MKAnnotation]()
    var temporaryContext: NSManagedObjectContext!
    
    var guidList : [String] = []
    
    var searchLocation : String?
    
    var firstLoad : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        // set the fetchedResultsControllerDelegate to self
        fetchedResultsController.delegate = self
        
        // Set the temporary context
        temporaryContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        temporaryContext.persistentStoreCoordinator = sharedContext.persistentStoreCoordinator
        
        //config map when first loaded
        if (firstLoad == true) {
            fetchPersistentProperties()
            let annotations = mapView.annotations
            setMapViewSpan(annotations)
            firstLoad = false
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        if (firstLoad == false) {
            guidList = []
            
            //delete all annotations
            let allAnnotations = mapView.annotations
            mapView.removeAnnotations(allAnnotations)
            
            fetchPersistentProperties()
            
            displayTempProperties() {(done) in }
            
        }
        
    }
    
    
    @IBAction func didPushButton(sender: AnyObject) {
        
        initSearchWithParam("stratford", bedroom: nil, price: nil, pref: nil)
        
    }
    
    func initSearchWithParam(location: String!, bedroom: String?, price: String?, pref: String?) {
        
        //clear temp context
        let fetchPin = NSFetchRequest(entityName: "Property")
        fetchPin.sortDescriptors = [NSSortDescriptor(key: "guid", ascending: true)]
        
        let fetchedPinResultsController = NSFetchedResultsController(fetchRequest: fetchPin,
            managedObjectContext: self.temporaryContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        // Fetch
        do {
            try fetchedPinResultsController.performFetch()
        } catch {}
        
        // Delete objects from temp context
        if (fetchedPinResultsController.fetchedObjects!.count > 0) {
            let objects = fetchedPinResultsController.fetchedObjects! as! [NSManagedObject]
            for object in objects {
                self.temporaryContext.deleteObject(object)
            }
        }
        
        //delete temp pins
        let allAnnotations = mapView.annotations
        var annotationsToDelete : [MKAnnotation] = []
        for annotation in allAnnotations {
            let imageAnn = annotation as? imageAnnotation
            if ((imageAnn) != nil) {
                if (imageAnn?.saved! == false) {
                    annotationsToDelete.append(annotation)
                }
            }
        }
        mapView.removeAnnotations(annotationsToDelete)
        
        let parameters = NestoriaClient.sharedInstance().methodArgumentsWithExtendedParams(location, bedroom: bedroom, price: price, pref: pref)
        
        NestoriaClient.sharedInstance().taskForSearchListing(parameters) { (result, error) in
            
            if (error != nil) {
                
                print("nestoria error")
                
            } else {
                let parsedResult = result as! [String: AnyObject]
                if let propDictionaries = parsedResult["response"]!["listings"] as? [[String: AnyObject]] {
                    
                    self.temporaryContext.performBlockAndWait {
                        
                        self.searchResult = propDictionaries.map() {
                            Property(dictionary: $0, context: self.temporaryContext)
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        self.displayTempProperties() { (done) in
                        
                            //find temp pins
                            let allAnnotations = self.mapView.annotations as! [imageAnnotation]
                            var tempPins : [MKAnnotation] = []
                            for annotation in allAnnotations {
                                if (annotation.saved == false) {
                                    tempPins.append(annotation)
                                }
                            }
                            //zoom map to new pins
                            self.setMapViewSpan(tempPins)
                        }
                    })
                }
            }
        }
    }
    
    
    // %%%%%%%%%%%%%%%        Map View Protocols       %%%%%%%%%%%%%%
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let userAnnotation = annotation as! imageAnnotation
        var reuseId = userAnnotation.guid!
        if (userAnnotation.saved! == true) {
            reuseId += "saved"
        }
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        
        if pinView == nil {
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            if #available(iOS 9.0, *) {
                if (userAnnotation.saved == true) {
                    pinView!.image = UIImage(named:"greenhouse")!
                } else {
                    pinView!.image = UIImage(named:"orangehouse")!
                }
                
            } else {
                // Fallback on earlier versions
            }
            
            let image = userAnnotation.propertyImage
            let button   = UIButton(type: .Custom)
            button.frame = CGRectMake(50, 50, 150, 150)
            button.setImage(image, forState: .Normal)
            
            let widthConstraint = NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 150)
            let heightConstraint = NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 150)
            
            button.contentMode = .ScaleAspectFill
            
            //button.addTarget(self, action: "showDetail:", forControlEvents:UIControlEvents.TouchUpInside)
            
            button.addConstraint(widthConstraint)
            button.addConstraint(heightConstraint)
            
            pinView!.detailCalloutAccessoryView = button
            
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            
            
        }
        else {
            pinView!.annotation = userAnnotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            
            let annotation = view.annotation as? imageAnnotation
            
            let guid = annotation?.guid
            
            //fetch pin entity from temp core data
            let fetchPin = NSFetchRequest(entityName: "Property")
            fetchPin.sortDescriptors = [NSSortDescriptor(key: "guid", ascending: true)]
            let pred = NSPredicate(format: "guid == %@", guid!)
            fetchPin.predicate = pred
            
            let fetchedPinResultsController = NSFetchedResultsController(fetchRequest: fetchPin,
                managedObjectContext: self.temporaryContext,
                sectionNameKeyPath: nil,
                cacheName: nil)
            
            // Fetch
            do {
                try fetchedPinResultsController.performFetch()
            } catch {}
            
            if (fetchedPinResultsController.fetchedObjects!.count > 0) {
                let prop = fetchedPinResultsController.fetchedObjects![0] as? Property
                
                let controller = self.storyboard?.instantiateViewControllerWithIdentifier("PropDetailVC") as! PropDetailViewController
                
                controller.thisProperty = prop
                controller.saved = annotation!.saved!
                
                self.navigationController?.pushViewController(controller, animated: true)
                
            }
            
        }
    }
    
    func displayNewPins(props: [Property]?, saved: Bool) {
        
        if let props = props {
             for currentProp in props {
                
                let newAnotation = imageAnnotation()
                newAnotation.coordinate = currentProp.coordinate!
                newAnotation.title = currentProp.price_formatted
                newAnotation.guid = currentProp.guid
                newAnotation.saved = saved
                let currentImage = currentProp.nestoriaImage
                
                if (currentImage != nil) {
                    newAnotation.propertyImage = currentProp.nestoriaImage
                    //add pin to map
                    self.mapView.addAnnotation(newAnotation)
                    
                } else {
                    //download image
                    NestoriaClient.sharedInstance().taskForDownloadImage(currentProp.img_url!) { (image, error) in
                        
                        if (error != nil) {
                            print("error downloading image")
                        } else {
                            
                            currentProp.nestoriaImage = image
                            newAnotation.propertyImage = image
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                self.mapView.addAnnotation(newAnotation)
                            })
                        }
                        
                    }
                }
                
            }
        }
        
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
    
    func fetchPersistentProperties() {
        
        // Fetch
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        if (fetchedResultsController.fetchedObjects!.count > 0) {
            let props : [Property]? = fetchedResultsController.fetchedObjects as? [Property]
            for prop in props! {
                self.guidList.append(prop.guid!)
            }
            displayNewPins(props, saved: true)
        }
    }
    
    func displayTempProperties(completionHandler: (done: Bool)->Void) {
        if (self.searchResult.count > 0) {
            var propsToDisplay : [Property]? = []
            for prop in self.searchResult {
                let found = self.guidList.indexOf(prop.guid!)
                if (found == nil) {
                    propsToDisplay?.append(prop)
                }
            }
            displayNewPins(propsToDisplay, saved: false)
            completionHandler(done: true)
        }
        
    }
    
    func setMapViewSpan(annotations: [MKAnnotation]) {
        

            var maxLat = -90.0
            var minLat = 90.0
            var maxLon = -180.0
            var minLon = 180.0
        
        if (annotations.count > 0) {
            for annotation in annotations {
                let thisLat = annotation.coordinate.latitude
                let thisLon = annotation.coordinate.longitude
                if (thisLat > maxLat) { maxLat = thisLat}
                else if (thisLat < minLat) { minLat = thisLat }
                if (thisLon > maxLon) { maxLon = thisLon }
                else if (thisLon < minLon) { minLon = thisLon }
            }
        } else {
            // London
            maxLat = 51.5074 + 0.1
            minLat = 51.5074 - 0.1
            maxLon = 0.1278 + 0.1
            minLon = 0.1278 - 0.1
            
        }
        
        //config span
        var span = MKCoordinateSpan()
        var region = MKCoordinateRegion()
        let lat = (minLat + maxLat)/2
        let lon = (minLon + maxLon)/2
        region.center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let latDelta = maxLat - minLat + 0.01
        let lonDelta = maxLon - minLon + 0.01
        span.latitudeDelta = latDelta
        span.longitudeDelta = lonDelta
        region.span = span
        self.mapView.setRegion(region, animated: true)
        
    }

}

