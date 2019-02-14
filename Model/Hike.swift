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
    var coordinates: [String]?
    
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
    
    func initVariables(hike: Trail){
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
    }
    
}
