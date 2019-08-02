//
//  Hike.swift
//  Vanmino
//
//  Created by Gustavo Ferrufino on 2019-01-12.
//  Copyright © 2019 Gustavo Ferrufino. All rights reserved.
//


import UIKit
import CoreLocation


class Hike {
    
    //Variables
    var id: String?
    var difficulty: String?
    var distance: String?
    var elevation: String?
    var name: String?
    var season: String?
    var time: String?
    var region:String?
    var distanceFromUser: String?
    var dogFriendly: Bool!
    var camping: Bool!
    var kidsFriendly: Bool!
    var isloop: Bool!
    var startLocation: CLLocationCoordinate2D?
    var state: String?
    var type: String?
    
    //Weather Variables
    var temperature: String?
    var humidity: String?
    var barometer: String?
    var weather: String?
    var weatherIcon: String?
    var windSpeed: String?
    var windDirection: String?
    var sunrise: String?
    var sunset: String?
    var visibility: String?
    var tempMin: String?
    var tempMax: String?
    var clouds: String?
    

    
    func initVariables(trailId: String, hikeDetails: AnyObject){
        name = hikeDetails["name"] as? String ?? hikeDetails["trailName"] as? String
        difficulty = hikeDetails["difficulty"] as? String ?? ""
        distance = hikeDetails["distance"] as? String ?? ""
        elevation = hikeDetails["elevation"] as? String ?? ""
        id = trailId
        season = hikeDetails["season"] as? String ?? ""
        region = hikeDetails["locality"] as? String ?? ""
        time = hikeDetails["time"] as? String ?? ""
        dogFriendly = hikeDetails["dog-friendly"] as? Bool ?? false
        kidsFriendly = hikeDetails["kids-friendly"] as? Bool ?? false
        camping = hikeDetails["camping"] as? Bool ?? false
        isloop = hikeDetails["isLoop"] as? Bool ?? false
        startLocation = getCoordinatesFromString(coordinatesString: (hikeDetails["startLocation"] as! String))
        state = hikeDetails["state"] as? String ?? ""
        type = hikeDetails["type"] as? String ?? ""
        distanceFromUser = nil
    }
    
  
    
    func copyData(hike: Hike){
        id = hike.id
        difficulty = hike.difficulty
        distance = hike.distance
        elevation = hike.elevation
        name = hike.name
        season = hike.season
        time = hike.time
        dogFriendly = hike.dogFriendly
        camping = hike.camping
        startLocation = hike.startLocation
        
    }
    
    func getCoordinatesFromString(coordinatesString: String) -> CLLocationCoordinate2D {
        let coodinatesStringArray = coordinatesString.components(separatedBy: ",")
        
        return CLLocationCoordinate2D(latitude: Double(coodinatesStringArray[0])!, longitude: Double(coodinatesStringArray[1])!)
    }
    
    
    
}
