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

class PropDetailViewController: UIViewController {
    
    
    @IBOutlet var detailMapView: MKMapView!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var propTypeLabel: UILabel!
    @IBOutlet var bedroomLabel: UILabel!
    @IBOutlet var bathroomLabel: UILabel!
    @IBOutlet var parkingLabel: UILabel!
    
    var thisProperty : Property?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        configMap()
        
        priceLabel.text = thisProperty?.price_formatted
        propTypeLabel.text = thisProperty?.property_type
        bedroomLabel.text = thisProperty?.bedroom_number?.stringValue
        bathroomLabel.text = thisProperty?.bathroom_number?.stringValue
        parkingLabel.text = thisProperty?.car_spaces?.stringValue
        
    }
    
    func configMap() {
        //initial view
        
        
    }
    
    @IBAction func didPushMorgageButton(sender: AnyObject) {
        
        
    }
    
}