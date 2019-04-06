//
//  Hike.swift
//  Vanmino
//
//  Created by Gustavo Ferrufino on 2019-01-12.
//  Copyright © 2019 Gustavo Ferrufino. All rights reserved.
//

//import Foundation
import UIKit



class Hike {
    
    var id: String?
    var difficulty: String?
    var distance: String?
    var elevation: String?
    var name: String?
    var season: String?
    var startLocation: String?
    var time: String?
    var region:String?
    var coordinates: [String]?
    var coordinateComments: [String?]?
    var distanceFromUser: String?
    
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
    
    var dogFriendly: Bool!
    var camping: Bool!
    
    func initVariables(nameOfHike: String, hikeDetails: AnyObject){
        id = hikeDetails["id"] as? String ?? ""
        difficulty = hikeDetails["difficulty"] as? String ?? ""
        distance = hikeDetails["distance"] as? String ?? ""
        elevation = hikeDetails["elevation"] as? String ?? ""
        name = nameOfHike
        season = hikeDetails["season"] as? String ?? ""
        region = hikeDetails["region"] as? String ?? ""
        startLocation = hikeDetails["location"] as? String ?? ""
        time = hikeDetails["time"] as? String ?? ""
        dogFriendly = hikeDetails["dog-friendly"] as? Bool ?? false
        camping = hikeDetails["camping"] as? Bool ?? false
        coordinates = hikeDetails["coordinates"] as? [String]
        coordinateComments = hikeDetails["coordinateComments"] as? [String?]
    }
    
    func copyData(hike: Hike){
        id = hike.id
        difficulty = hike.difficulty
        distance = hike.distance
        elevation = hike.elevation
        name = hike.name
        season = hike.season
        startLocation = hike.startLocation
        time = hike.time
        dogFriendly = hike.dogFriendly
        camping = hike.camping
        coordinates = hike.coordinates
        coordinateComments = hike.coordinateComments
        
    }
    
}
