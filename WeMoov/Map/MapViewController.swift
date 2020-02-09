//
//  MapViewController.swift
//  WeMoov
//
//  Created by Gougerot Elisa on 25/01/2020.
//  Copyright © 2020 Elisa Gougerot. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    let address = GlobalVariable.eventClicked.address
    var coord_lat = GlobalVariable.eventClicked.coordinates.coordinate.latitude
    var coord_long = GlobalVariable.eventClicked.coordinates.coordinate.longitude
    let locationManager = CLLocationManager()

    @IBOutlet var EventsMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor.black
        
        self.EventsMapView.delegate = self
        
        // Geoloc
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        //print(address)
        if #available(iOS 13.0, *) {
            self.EventsMapView.overrideUserInterfaceStyle = .dark
            
        }
        getCoord(from: self.address) { location in
            self.coord_lat = location!.latitude
            self.coord_long = location!.longitude
        }
    }
    
    
    func getCoord(from address: String, completion: @escaping (_ location: CLLocationCoordinate2D?)-> Void){
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location?.coordinate
            else {
                // handle no location found
                return
            }
            self.coord_lat = location.latitude
            self.coord_long = location.longitude
            
            print("EZ \(self.coord_lat) && \(self.coord_long)")
          /*  let pin = MKPointAnnotation()
            pin.title = GlobalVariable.eventClicked.name
            pin.coordinate = CLLocationCoordinate2D(latitude: self.coord_lat, longitude: self.coord_long)
            self.EventsMapView.addAnnotation(pin)
            self.EventsMapView.showAnnotations([pin], animated: true)
         */
            if GlobalVariable.userCoord.0 != 0 && GlobalVariable.userCoord.1 != 0 {
                self.displayRoutes()
            }
           
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor.white
    }
       

    
    private func displayRoutes() {
        
        let sourceLoc = CLLocationCoordinate2D(latitude: GlobalVariable.userCoord.0, longitude: GlobalVariable.userCoord.1)
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceLoc, addressDictionary: nil)
         let destinationPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: self.coord_lat, longitude: self.coord_long), addressDictionary: nil)
         
         let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
         let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
         
         let sourceAnnotation = MKPointAnnotation()
         sourceAnnotation.title = "User"
         if let location = sourcePlacemark.location {
             sourceAnnotation.coordinate = location.coordinate
         }

         let destinationAnnotation = MKPointAnnotation()
         destinationAnnotation.title = GlobalVariable.eventClicked.name
         
         if let location = destinationPlacemark.location {
             destinationAnnotation.coordinate = location.coordinate
         }
        
         self.EventsMapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
         
         
         let directionRequest = MKDirections.Request()
         directionRequest.source = sourceMapItem
         directionRequest.destination = destinationMapItem
         directionRequest.transportType = .automobile
         
         // Calculate the direction
         let directions = MKDirections(request: directionRequest)
         
         directions.calculate {
             (response, error) -> Void in
             
             guard let response = response else {
                 if let error = error {
                     print("Error: \(error)")
                 }
                 
                 return
             }
             
             let route = response.routes[0]
            self.EventsMapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
             
             let rect = route.polyline.boundingMapRect
             self.EventsMapView.setRegion(MKCoordinateRegion (rect), animated: true)
         }
    }
    
}


extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
       {
           if !(annotation is MKPointAnnotation) {
               return nil
           }
           
           let annotationIdentifier = "AnnotationIdentifier"
           var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
           
           if annotationView == nil {
               annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
               annotationView!.canShowCallout = true
           }
           else {
               annotationView!.annotation = annotation
           }
           
           let pinImage = UIImage(named: "pushpin")
           annotationView!.image = pinImage
        
           if annotation.title == GlobalVariable.eventClicked.name {
                let pinImageUser = UIImage(named: "pushpin")
                annotationView!.image = pinImageUser
           } else {
                let pinImage = UIImage(named: "pinUser")
                annotationView!.image = pinImage
           }
        
          return annotationView
       }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
    
        return renderer
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        GlobalVariable.userCoord = (locValue.latitude, locValue.longitude)
        
        removeSpecificAnnotation("User")
        self.displayRoutes()
    }
    
    func removeSpecificAnnotation(_ titleAnnotation: String) {
        for annotation in self.EventsMapView.annotations {
            if let title = annotation.title, title == titleAnnotation {
                self.EventsMapView.removeAnnotation(annotation)
            }
        }
    }
}
