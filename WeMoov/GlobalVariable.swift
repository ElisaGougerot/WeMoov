//
//  GlobalVariable.swift
//  WeMoov
//
//  Created by Victor on 24/12/2019.
//  Copyright © 2019 Elisa Gougerot. All rights reserved.
//

import Foundation
import CoreLocation
struct GlobalVariable {
    static var user = User(id: "", email: "", username: "", isOrganizer: false)
    static var eventClicked = Event(id: "", idOrganizer: "", name: "", content: "", coordinates: CLLocation(), image: "", typeEvent: "", typePlace: "", startDate: Date(), endDate: Date(), price: 0)
    static var imageCache = NSCache<AnyObject, AnyObject>()
}
