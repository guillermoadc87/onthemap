//
//  AddPinViewController.swift
//  OnTheMap
//
//  Created by Guillermo Diaz on 4/4/17.
//  Copyright © 2017 Guillermo Diaz. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class AddPinViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var locationTextView: UITextField!
    @IBOutlet weak var cancelButton: UIButton! 
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    let websiteTextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextView.delegate = self
        websiteTextField.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func findOnTheMapButton(_ sender: UIButton) {
        if locationTextView.text!.isEmpty {
            self.displayAlert(title: "", message: "Please Specify a Location First")
        }
        
        self.showActivityIndicator(activityIndicator)
        
        CLGeocoder().geocodeAddressString(self.locationTextView.text!) { (placemarks, error) in
            self.processResponse(withPlacemarks: placemarks, error: error)
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        
        guard error == nil else {
            displayAlert(title: "", message: "The Address Entered is not Correct")
            return
        }
        
        var location: CLLocation?
        
        if let placemarks = placemarks, placemarks.count > 0 {
            location = placemarks.first?.location
        }
        
        if let location = location {
            let coordinate = location.coordinate
            
            StudentDataModel.latitude = coordinate.latitude
            StudentDataModel.longitude = coordinate.longitude
            
            self.updateUI(withCoordinate: coordinate)
            
            self.hideActivityIndicator(activityIndicator)
            
        } else {
            self.displayAlert(title: "", message: "No Matching Location Found")
        }
    }
    
    // mapView Delegate Methods
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func updateUI(withCoordinate coordinate: CLLocationCoordinate2D) {
        
        let margins = self.view.layoutMarginsGuide
        
        self.cancelButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        
        // Create UIView
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.3507379946, green: 0.4581601559, blue: 1, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        self.view.insertSubview(view, belowSubview: self.cancelButton)
        
        NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
        view.bottomAnchor.constraint(equalTo: margins.centerYAnchor, constant: -80).isActive = true
        
        var annotations = [MKPointAnnotation]()
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "\(locationTextView.text!)"
        annotations.append(annotation)
        
        //Create the mapView and add to the view
        let mapView = MKMapView()
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.addAnnotations(annotations)
        self.view.addSubview(mapView)
        
        // Set the auto-layout constrains
        NSLayoutConstraint(item: mapView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: mapView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: mapView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        mapView.topAnchor.constraint(equalTo: margins.centerYAnchor, constant: -80).isActive = true
        
        // Zoom the map to the Pin location
        let latDelta: CLLocationDegrees = 0.05
        let lonDelta: CLLocationDegrees = 0.05
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(StudentDataModel.latitude, StudentDataModel.longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        mapView.setRegion(region, animated: true)
        
        websiteTextField.translatesAutoresizingMaskIntoConstraints = false
        websiteTextField.placeholder = "Enter a Link to Share Here"
        websiteTextField.textAlignment = .center
        self.view.insertSubview(websiteTextField, aboveSubview: view)
        
        NSLayoutConstraint(item: websiteTextField, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: websiteTextField, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: websiteTextField, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 80).isActive = true
        
        let submitButton = UIButton()
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(UIColor.blue, for: .normal)
        submitButton.backgroundColor = UIColor.white
        submitButton.addTarget(self, action: #selector(submitButtonPressed), for: .touchUpInside)
        self.view.insertSubview(submitButton, aboveSubview: mapView)
        NSLayoutConstraint(item: submitButton, attribute: NSLayoutAttribute.height, relatedBy: .equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 40).isActive = true
        NSLayoutConstraint(item: submitButton, attribute: NSLayoutAttribute.width, relatedBy: .equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 100).isActive = true
        submitButton.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        submitButton.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -80).isActive = true
        
    }
    
    @objc func submitButtonPressed() {
        if websiteTextField.text!.isEmpty {
            self.displayAlert(title: "", message: "You Need to Specify a URL")
        } else {
            StudentDataModel.mapString = locationTextView.text!
            StudentDataModel.website = websiteTextField.text!
            ParsedLogin.sharedInstance().submitLocation() { success, error in
                if success {
                    performUIUpdatesOnMain {
                        self.dismiss(animated:true,completion:nil)
                    }
                } else {
                    performUIUpdatesOnMain {
                        self.displayAlert(title: "", message: "Could not Submit the New Locaction")
                    }
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
