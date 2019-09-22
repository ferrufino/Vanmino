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
import Firebase


class MainTrailTableViewCell: UITableViewCell {

  static let cellHeight: CGFloat = 295.0
  let imageCache = NSCache<NSString, UIImage>()
    
    @IBOutlet weak var trailNameLabel: UILabel!
    @IBOutlet weak var distanceFromUser: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var elevationGainLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var difficultyTitle: UILabel!
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var regionTitle: UILabel!
    @IBOutlet weak var seasonLabel: UILabel!
    @IBOutlet weak var seasonTitle: UILabel!
    @IBOutlet weak var TrailImg: UIImageView!
    @IBOutlet weak var trailCard: UIView!
    var geoJSONOverlay: GeoJSON!
    var hikeRoute: Route?
    var coordinatesOfTrail = [CLLocationCoordinate2D]()
    

    
    func configCell(trail: Hike, closure: @escaping () -> Void){
        self.distanceLabel.text = trail.distance! + " km"
        self.trailNameLabel.text = trail.name
        self.elevationGainLabel.text = trail.elevation! + " m"
        self.timeLabel.text = trail.time
        
        self.trailCard.layer.masksToBounds = true
        self.trailCard.layer.borderWidth = 0.5
        self.trailCard.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        self.trailCard.layer.cornerRadius = 10
        self.trailCard.layer.shadowOffset = CGSize(width: 0, height: 10)
        self.trailCard.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.trailCard.layer.shadowRadius = 5
        self.trailCard.layer.shadowOpacity = 0.3
        
        if trail.season == nil {
            seasonTitle.isHidden = true
            seasonLabel.isHidden = true
        } else {
            self.seasonLabel.text = trail.season
        }
        if trail.region == nil {
            regionTitle.isHidden = true
            regionLabel.isHidden = true
        } else {
            self.regionLabel.text = trail.region
        }
        
        if trail.difficulty == nil {
            difficultyTitle.isHidden = true
            difficultyLabel.isHidden = true
        }else {
            self.difficultyLabel.text = trail.difficulty == "Inter." ? "Intermediate": trail.difficulty
            self.difficultyLabel.textColor = getTrailCardBackgroundColor(difficulty: trail.difficulty)
        }
       
        if trail.img == nil {
            // LOAD Cache images
            if trail.imgURL == "" {
                self.TrailImg.image = UIImage(named: "emptyTrailMap")
            } else{
              
                    self.TrailImg.image = self.getStaticImage(imgURL: trail.imgURL!)
            
              
                }
           
        }else {
             self.TrailImg.image = trail.img
        }
            closure()
        
    }
    
    func getStaticImage(imgURL: String) -> UIImage {
        if let cachedImage = imageCache.object(forKey: imgURL as NSString) {
           print("Cached image found: \(imgURL)")
           return cachedImage
        }
        
        //download
        let storage = Storage.storage()

        let httpsReference = storage.reference(forURL: imgURL)
        var imageRetrieved = UIImage(named: "loadingTrailMap")!
        DispatchQueue.main.async {
         
            httpsReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print("Error getting image: \(error)")
                    // Uh-oh, an error occurred!
                } else {
               
                    imageRetrieved = UIImage(data: data!)!
                     print("New image assigned: \(imgURL)")
                    //Cache new image
                    self.imageCache.setObject(imageRetrieved, forKey: imgURL as NSString)
                }
            }
    }
        return imageRetrieved
    
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

