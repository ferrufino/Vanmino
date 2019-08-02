//
//  SavedTrailsViewController.swift
//  Vanmino
//
//  Created by Gustavo Ferrufino on 2019-03-28.
//  Copyright © 2019 Gustavo Ferrufino. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseFirestore
import Foundation

class SavedTrailsViewController: UIViewController, CLLocationManagerDelegate {
  
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var db : Firestore!
    @IBOutlet weak var tableView: UITableView! // Table of Hikes
   
    override func viewDidLoad() {
        super.viewDidLoad()   
        setTableViewServices()
        
    }
    override func viewWillAppear(_ animated: Bool) {
    
           
            print("count of saved trails SavedTrails \(User.sharedInstance.savedTrails.count)")
            tableView.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //Table Services
    func setTableViewServices() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = false
        
        //Register cells with identifier
        tableView.register(UINib(nibName: "MainTrailTableViewCell", bundle: nil), forCellReuseIdentifier: "MainTrailTableViewCell")
    }
    

}


extension SavedTrailsViewController:  UITableViewDelegate, UITableViewDataSource{

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if User.sharedInstance.savedTrails.count == 0 {
            tableView.setEmptyMessage("No Hikes Saved yet!")
        } else {
           tableView.restore()
        }
        
        return User.sharedInstance.savedTrails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MainTrailTableViewCell") as? MainTrailTableViewCell else {return UITableViewCell()}
        
        cell.selectionStyle = .none
        if !User.sharedInstance.savedTrails.isEmpty {
            let hike = User.sharedInstance.savedTrails[indexPath.row]
            print(hike)
            cell.configCell(trail: hike)
           // cell.trailCard.backgroundColor = getTrailCardBackgroundColor(difficulty: hike.difficulty)
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
        //UITableView.automaticDimension
    }
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 300
    }
    
    func getTrailCardBackgroundColor(difficulty: String?) -> UIColor{
        
        switch difficulty {
        case "Easy":
            return #colorLiteral(red: 0.2813360691, green: 0.5927771926, blue: 0.2168164253, alpha: 1)
        case "Intermediate":
            return #colorLiteral(red: 0.2328401208, green: 0.5419160128, blue: 0.8636065125, alpha: 1)
        case "Hard":
            return #colorLiteral(red: 0.7679718733, green: 0.1060277745, blue: 0.1434147358, alpha: 1)
        default:
            return #colorLiteral(red: 0.2813360691, green: 0.5927771926, blue: 0.2168164253, alpha: 1)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
                guard let trailDescriptionVC = storyboard?.instantiateViewController(withIdentifier: "TrailDescriptionVC") as? HikeMapVC else {return}
                trailDescriptionVC.initTrailDescriptionData(hike: User.sharedInstance.savedTrails[indexPath.row])
                
                presentDescription(trailDescriptionVC)

    }
    
    
}

extension SavedTrailsViewController {
 
    func readSavedHikesFromFirebase(){
       
        //get trails info of ids present in array as true.
       // let capitalCities = db.collection("trails").whereField("trailId", isEqualTo: "CA")


        
    }

    
}


