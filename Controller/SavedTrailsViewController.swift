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
    var user = User()
    @IBOutlet weak var tableView: UITableView! // Table of Hikes
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.user = HikesVC.user
        print("count of saved trails viewdidload \(self.user.savedTrails.count)")
        
        setTableViewServices()
        
    }
    override func viewWillAppear(_ animated: Bool) {
    
            self.db = Firestore.firestore()
            self.readSavedHikesFromFirebase()
        
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
    }
    

}


extension SavedTrailsViewController:  UITableViewDelegate, UITableViewDataSource{
    //get from hike vc user data and saved trails
    func updateUserData( user: User){
        self.user = user
        print("SavedTrails: ")
        print(self.user.savedTrails)
       print("count of saved trails updateuserdata \(self.user.savedTrails.count)")
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.user.savedTrails.count == 0 {
            tableView.setEmptyMessage("No Hikes Saved yet!")
        } else {
           tableView.restore()
        }
        print("count of saved trails \(self.user.savedTrails.count)")
        print(self.user.savedTrails)
        
        return self.user.savedTrails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "savedTrailCell") as? SavedTrailsTableViewCell else {return UITableViewCell()}
        // set the text from the data model
        cell.selectionStyle = .none
        if !self.user.savedTrails.isEmpty {
            let hike = self.user.savedTrails[indexPath.row]
            print(hike)
            cell.configCell(trail: hike)
            cell.trailCard.backgroundColor = getTrailCardBackgroundColor(difficulty: hike.difficulty)
        }
        print("empty of saved trails \(self.user.savedTrails.isEmpty)")
        
        return cell
    }
    
    func getTrailCardBackgroundColor(difficulty: String?) -> UIColor{
        
        switch difficulty {
        case "Easy":
            return #colorLiteral(red: 0.2813360691, green: 0.5927771926, blue: 0.2168164253, alpha: 1)
        case "Intermediate":
            return #colorLiteral(red: 0.2328401208, green: 0.5419160128, blue: 0.8636065125, alpha: 1)
        case "Expert":
            return #colorLiteral(red: 0.7679718733, green: 0.1060277745, blue: 0.1434147358, alpha: 1)
        default:
            return #colorLiteral(red: 0.2813360691, green: 0.5927771926, blue: 0.2168164253, alpha: 1)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
                guard let trailDescriptionVC = storyboard?.instantiateViewController(withIdentifier: "TrailDescriptionVC") as? HikeMapVC else {return}
                //trailDescriptionVC.initTrailDescriptionData(hike: self.user.savedTrails[indexPath.row], userLocation: self.userLocation, user: self.user)
                
                presentDescription(trailDescriptionVC)
                
                
       
    }
    
    
}

extension SavedTrailsViewController {
 
    func readSavedHikesFromFirebase(){
       
        //get trails info of ids present in array as true.
       // let capitalCities = db.collection("trails").whereField("trailId", isEqualTo: "CA")


        
    }

    
}


