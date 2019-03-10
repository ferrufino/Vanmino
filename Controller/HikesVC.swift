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
import YNDropDownMenu

let appDelegate = UIApplication.shared.delegate as? AppDelegate


class HikesVC: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView! // Table of Hikes
    let locationManager = CLLocationManager()
    var userLocation: CLLocationCoordinate2D!
    var hikes: [Hike] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        self.readhikesFromFirebase()
        setTableViewServices()
    }
    
    override func viewDidAppear(_ animated: Bool) {
       
    }
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //////////////////////
    // Navigation bar FUNCTIONS
    /////////////////////

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
        let systemVersion = UIDevice.current.systemVersion
        print("iOS version: \(systemVersion)")
        print(modelIdentifier()) //https://www.theiphonewiki.com/wiki/Models
    }
    
    //////////////////////
    // User Location SERVICES
    /////////////////////
    

    func checkLocationServices() {
        //print("CLLocationManager.locationServicesEnabled()\(CLLocationManager.locationServicesEnabled())")
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            
           
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
          notifyUser(title: "Your location is needed.", message: "Features from Camino won't work if we don't have acces to your location. Please enable it at Settings>Camino>Location>While Using the App")
            
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
            break
        case .restricted:
            // Show an alert letting them know what's up
            notifyUser(title: "Your location is needed.", message: "Features from Camino won't work if we don't have acces to your location. Please enable it at Settings>Camino>Location>While Using the App")
            
            break
        case .authorizedAlways:
            break
        }
    }
    
    func notifyUser(title: String, message: String) -> Void{
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //////////////////////
    // TableView SERVICES
    /////////////////////
    
    func setTableViewServices() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = false
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
        
        if self.userLocation != nil {
            guard let trailDescriptionVC = storyboard?.instantiateViewController(withIdentifier: "TrailDescriptionVC") as? HikeMapVC else {return}
            trailDescriptionVC.initData(hike: hikes[indexPath.row], userLocation: self.userLocation)
            
            presentDescription(trailDescriptionVC)
        }else {
            checkLocationServices()
            notifyUser(title: "User location not found", message: "Features from Camino won't work if we don't have access to your location. Please enable it at Settings>Camino>Location>While Using the App")
        }
    }
    
 
    


}


//Firebase
extension HikesVC {
   

    
    func readhikesFromFirebase(){
        
        let trailsReference = Database.database().reference()
        trailsReference.keepSynced(true)
        let itemsRef = trailsReference.child("trails")
        itemsRef.queryOrderedByValue().observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as! [String: AnyObject]
           
            for (nameOfHike,infoOfHike) in value {
                if !(infoOfHike["location"] as! String).isEmpty{// hikes need to have atleast a location
                    //print("location found \(!(infoOfHike["location"] as! String).isEmpty) \(infoOfHike["location"] as! String)")
                    
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
            print("Error \(error.localizedDescription)")
        }
        
    }
    
}

