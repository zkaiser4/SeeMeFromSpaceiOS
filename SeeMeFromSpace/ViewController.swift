//
//  ViewController.swift
//  SeeMeFromSpace
//
//  Created by ZKApps on 5/9/20.
//  Copyright © 2020 ZKApps. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController , CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate{
    
    //Class Variables
    @IBOutlet weak var mapView: MKMapView!
    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocation?
    private var annotationCoordinates : CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setting up mapView
        mapView.showsUserLocation = true
        mapView.showsScale = true
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        
        // Check for Location Services
        checkLocationServices()
        
        
        //Setting up Gesture Recognition for adding anotations
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            gestureRecognizer.delegate = self
            mapView.addGestureRecognizer(gestureRecognizer)
        
        
        //Setting navigation view items
        self.navigationItem.leftBarButtonItem = MKUserTrackingBarButtonItem(mapView: mapView)
         self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(infoTapped))

        
    }
    
    
    
    
    //Method to check Location services
    private func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    
    
    
    
    //This method handles adding annotations
    @objc func handleTap(_ gestureReconizer: UILongPressGestureRecognizer){
        let location = gestureReconizer.location(in: mapView)
        let coordinate = mapView.convert(location,toCoordinateFrom: mapView)

        // Add annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            

            if !(annotation is MKPointAnnotation) {
                return nil
            }

            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "SeeMePin")
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "SeeMePin")
                annotationView!.canShowCallout = true
            }
            else {
                annotationView!.annotation = annotation
            }

            annotationView!.image = UIImage(named: "SpaceShuttle")

            return annotationView

        }
  
    
    
    
   
    
    
    //Delegate method for location manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { currentLocation = locations.last }
        if currentLocation == nil {
            // Zoom to user location
            if let userLocation = locations.last {
               mapView.centerToLocation(userLocation)
            }
        }
    }
    
    
    
    
    //The functions help prepare for the segue into the EartImageViewController and InfoViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let vc = segue.destination as? EarthImageViewController
        {
            vc.coordinates = annotationCoordinates
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        annotationCoordinates = view.annotation?.coordinate
        self.performSegue(withIdentifier: "showEarthImageViewController", sender: nil)
        
    }
    
    @objc func infoTapped(){
        print("Info")
        self.performSegue(withIdentifier: "showInfoViewController", sender: nil)
    }
    
    
    
    //These functions assist with enabling the deletion of annotations when the user shakes the device
    
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?){
        if motion == .motionShake {
            print("Shake event detected. Removing annotations")
            mapView.removeAnnotations(self.mapView.annotations)
        }
    }
    
   
    
    
    

}







//Extension for Map View
private extension MKMapView {
    
  func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000){
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}







