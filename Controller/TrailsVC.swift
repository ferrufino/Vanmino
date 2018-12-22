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


class TrailsVC: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    let locationManager = CLLocationManager()
    var userLocation: CLLocationCoordinate2D!
    var trails: [Trail] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = false
        
        self.readTrailsFromFirebase()
        //self.deleteAllData("Trail")
         fetchCoreDataObjects()
         tableView.reloadData()
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
    func fetchCoreDataObjects(){
        self.fetch { (complete) in
            if complete {
                if trails.count >= 1 {
                    print("Data read into obj from model")
                } else {
                    print("Data NOT read into obj from model")
                }
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      //  let root = Database.database().reference()
       // let childRef = Database.database().referen
        
        
    }

    
   
}

extension TrailsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "trailCell") as? TrailCell else {return UITableViewCell()}
        
        // set the text from the data model
        //cell.textLabel?.text = self.animals[indexPath.row]
        let trail = trails[indexPath.row]
        cell.configCell(trail: trail)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("section: \(indexPath.section)")
       // print("row: \(indexPath.row)")
        guard let trailDescriptionVC = storyboard?.instantiateViewController(withIdentifier: "TrailDescriptionVC") as? TrailDescriptionVC else {return}
        trailDescriptionVC.initData(trail: trails[indexPath.row], userLocation: self.userLocation)
        presentDescription(trailDescriptionVC)
    }


}

 //Core Data
extension TrailsVC {

    func fetch(completion: (_ complete:Bool) -> ()){
        guard let manageContext = appDelegate?.persistentContainer.viewContext else { return }
        
        let fetchRequest = NSFetchRequest<Trail>(entityName: "Trail")
        
        do{
            trails = try manageContext.fetch(fetchRequest)
            print("Amount of trails: \(trails.count)")
            completion(true)
        } catch{
            debugPrint("Could not fetch: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    func deleteAllData(_ entity:String) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        let fetchRequest = NSFetchRequest<Trail>(entityName: "Trail")
        fetchRequest.includesPropertyValues = false
        
        do{
            let items = try managedContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [NSManagedObject]
            
            for item in items {
                managedContext.delete(item)
            }
            
            print("Model \(entity) successfully deleted")
        } catch {
            debugPrint("Could not delete entry: \(error.localizedDescription)")
        }
        
    }
    
}

//Firebase
extension TrailsVC {
    
    func readTrailsFromFirebase(){
        let trailsReference = Database.database().reference()
        let itemsRef = trailsReference.child("trails")
        itemsRef.observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as! [String: AnyObject]
            
            for (nameOfHike,infoOfHike) in value {
                if !(infoOfHike["location"] as! String).isEmpty{// hikes need to have a location
                    //print("location found \(!(infoOfHike["location"] as! String).isEmpty) \(infoOfHike["location"] as! String)")
                    self.save(nameOfHike: nameOfHike, descriptionOfHike: infoOfHike)
                }
            }
        }){ (error) in
            print(error.localizedDescription)
        }
    }
    
    func save(nameOfHike: String, descriptionOfHike: AnyObject) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        
        let trail = Trail(context: managedContext)
        
        trail.name = nameOfHike
        trail.difficulty = descriptionOfHike["difficulty"] as? String ?? ""
        trail.distance = descriptionOfHike["distance"] as? String ?? ""
        trail.elevation = descriptionOfHike["elevation"] as? String ?? ""
        trail.season = descriptionOfHike["season"] as? String ?? ""
        trail.time = descriptionOfHike["time"] as? String ?? "" 
        trail.startLocation = descriptionOfHike["location"] as? String ?? ""
        
        do{
            try managedContext.save()//persistant storage
           // print("Successfully build data")
            
        } catch {
            debugPrint("Could not save: \(error.localizedDescription)")
            
        }
        
    }

    
}

//
extension TrailsVC{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        self.userLocation = locValue
        //print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
}


