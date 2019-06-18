//
//  Coordinates.swift
//  Vanmino
//
//  Created by Gustavo Ferrufino on 2019-05-06.
//  Copyright © 2019 Gustavo Ferrufino. All rights reserved.
//

import UIKit

import CoreLocation


class Coordinates {
    
    var trailId: String?
    var startLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    var endLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    var coordinateComments: [[String:String?]] = []
    var coordinatePlaces: [[String:String?]] = []
    var coordinatesForTrail: [String] = []
    
    func setLocation(location: CLLocationCoordinate2D, id: String){
        startLocation = location
        trailId = id
    }
    
}
