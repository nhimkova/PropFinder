//
//  SearchViewController.swift
//  PropFinder
//
//  Created by Quynh Tran on 03/04/2016.
//  Copyright © 2016 Quynh. All rights reserved.
//

import Foundation
import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet var locationTextField: UITextField!
    @IBOutlet var bedroomControl: UISegmentedControl!
    @IBOutlet var priceControl: UISegmentedControl!
    @IBOutlet var resultControl: UISegmentedControl!
    @IBOutlet var distanceControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextField.delegate = self
        locationTextField.text = "Current Map Location"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    
    ////////////////////Keyboard methods
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
    }
    
    func keyboardWillHide(notification: NSNotification) {
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }

    @IBAction func didPushSearch(sender: AnyObject) {
        
        var location : String?
        var distance: String?
        var bedroom : String?
        var price : String?
        var pref : String?
        var lon : String?
        var lat : String?
        
        (location, distance, bedroom, price, pref) = getParams()
        
        if (location == "") {
            displayAlert("Error", message: "Please enter location or use current map location.")
        } else {
            
            let VCs = tabBarController?.viewControllers
            let nav = VCs![0] as? UINavigationController
            let mapVC = nav?.viewControllers[0] as? MapViewController

            if (location == "Current Map Location") {
                //get mapview location
                let coordinate = mapVC?.mapView.centerCoordinate
                lon = String((coordinate?.longitude)!)
                lat = String((coordinate?.latitude)!)
                location = nil
            }
            
            mapVC?.initSearchWithParam(location, longitude: lon, latitude: lat, distance: distance, bedroom: bedroom, price: price, pref: pref)
            tabBarController?.selectedIndex = 0
        }
    }
    
    func getParams()->(location: String?, distance: String?, bedroom: String?, price: String?, pref: String?) {
        
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
        
        let distanceIndex = distanceControl.selectedSegmentIndex
        var distance : String?
        if (distanceIndex == 0) {
            distance = "1km"
        }
        else if (distanceIndex == 1) {
            distance = "2km"
        }
        else if (distanceIndex == 2) {
            distance = "5km"
        }
        else if (distanceIndex == 3) {
            distance = "10km"
        }
        
        return (location, distance, bedroom, price, pref)
        
    }
    
    @IBAction func didPushCurrentLocation(sender: AnyObject) {
        locationTextField.text = "Current Map Location"
    }
    
    func displayAlert(title: String!, message: String!) {
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
}