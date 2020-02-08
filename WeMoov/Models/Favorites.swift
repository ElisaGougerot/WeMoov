//
//  Favorites.swift
//  WeMoov
//
//  Created by Victor on 07/02/2020.
//  Copyright © 2020 Elisa Gougerot. All rights reserved.
//

import Foundation
class Favorites {
    private var userID: String = ""
    private var favEventsID: [String] = []
    
    func setUserID(id: String) {
        userID = id
    }
    
    func getFavEvents() -> [String] {
        return favEventsID
    }
    
    func addFavEvent(id: String) {
        favEventsID.append(id)
    }
    
    func removeFavEvent(id: String) {
        favEventsID.removeAll { (eventID) in
            return eventID == id
        }
    }
    
    func removeAllFav() {
        favEventsID.removeAll()
    }
    
    func contains(_ id: String) -> Bool {
        return favEventsID.contains(id)
    }
}
