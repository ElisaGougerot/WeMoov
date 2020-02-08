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

    @IBOutlet var EventsMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.EventsMapView.delegate = self
        //print(address)
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
            let pin = MKPointAnnotation()
            pin.title = GlobalVariable.eventClicked.name
            pin.coordinate = CLLocationCoordinate2D(latitude: self.coord_lat, longitude: self.coord_long)
            self.EventsMapView.addAnnotation(pin)
           
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
    
          return annotationView
       }
}
