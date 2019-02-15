//
//  ViewController.swift
//  Vanmino
//
//  Created by Gustavo Ferrufino on 2018-12-02.
//  Copyright © 2018 Gustavo Ferrufino. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseDatabase
import CoreLocation
import MapKit

let appDelegate = UIApplication.shared.delegate as? AppDelegate


class HikesVC: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    let locationManager = CLLocationManager()
    var userLocation: CLLocationCoordinate2D!
    var hikes: [Hike] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = false
        
        self.readhikesFromFirebase()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        //location
        // Ask for Authorisation from the User.
        //self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // tableView.reloadData()
      //  let root = Database.database().reference()
       // let childRef = Database.database().referen
        
        
    }

    
   
}

extension HikesVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hikes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "trailCell") as? HikeTableViewCell else {return UITableViewCell()}
        
        // set the text from the data model
        cell.selectionStyle = .none
        let hike = hikes[indexPath.row]
        cell.configCell(trail: hike)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("section: \(indexPath.section)")
       // print("row: \(indexPath.row)")
        guard let trailDescriptionVC = storyboard?.instantiateViewController(withIdentifier: "TrailDescriptionVC") as? HikeMapVC else {return}
        trailDescriptionVC.initData(hike: hikes[indexPath.row], userLocation: self.userLocation)
        
        presentDescription(trailDescriptionVC)
    }


}

 //Core Data
extension HikesVC {

    func deleteAllTrailRecords() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Trail")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }
    
}

//Firebase
extension HikesVC {
   

    
    func readhikesFromFirebase(){
        Database.database().isPersistenceEnabled = true
        
        let trailsReference = Database.database().reference()
        trailsReference.keepSynced(true)
        let itemsRef = trailsReference.child("trails")
        itemsRef.queryOrderedByValue().observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as! [String: AnyObject]
            //print(value)
            for (nameOfHike,infoOfHike) in value {
                if !(infoOfHike["location"] as! String).isEmpty{// hikes need to have atleast a location
                    print("location found \(!(infoOfHike["location"] as! String).isEmpty) \(infoOfHike["location"] as! String)")
                    
                    let hike = Hike()
                    hike.initVariables(nameOfHike: nameOfHike, hikeDetails: infoOfHike)
                    self.hikes.append(hike)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }){ (error) in
            print(error.localizedDescription)
        }
        
    }
    
}

//
extension HikesVC{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        self.userLocation = locValue
        //print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
}


