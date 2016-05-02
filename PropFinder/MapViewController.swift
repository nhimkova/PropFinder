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

class PropAnnotation : MKPointAnnotation {
    
    var propertyImage : UIImage?
    var guid : String?
    var saved : Bool?
    
}

class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet var mapView: MKMapView!
    var searchResult = [Property]() //To display only the current search results

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var temporaryContext: NSManagedObjectContext!
    
    var guidList : [String] = []
    
    var searchLocation : String?
    
    var firstLoad : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        activityIndicator.hidden = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear", style: .Plain, target: self, action: "clearButton")
        
        // set the fetchedResultsControllerDelegate to self
        fetchedResultsController.delegate = self
        
        // Set the temporary context
        temporaryContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        temporaryContext.persistentStoreCoordinator = sharedContext.persistentStoreCoordinator
        
        //config map when first loaded
        if (firstLoad == true) {
            fetchPersistentProperties(true)
            firstLoad = false
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if (firstLoad == false) {
            guidList = []
            
            
            //delete all annotations
            let allAnnotations = mapView.annotations
            mapView.removeAnnotations(allAnnotations)
            
            fetchPersistentProperties(false)
            if (searchResult.count > 0) {
                displayTempProperties() {(done) in }
            }
            
        }
        
    }
    
    func initSearchWithParam(location: String!, longitude: String?, latitude: String?, bedroom: String?, price: String?, pref: String?) {
        
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        
        clearTempObjects { (done) -> Void in
        
            let parameters = NestoriaClient.sharedInstance().methodArgumentsWithExtendedParams(location, latitude: latitude, longitude: longitude, bedroom: bedroom, price: price, pref: pref)
        
            NestoriaClient.sharedInstance().taskForSearchListing(parameters) { (result, error) in
            
                if (error != nil) {
                
                    self.displayAlert("Nestoria Error", message: "Connection failure.")
                
                } else {
                    let parsedResult = result as! [String: AnyObject]
                    if let propDictionaries = parsedResult["response"]!["listings"] as? [[String: AnyObject]] {
                    
                        dispatch_async(dispatch_get_main_queue(), {
                        
                            self.searchResult = propDictionaries.map() {
                            Property(dictionary: $0, context: self.temporaryContext)
                            }
                            
                            if (self.searchResult.count == 0) {
                                self.displayAlert("No results found", message: "Please try another search.")
                            }
        
                            self.displayTempProperties() { (done) in
                                
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.setMapViewSpan(self.searchResult)
                                    self.activityIndicator.stopAnimating()
                                    self.activityIndicator.hidden = true
                                })
                            }
                        })
                        
                    } else {
                        self.displayAlert("Nestoria Error", message: "Cannot parse JSON.")
                    }
                }
            }
        }
    }
    
    func clearButton() {
        
        clearTempObjects() { (done) in }
    }
    func clearTempObjects(completionHandler: (done: Bool)->Void) {
        
        searchResult = []
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
            let propAnn = annotation as? PropAnnotation
            if ((propAnn) != nil) {
                if (propAnn?.saved! == false) {
                    annotationsToDelete.append(annotation)
                }
            }
        }
        print("annotations to delete: \(annotationsToDelete.count)")
        mapView.removeAnnotations(annotationsToDelete)
        
        print("clearTempObjects completion handler invoked")
        completionHandler(done: true)
        
    }
    
    
    // %%%%%%%%%%%%%%%        Map View Protocols       %%%%%%%%%%%%%%
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let userAnnotation = annotation as! PropAnnotation
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
            
            let annotation = view.annotation as? PropAnnotation
            
            let guid = annotation?.guid
            var fetchedObjects : [Property]?
            
            let fetchPin = NSFetchRequest(entityName: "Property")
            fetchPin.sortDescriptors = [NSSortDescriptor(key: "guid", ascending: true)]
            let pred = NSPredicate(format: "guid == %@", guid!)
            fetchPin.predicate = pred
            
            var fetchedPropertyResultsController : NSFetchedResultsController?
            
            if (annotation?.saved == false) {
                
                fetchedPropertyResultsController = NSFetchedResultsController(fetchRequest: fetchPin,
                    managedObjectContext: self.temporaryContext,
                    sectionNameKeyPath: nil,
                    cacheName: nil)
            } else {
                
                fetchedPropertyResultsController = NSFetchedResultsController(fetchRequest: fetchPin,
                    managedObjectContext: self.sharedContext,
                    sectionNameKeyPath: nil,
                    cacheName: nil)
                
            }
            
            do {
                try fetchedPropertyResultsController!.performFetch()
            } catch {}
            
            fetchedObjects = fetchedPropertyResultsController!.fetchedObjects as? [Property]
            
            if (fetchedObjects!.count > 0) {
                let prop = fetchedObjects![0]
                
                let controller = self.storyboard?.instantiateViewControllerWithIdentifier("PropDetailVC") as! PropDetailViewController
                
                controller.thisProperty = prop
                controller.saved = annotation!.saved!
                
                self.navigationController?.pushViewController(controller, animated: true)
                
            }
            
        }
    }
    
    func displayNewPins(props: [Property]?, saved: Bool, completionHandler: (done: Bool)->Void) {
        
        if let props = props {
             let totalProps = props.count
             var count = 0
             for currentProp in props {
                count += 1
                let newAnotation = PropAnnotation()
                newAnotation.coordinate = currentProp.coordinate!
                newAnotation.title = currentProp.price_formatted
                newAnotation.guid = currentProp.guid
                newAnotation.saved = saved
                let currentImage = currentProp.nestoriaImage
                
                if (currentImage != nil) {
                    newAnotation.propertyImage = currentProp.nestoriaImage
                    //add pin to map
                    self.mapView.addAnnotation(newAnotation)
                    if (count == totalProps) {
                        print("displayNewPins completed")
                        completionHandler(done: true)
                    }
                    
                } else {
                    //download image
                    NestoriaClient.sharedInstance().taskForDownloadImage(currentProp.img_url!) { (image, error) in
                        
                        if (error != nil) {
                            newAnotation.propertyImage = UIImage(named: "placeholderHouse")
                            
                        } else {
                            
                            currentProp.nestoriaImage = image
                            newAnotation.propertyImage = image
                            
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            self.mapView.addAnnotation(newAnotation)
                            if (count == totalProps) {
                                print("displayNewPins completion handler invoked")
                                completionHandler(done: true)
                            }
                        }) //end dispatch
                    } //end nestoria client
                } //end else
            } //end property loop
        } //end if let props
        
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
    
    func fetchPersistentProperties(setMapSpan: Bool) {
        
        // Fetch
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        if (fetchedResultsController.fetchedObjects!.count > 0) {
            let props : [Property]? = fetchedResultsController.fetchedObjects as? [Property]
            for prop in props! {
                self.guidList.append(prop.guid!)
            }
            displayNewPins(props, saved: true) { (done) in }
            if (setMapSpan == true) {
                setMapViewSpan(props!)
            }
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
            displayNewPins(propsToDisplay, saved: false) { (done) in
                print("displayTempProperties completion handler invoked")
                completionHandler(done: true)
            }
        } else {
            completionHandler(done: true)
        }
    }
    
    func setMapViewSpan(props: [Property]) {
        
        var maxLat = -90.0
        var minLat = 90.0
        var maxLon = -180.0
        var minLon = 180.0
        
        if (props.count > 0) {
            maxLat = props[0].coordinate!.latitude
            minLat = props[0].coordinate!.latitude
            maxLon = props[0].coordinate!.longitude
            minLon = props[0].coordinate!.longitude

            for prop in props {
                let thisLat = prop.coordinate!.latitude
                let thisLon = prop.coordinate!.longitude
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
    
    func displayAlert(title: String!, message: String!) {
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }

}

