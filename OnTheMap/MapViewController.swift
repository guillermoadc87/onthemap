//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Guillermo Diaz on 3/8/17.
//  Copyright © 2017 Guillermo Diaz. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    var appDelegate: AppDelegate!
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            getStudentInfo()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getStudentInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func getStudentInfo(){
        ParsedLogin.sharedInstance().getStudentLocation { (studentInfo, error) in
            if let studentInfo = studentInfo {
                StudentDataModel.studentLocations = studentInfo
                performUIUpdatesOnMain {
                    self.populateMapView()
                }
            }else{
                //print(error)
                self.displayAlert(title: "Invalid Link", message: "Could not get student locations.")
            }
        }
    }
    
    func populateMapView(){
        var annotations = [MKPointAnnotation]()
        //print(StudentDataModel.studentLocations)
        for student in StudentDataModel.studentLocations {
            let lat = CLLocationDegrees(student.latitude)
            let long = CLLocationDegrees(student.longitude)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(student.firstName) \(student.lastName)"
            annotation.subtitle = student.website
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
            
        }
        // When the array is complete, we add the annotations to the map.
        if let allAnnotations = self.mapView.annotations as? [MKAnnotation] {
            self.mapView.removeAnnotations(allAnnotations)
        }
        self.mapView.addAnnotations(annotations)
        print("annotations added to the map view.")
    }
    
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            
            let app = UIApplication.shared
            if let annotation = view.annotation, let urlString = annotation.subtitle {
                if let url = URL(string: urlString!) {
                    if app.canOpenURL(url) {
                        app.open(url, options: [:], completionHandler: nil)
                    }else{
                        //displayAlert(title: "Invalid Link", message: "Selected web link could not be opened.")
                    }
                }else{
                    //displayAlert(title: "Invalid Link", message: "Not a valid web link.")
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
