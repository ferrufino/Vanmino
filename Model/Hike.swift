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
    
    var difficulty: String?
    var distance: String?
    var elevation: String?
    var name: String?
    var season: String?
    var startLocation: String?
    var time: String?
    
    var temperature: String?
    var precipitation: String?
    var weather: String?
    var wind: String?
    var daylight: String?
    
    func requestData(completion: ((_ data: String) -> Void)) {
        // the data was received and parsed to String
        let data = "Data from wherever"
        completion(data)
    }
    
}
