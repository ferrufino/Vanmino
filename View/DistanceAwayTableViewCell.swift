//
//  DistanceAwayTableViewCell.swift
//  Vanmino
//
//  Created by Gustavo Ferrufino on 2019-04-02.
//  Copyright © 2019 Gustavo Ferrufino. All rights reserved.
//

import UIKit

class DistanceAwayTableViewCell: UITableViewCell {
  static let cellHeight: CGFloat = 40.0
    
    @IBOutlet weak var distanceAwayLabel: UILabel!
    @IBOutlet weak var GetDirectionsBtn: UIButton!
    
    func configCell(distanceAway: String, handleComplete: (()->())){
        distanceAwayLabel.text = distanceAway
        
        GetDirectionsBtn.setTitleColor(#colorLiteral(red: 0.134868294, green: 0.3168562651, blue: 0.5150131583, alpha: 1), for: .normal)
        GetDirectionsBtn.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
        GetDirectionsBtn.layer.cornerRadius = 25
        GetDirectionsBtn.layer.shadowOffset = CGSize(width: 0, height: 10)
        GetDirectionsBtn.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        GetDirectionsBtn.layer.shadowRadius = 5
        GetDirectionsBtn.layer.shadowOpacity = 0.3
      //  GetDirectionsBtn.addTarget(self, action: #selector( @objc handleComplete()), for: .touchUpInside)
    }
}
