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
    
}


class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {

    
    @IBOutlet var mapView: MKMapView!
    var properties = [Property]()
    var temporaryContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Fetch
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        // set the fetchedResultsControllerDelegate to self
        fetchedResultsController.delegate = self
        
        fetchProperties()
        
        // Set the temporary context
        temporaryContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        temporaryContext.persistentStoreCoordinator = sharedContext.persistentStoreCoordinator

    }


    
    @IBAction func didPushButton(sender: AnyObject) {
        
        let parameters = NestoriaClient.sharedInstance().methodArgumentsWithPlaceName("greenwich")
        
        NestoriaClient.sharedInstance().taskForSearchListing(parameters) { (result, error) in
            
            if (error != nil) {
                
                print("nestoria error")
                
            } else {
                let parsedResult = result as! [String: AnyObject]
                if let propDictionaries = parsedResult["response"]!["listings"] as? [[String: AnyObject]] {
                    
                    self.temporaryContext.performBlockAndWait {
                    
                        self.properties = propDictionaries.map() {
                            Property(dictionary: $0, context: self.temporaryContext)
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.displayNewPins(self.properties)
                    })
                    
                }
                
                
            }
            
        }
        
    }
    
    
    // %%%%%%%%%%%%%%%        Map View Protocols       %%%%%%%%%%%%%%
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        let userAnnotation = annotation as! imageAnnotation
        
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            if #available(iOS 9.0, *) {
                pinView!.pinTintColor = UIColor.purpleColor()
            } else {
                // Fallback on earlier versions
            }
            
            //config annotationview
            
            let annotationImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
            annotationImageView.image = userAnnotation.propertyImage
            annotationImageView.contentMode = .ScaleAspectFill
            
            let widthConstraint = NSLayoutConstraint(item: annotationImageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 150)
            
            annotationImageView.addConstraint(widthConstraint)
            
            let heightConstraint = NSLayoutConstraint(item: annotationImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 150)
            
            annotationImageView.addConstraint(heightConstraint)
            
            pinView!.detailCalloutAccessoryView = annotationImageView
            
        }
        else {
            pinView!.annotation = userAnnotation
        }
        
        return pinView
    }

    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        
        for annotation in views {
            
            let endFrame = annotation.frame
            annotation.frame = CGRectOffset(endFrame, 0, -500)
            
            UIView.animateWithDuration(1, animations: {
                
                annotation.frame = endFrame
                
            })
            
        }
        
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            //new VC
        }
    }
    
    func displayNewPins(props: [Property]?) {
        
        if let props = props {
             for currentProp in props {
                
                let lat = CLLocationDegrees(currentProp.latitude!) //TODO: handle errors here!
                let long = CLLocationDegrees(currentProp.longitude!)
                
                let newAnotation = imageAnnotation()
                newAnotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                newAnotation.title = currentProp.price_formatted
                newAnotation.guid = currentProp.guid
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
    
    func fetchProperties() {
        
        let props : [Property]? = fetchedResultsController.fetchedObjects as? [Property]
        
        displayNewPins(props)

    }

}

