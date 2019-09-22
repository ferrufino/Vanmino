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
    
    
    func appendVariablesFromCoreData(hike: Trail){
        let newHike = Hike()
        newHike.id = hike.trailId ?? ""
        newHike.name = hike.name
        newHike.distance = hike.distance
        newHike.time = hike.time
        newHike.elevation = hike.elevationGain
        newHike.coor.coordinatesForTrail = hike.coordinates ?? []
        newHike.coor.startLocation = getCoordinatesFromString(coordinatesString: hike.coordinates![0])
        newHike.region = hike.region
        newHike.img = UIImage(data: hike.staticImage!)
        newHike.publicTrail = false
        //default empty values
        newHike.dogFriendly = false
        newHike.camping = false
        
        
        savedTrails.append(newHike)
        if let id = hike.trailId {
            savedTrailsStatus[id] = true
        }
    }
    
    //This menthod should be part of a base class
    func getCoordinatesFromString(coordinatesString: String) -> CLLocationCoordinate2D {
        let coodinatesStringArray = coordinatesString.components(separatedBy: ",")
        
        return CLLocationCoordinate2D(latitude: Double(coodinatesStringArray[0])!, longitude: Double(coodinatesStringArray[1])!)
    }
}
