//
//  MainTrailTableViewCell.swift
//  Vanmino
//
//  Created by Gustavo Ferrufino on 2019-07-19.
//  Copyright © 2019 Gustavo Ferrufino. All rights reserved.
//

import UIKit
import MapboxStatic
import Mapbox
import MapboxDirections
import MapboxCoreNavigation

class MainTrailTableViewCell: UITableViewCell {

  static let cellHeight: CGFloat = 295.0
    
    @IBOutlet weak var trailNameLabel: UILabel!
    @IBOutlet weak var distanceFromUser: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var elevationGainLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var seasonLabel: UILabel!
    @IBOutlet weak var TrailImg: UIImageView!
    @IBOutlet weak var trailCard: UIView!
    var geoJSONOverlay: GeoJSON!
    var hikeRoute: Route?
    var coordinatesOfTrail = [CLLocationCoordinate2D]()
    

    
    func configCell(trail: Hike){
        self.distanceLabel.text = trail.distance! + " km"
        self.trailNameLabel.text = trail.name
        self.elevationGainLabel.text = trail.elevation
        self.timeLabel.text = trail.time
        //self.trailCard.layer.cornerRadius = 10
        self.trailCard.layer.masksToBounds = true
        //self.trailCard.layer.borderWidth = 0.5
       // self.trailCard.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        self.trailCard.layer.cornerRadius = 10
        self.trailCard.layer.shadowOffset = CGSize(width: 0, height: 10)
        self.trailCard.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.trailCard.layer.shadowRadius = 5
        self.trailCard.layer.shadowOpacity = 0.3
        
        self.seasonLabel.text = trail.season
        self.regionLabel.text = trail.region
        self.difficultyLabel.text = trail.difficulty == "Inter." ? "Intermediate": trail.difficulty
        self.difficultyLabel.textColor = getTrailCardBackgroundColor(difficulty: trail.difficulty)
        // # TODO:
        // Default image if no internet
        //CACHE IMAGES!
        // LOAD Cache images
        //self.TrailImg.loadImageUsingCacheWithGeoJSONURLString(urlString: trail.id!, coor: trail.startLocation)
        self.TrailImg.image = UIImage(named: "emptyTrailMap")
    }
    
    func getTrailCardBackgroundColor(difficulty: String?) -> UIColor{
        
        switch difficulty {
        case "Easy":
            return #colorLiteral(red: 0.2813360691, green: 0.5927771926, blue: 0.2168164253, alpha: 1)
        case "Inter.":
            return #colorLiteral(red: 0.2328401208, green: 0.5419160128, blue: 0.8636065125, alpha: 1)
        case "Hard":
            return #colorLiteral(red: 0.768627451, green: 0.1058823529, blue: 0.1450980392, alpha: 1)
        default:
            return #colorLiteral(red: 0.2813360691, green: 0.5927771926, blue: 0.2168164253, alpha: 1)
        }
    }
}

