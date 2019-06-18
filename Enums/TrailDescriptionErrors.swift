//
//  TrailDescriptionErrors.swift
//  Vanmino
//
//  Created by Gustavo Ferrufino on 2019-05-24.
//  Copyright © 2019 Gustavo Ferrufino. All rights reserved.
//

import UIKit

enum TrailDescriptionError: Error {
    
    // Missing info
    case noUserLocation
    case noStartLocationOfTrail
    case noCoordinatesForTrailFound
    
    //Navigation Error
    case noRouteFound
    // Problem rendering the map
    
}
