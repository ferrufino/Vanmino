//
//  TrailCell.swift
//  Vanmino
//
//  Created by Gustavo Ferrufino on 2018-12-02.
//  Copyright © 2018 Gustavo Ferrufino. All rights reserved.
//

import UIKit

class HikeTableViewCell: UITableViewCell {

   
    @IBOutlet weak var trailName: UILabel!
    @IBOutlet weak var trailDistanceLbl: UILabel!
    @IBOutlet weak var trailElevationLbl: UILabel!
    @IBOutlet weak var trailTimeLbl: UILabel!
    @IBOutlet weak var trailCard: UIView!
    @IBOutlet weak var trailSeasonLbl: UILabel!
    @IBOutlet weak var trailRegion: UILabel!
    @IBOutlet weak var distanceFromUser: UILabel!
    @IBOutlet weak var trailDifficulty: UILabel!
    
    func configCell(trail: Hike){
        self.trailDistanceLbl.text = trail.distance! + "Km"
        self.trailName.text = trail.name
        self.trailElevationLbl.text = trail.elevation
        self.trailTimeLbl.text = trail.time
        self.trailCard.layer.cornerRadius = 25
        self.trailCard.layer.masksToBounds = true
        self.trailCard.layer.borderWidth = 3.0
        self.trailCard.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.trailSeasonLbl.text = trail.season
        self.trailRegion.text = trail.region
        self.trailDifficulty.text = trail.difficulty
    }
    
}


