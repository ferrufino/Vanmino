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
import FirebaseDatabase

class SavedTrailsViewController: UIViewController, CLLocationManagerDelegate {
  
    
    var savedTrails: [Hike] = []
    var userLocation: CLLocationCoordinate2D!
    var  locationManager = CLLocationManager()
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var uuid = ""
    
    @IBOutlet weak var tableView: UITableView! // Table of Hikes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        setTableViewServices()

        
    }
    

    func initData(userid: String){
        uuid = userid
        readSavedHikesFromFirebase()
    }
    
    
    @IBAction func unwindToContainerVC() {
        dismissDetail()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Location Services
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // locationManager.stopMonitoringSignificantLocationChanges()
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        // print("User Location: \(locValue)")
        self.userLocation = locValue
        
        
    }
    func checkLocationServices(handleComplete:(()->())) {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                locationManager.requestWhenInUseAuthorization()
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
                print("Access")
            }
        } else {
            notifyUser(title: "By the way.. 🙄", message: "Features from Outdoorsy won't work if we don't have access to your location. We don't save your location! \n Please enable it at Settings>Outdoorsy>Location>While Using the App.",imageName: "", extraOption: "",{})
        }
        
        handleComplete()
    }
    
    //Table Services
    func setTableViewServices() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = false
    }
    

}


extension SavedTrailsViewController:  UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedTrails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "savedTrailCell") as? SavedTrailsTableViewCell else {return UITableViewCell()}
        // set the text from the data model
        cell.selectionStyle = .none
        
        let hike = savedTrails[indexPath.row]
        print(hike)
        cell.configCell(trail: hike)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        checkLocationServices { () -> () in
            if self.userLocation != nil {
                guard let trailDescriptionVC = storyboard?.instantiateViewController(withIdentifier: "TrailDescriptionVC") as? HikeMapVC else {return}
                trailDescriptionVC.initData(hike: savedTrails[indexPath.row], userLocation: self.userLocation, userid: self.uuid)
                
                presentDescription(trailDescriptionVC)
                
                
            }
        }
    }
    
    
}

extension SavedTrailsViewController {
    func readSavedHikesFromFirebase(){
        
        let trailsReference = Database.database().reference()
        var trailIds: [String] = []
        trailsReference.keepSynced(true)
        let itemsRefSavedTrails = trailsReference.child("Users").child(self.uuid).child("SavedTrails")
        itemsRefSavedTrails.queryOrderedByValue().observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as! [String: Bool]
            print(value)
            for(trailId, savedStatus) in value{
                if !(trailId).isEmpty {
                    let isSaved = savedStatus
                    if isSaved {
                        trailIds.append(trailId)
                    }
                }
            }
        }){ (error) in
            print("Error \(error.localizedDescription)")
        }
        
        let itemsRef = trailsReference.child("trails")
        itemsRef.queryOrderedByValue().observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as! [String: AnyObject]
            
            for (nameOfHike,infoOfHike) in value {
                if !(infoOfHike["location"] as! String).isEmpty{// hikes need to have atleast a location
                    //print("location found \(!(infoOfHike["location"] as! String).isEmpty) \(infoOfHike["location"] as! String)")
                    if trailIds.contains(infoOfHike["id"] as! String) {
                        let hike = Hike()
                        hike.initVariables(nameOfHike: nameOfHike, hikeDetails: infoOfHike)
                        self.savedTrails.removeAll(where: { hike.id == $0.id })
                        self.savedTrails.append(hike)
                    }
                }
            }
            
            //Order in Desc Hike name by default
            self.savedTrails.sort(by: { $0.name! < $1.name! })
            self.tableView.reloadData()
            
        }){ (error) in
            print("Error \(error.localizedDescription)")
        }
            
            
//            for (nameOfHike,infoOfHike) in value {
//                if !(infoOfHike["location"] as! String).isEmpty{// hikes need to have atleast a location
//                    //print("location found \(!(infoOfHike["location"] as! String).isEmpty) \(infoOfHike["location"] as! String)")
//
//                    let hike = Hike()
//                    hike.initVariables(nameOfHike: nameOfHike, hikeDetails: infoOfHike)
//                    self.hikes.removeAll(where: { hike.id == $0.id })
//                    self.hikes.append(hike)
//
//                }
//            }
//
//            //Order in Desc Hike name by default
//            self.hikes.sort(by: { $0.name! < $1.name! })
//            self.tableView.reloadData()
//
       
        
    }
    
}
