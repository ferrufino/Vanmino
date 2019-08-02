//
//  SideBarController.swift
//  Vanmino
//
//  Created by Gustavo Ferrufino on 2019-04-05.
//  Copyright © 2019 Gustavo Ferrufino. All rights reserved.
//

import UIKit
protocol ChildToParentProtocol:class {
    
    
    func OrderHikeListBy(Order: String)
   
    
}

class SideBarController: UITableViewController {
    @IBOutlet weak var closestHikeDot: UIImageView!
    @IBOutlet weak var hikeNameDot: UIImageView!
    @IBOutlet weak var hikeDistanceDot: UIImageView!
    @IBOutlet weak var hikeDifficultyDot: UIImageView!
    @IBOutlet weak var hikeRegionDot: UIImageView!
    @IBOutlet weak var hikeCount: UILabel!
    
    weak var delegate:ChildToParentProtocol? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        closestHikeDot.isHidden = true
        hikeNameDot.isHidden = false
        hikeDistanceDot.isHidden = true
        hikeDifficultyDot.isHidden = true
        hikeRegionDot.isHidden = true
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        
    }



    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionName: String
        switch section {
        case 0:
            sectionName = NSLocalizedString("Order the list by", comment: "mySectionName")
        case 1:
            sectionName = NSLocalizedString("See other Trails:", comment: "myOtherSectionName")
        // ...
        default:
            sectionName = ""
        }
        return sectionName
    }
    
    @IBAction func ClosesHikeToYouBtn_Pressed(_ sender: Any) {
        delegate?.OrderHikeListBy(Order: "closest")
        closestHikeDot.isHidden = false
        hikeNameDot.isHidden = true
        hikeDistanceDot.isHidden = true
        hikeDifficultyDot.isHidden = true
        hikeRegionDot.isHidden = true
    }
    
    @IBAction func HikeNameBtn_Pressed(_ sender: Any) {
        delegate?.OrderHikeListBy(Order: "name")
        closestHikeDot.isHidden = true
        hikeNameDot.isHidden = false
        hikeDistanceDot.isHidden = true
        hikeDifficultyDot.isHidden = true
        hikeRegionDot.isHidden = true
    }
    @IBAction func HikeDistanceBtn_Pressed(_ sender: Any) {
        delegate?.OrderHikeListBy(Order: "distance")
        closestHikeDot.isHidden = true
        hikeNameDot.isHidden = true
        hikeDistanceDot.isHidden = false
        hikeDifficultyDot.isHidden = true
        hikeRegionDot.isHidden = true
    }
    @IBAction func HikeDifficultyBtn_Pressed(_ sender: Any) {
        delegate?.OrderHikeListBy(Order: "difficulty")
        closestHikeDot.isHidden = true
        hikeNameDot.isHidden = true
        hikeDistanceDot.isHidden = true
        hikeDifficultyDot.isHidden = false
        hikeRegionDot.isHidden = true
    }
    
    @IBAction func HikeRegionBtn_Pressed(_ sender: Any) {
        delegate?.OrderHikeListBy(Order: "region")
        closestHikeDot.isHidden = true
        hikeNameDot.isHidden = true
        hikeDistanceDot.isHidden = true
        hikeDifficultyDot.isHidden = true
        hikeRegionDot.isHidden = false
    }
}
