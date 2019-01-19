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
    
    func configCell(trail: Trail){
        
        self.trailDistanceLbl.text = trail.distance
        self.trailName.text = trail.name
        self.trailElevationLbl.text = trail.elevation
        self.trailTimeLbl.text = trail.time
        self.trailCard.layer.cornerRadius = 5
        self.trailSeasonLbl.text = trail.season
        
    }
    
}


