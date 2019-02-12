//
//  FactInfoTableViewCell.swift
//  Vanmino
//
//  Created by Gustavo Ferrufino on 2019-01-18.
//  Copyright © 2019 Gustavo Ferrufino. All rights reserved.
//

import UIKit

/// A cell that displays within a DrawerViewController. Displays
/// a static image, title label and description label but doesn't
/// do much more than that for the sake of this demo.
class FactInfoTableViewCell: UITableViewCell {
    
    /// Static Cell Height
    static let cellHeight: CGFloat = 100.0
    
    @IBOutlet weak var hikeElevation: UILabel!
    @IBOutlet weak var hikeTime: UILabel!
    @IBOutlet weak var hikeDistance: UILabel!
    @IBOutlet weak var hikeDifficulty: UILabel!
    @IBOutlet weak var dogIcon: UIImageView!
    @IBOutlet weak var campingIcon: UIImageView!
   
}
