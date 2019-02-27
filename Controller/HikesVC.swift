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
    
    @IBOutlet weak var tableView: UITableView! // Table of Hikes
    let locationManager = CLLocationManager()
    var userLocation: CLLocationCoordinate2D!
    var hikes: [Hike] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.readhikesFromFirebase()
        //self.readFromTest() // Proper unit tests should be implemented here..
        setTableViewServices()
        checkLocationServices()
        

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func hikeOrder(_ sender: Any) {
        self.hikes.sort(by: { $0.name! < $1.name! })
        self.tableView.reloadData()
    }
    
    @IBAction func regionOrder(_ sender: Any) {
        self.hikes.sort(by: { $0.region! < $1.region! })
        self.tableView.reloadData()
    }
    
    @IBAction func distanceOrder(_ sender: Any) {
        self.hikes.sort(by: { Float($0.distance!)! < Float($1.distance!)! })
        self.tableView.reloadData()
        
        //Data from phone to use for comments?
        var systemVersion = UIDevice.current.systemVersion
        print("iOS version: \(systemVersion)")
        print(modelIdentifier()) //https://www.theiphonewiki.com/wiki/Models
    }
    
}

extension HikesVC{
    
    //////////////////////
    // User Phone Specs
    /////////////////////
    
    func modelIdentifier() -> String {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] { return simulatorModelIdentifier }
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        self.userLocation = locValue
        //print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    //////////////////////
    // TableView SERVICES
    /////////////////////
    
    func setTableViewServices() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = false
    }
    
    //////////////////////
    // User Location FUNCTIONS
    /////////////////////
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on.
            //Alert user some features won't work without it's location.
            let alertController = UIAlertController(title: "Your location is needed.", message: "Features from Camino won't work if we don't have acces to your location. Please enable it at Settings>Camino>Location>While Using the App", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            break
        case .denied:
            // Show alert instructing them how to turn on permissions
          
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Show an alert letting them know what's up
            
            break
        case .authorizedAlways:
            break
        }
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
           
            for (nameOfHike,infoOfHike) in value {
                if !(infoOfHike["location"] as! String).isEmpty{// hikes need to have atleast a location
                    print("location found \(!(infoOfHike["location"] as! String).isEmpty) \(infoOfHike["location"] as! String)")
                    
                    let hike = Hike()
                    hike.initVariables(nameOfHike: nameOfHike, hikeDetails: infoOfHike)
                    self.hikes.removeAll(where: { hike.id == $0.id })
                    self.hikes.append(hike)
                    
                }
            }
            
            //Order in Desc Hike name by default
            self.hikes.sort(by: { $0.name! < $1.name! })
            self.tableView.reloadData()
            
        }){ (error) in
            print(error.localizedDescription)
        }
        
    }
    
}

