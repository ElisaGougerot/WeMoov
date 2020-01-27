//
//  MapViewController.swift
//  WeMoov
//
//  Created by Gougerot Elisa on 25/01/2020.
//  Copyright © 2020 Elisa Gougerot. All rights reserved.
//

import UIKit
import MapKit

fileprivate class EventAnnotation: NSObject {
    var coordinate: CLLocation {
        return self.event.coordinates
    }
    let event: Event
    
    var title: String? {
        return self.event.name
    }
    
    init(event: Event) {
        self.event = event
        super.init()
    }
}

class MapViewController: UIViewController {

    @IBOutlet var EventsMapView: MKMapView!


    var events: [Event] = [] {
           didSet {
               self.EventsMapView.addAnnotation(self.events.map({EventAnnotation(event: $0)}) as! MKAnnotation)
           }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.EventsMapView.delegate = self


    }

}


extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        return nil
    }

}
