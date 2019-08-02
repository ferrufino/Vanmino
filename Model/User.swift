//
//  User.swift
//  Vanmino
//
//  Created by Gustavo Ferrufino on 2019-05-16.
//  Copyright © 2019 Gustavo Ferrufino. All rights reserved.
//


import UIKit
import CoreLocation



class User {
    static let sharedInstance = User()
    var savedTrailsStatus = [String: Bool]()
    var savedTrails: [Hike] = []
    var userId: String = ""
    var locality: String = "undefined"
    var userLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    func createSavedTrailStatus(){
        for trail in savedTrails {
            savedTrailsStatus[trail.id!] = true
        }
    }
}
