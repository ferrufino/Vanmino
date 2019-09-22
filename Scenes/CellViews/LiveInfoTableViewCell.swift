//
//  DrawerTableViewCell.swift
//  Vanmino
//
//  Created by Gustavo Ferrufino on 2018-12-22.
//  Copyright © 2018 Gustavo Ferrufino. All rights reserved.
//

import UIKit
import Mapbox
import MapboxDirections
import MapboxCoreNavigation
import MapboxNavigation

/// A cell that displays within a DrawerViewController. Displays
/// a static image, title label and description label but doesn't
/// do much more than that for the sake of this demo.
class LiveInfoTableViewCell: UITableViewCell {
    
    /// Static Cell Height
    static let cellHeight: CGFloat = 100.0
    

    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var weather: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var tempMin: UILabel!
    @IBOutlet weak var tempMax: UILabel!
    @IBOutlet weak var sunrise: UILabel!
    @IBOutlet weak var sunset: UILabel!
    
}

