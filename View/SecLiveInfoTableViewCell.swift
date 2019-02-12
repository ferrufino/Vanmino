//
//  SecLiveInfoTableViewCell.swift
//  Vanmino
//
//  Created by Gustavo Ferrufino on 2019-02-07.
//  Copyright © 2019 Gustavo Ferrufino. All rights reserved.
//

import UIKit

class SecLiveInfoTableViewCell: UITableViewCell {
    
    static let cellHeight: CGFloat = 100.0
    
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var barometer: UILabel!
    @IBOutlet weak var windDirection: UILabel!
    @IBOutlet weak var windSpeed: UILabel!
    @IBOutlet weak var visibility: UILabel!
    @IBOutlet weak var cloudsPercentage: UILabel!
    
/*
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  */
}
