//
//  SearchViewController.swift
//  PropFinder
//
//  Created by Quynh Tran on 03/04/2016.
//  Copyright © 2016 Quynh. All rights reserved.
//

import Foundation
import UIKit

class SearchViewController: UIViewController {
    
    
    @IBOutlet var locationTextField: UITextField!
    
    @IBOutlet var bedroomControl: UISegmentedControl!

    @IBOutlet var priceControl: UISegmentedControl!
    
    @IBOutlet var resultControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    @IBAction func didPushSearch(sender: AnyObject) {
        
        var location : String?
        var bedroom : String?
        var price : String?
        var pref : String?
        
        (location, bedroom, price, pref) = getParams()
        
        
        let VCs = tabBarController?.viewControllers
        let nav = VCs![0] as? UINavigationController
        let mapVC = nav?.viewControllers[0] as? MapViewController
        mapVC?.initSearchWithParam(location, bedroom: bedroom, price: price, pref: pref)
        tabBarController?.selectedIndex = 0
    }
    
    func getParams()->(location: String?, bedroom: String?, price: String?, pref: String?) {
        
        let location = locationTextField?.text
        let bedroomIndex = bedroomControl.selectedSegmentIndex
        var bedroom : String?
        if (bedroomIndex == 0) {
            bedroom = "1"
        }
        else if (bedroomIndex == 1) {
            bedroom = "2"
        }
        else if (bedroomIndex == 2) {
            bedroom = "3"
        }
        else if (bedroomIndex == 3) {
            bedroom = "4"
        }
        else if (bedroomIndex == 4) {
            bedroom = "min"
        }
        
        let priceIndex = priceControl.selectedSegmentIndex
        var price : String?
        if (priceIndex == 0) {
            price = "500000"
        }
        else if (priceIndex == 1) {
            price = "750000"
        }
        else if (priceIndex == 2) {
            price = "1000000"
        }
        else if (priceIndex == 3) {
            price = "1500000"
        }
        else if (priceIndex == 4) {
            price = "max"
        }
        
        
        let prefIndex = resultControl.selectedSegmentIndex
        var pref : String?
        if (prefIndex == 0) {
            pref = "price_lowhigh"
        }
        else if (prefIndex == 1) {
            pref = "price_highlow"
        }
        else if (prefIndex == 2) {
            pref = "newest"
        }
        else if (prefIndex == 3) {
            pref = "relevancy"
        }
        
        return (location, bedroom, price, pref)
        
    }
    
}