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
    
    var temperature: String?
    var humidity: String?
    var barometer: String?
    var weather: String?
    var weatherIcon: String?
    var wind: String?
    var sunrise: String?
    var sunset: String?
    
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
    }
    
}
