//
//  Event.swift
//  WeMoov
//
//  Created by Victor on 26/12/2019.
//  Copyright © 2019 Elisa Gougerot. All rights reserved.
//

import Foundation
import CoreLocation

struct Event {
    var idEvent: String
    var idOrganizer: String
    var name: String
    var content: String
    var coordinates: CLLocation
    var image: String
    var typeEvent: String
    var typePlace: String
    var startDate: Date
    var endDate: Date
    var price: String
    var address: String
    var period: String
    var favorite: Bool
}
