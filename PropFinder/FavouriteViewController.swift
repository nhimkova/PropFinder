//
//  FavouriteViewController.swift
//  PropFinder
//
//  Created by Quynh Tran on 03/04/2016.
//  Copyright © 2016 Quynh. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class FavTableVewCell : UITableViewCell {

    
    @IBOutlet var propImageView: UIImageView!
    
    @IBOutlet var bedroomNumberLabel: UILabel!
    
    @IBOutlet var bathroomNumberLabel: UILabel!
    
    @IBOutlet var priceLabel: UILabel!
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var innerView: UIView!
    
}

class FavouriteViewController: UIViewController, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("propCornCell") as! FavTableVewCell
        
        let property = fetchedResultsController.objectAtIndexPath(indexPath) as! Property
        
        // This is the new configureCell method
        configureCell(cell, property: property)

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let controller =
        storyboard!.instantiateViewControllerWithIdentifier("PropDetailVC")
            as! PropDetailViewController
        
        let property = fetchedResultsController.objectAtIndexPath(indexPath) as! Property
        
        controller.thisProperty = property
        controller.saved = true
        
        self.navigationController!.pushViewController(controller, animated: true)
 
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        let cell  = tableView.cellForRowAtIndexPath(indexPath) as! FavTableVewCell
        cell.innerView.backgroundColor = UIColor(red: 0/255, green: 62/255, blue: 128/255, alpha: 1)
    }
    
    func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        let cell  = tableView.cellForRowAtIndexPath(indexPath) as! FavTableVewCell
        cell.innerView.backgroundColor = UIColor(red: 0/255, green: 62/255, blue: 128/255, alpha: 1)
    }
    
    func configureCell(cell: FavTableVewCell, property: Property) {
        
        cell.propImageView.image = property.nestoriaImage
        cell.titleLabel.text = property.title
        cell.bedroomNumberLabel.text = property.bedroom_number?.stringValue
        cell.bathroomNumberLabel.text = property.bathroom_number?.stringValue
        cell.priceLabel.text = property.price_formatted
        
        cell.innerView.layer.cornerRadius = 6
        cell.innerView.clipsToBounds = true
        
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

    
    // %%%%%%%%%%%%%%%        NSFetchedResultController methods       %%%%%%%%%%%%%%
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int,
        forChangeType type: NSFetchedResultsChangeType) {
            
            switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
                
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
                
            default:
                return
            }
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            
            switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                
            case .Update:
                break
                
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    
    
}