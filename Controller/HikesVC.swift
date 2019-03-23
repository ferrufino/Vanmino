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
import MessageUI



class HikesVC: UIViewController, CLLocationManagerDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView! // Table of Hikes
    var userLocation: CLLocationCoordinate2D!
    let appDelegate = UIApplication.shared.delegate as? AppDelegate

    var  locationManager = CLLocationManager()
    var hikes: [Hike] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationManager()
        self.readhikesFromFirebase()
        setTableViewServices()
        
       
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            print("Not first launch.")
        } else {
            notifyUser(title: "Welcome to Outdoorsy!🤯", message: "This is an app to keep track of live trail conditions.", imageName: "orderHikes", extraOption: "", {})
            print("First launch, setting UserDefault.")
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
        
    }
    
    func notifyUser(title: String, message: String, imageName: String, extraOption: String, _ handlerFunction: @escaping () -> Void) -> Void{
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Close", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        if !imageName.isEmpty {
            let image = UIImage(named: imageName)
            alertController.addImage(image: image!)
        }
        
        if !extraOption.isEmpty {
            let extraAction = UIAlertAction(title: extraOption, style: .default, handler: {
                action in
                handlerFunction()
            })
            alertController.addAction(extraAction)
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //////////////////////
    // Navigation bar FUNCTIONS
    /////////////////////
    @IBAction func infoIconPressed(_ sender: Any) {
        notifyUser(title: "Hey!😁", message: "Stay tune for more improvements on this app 👷🏼‍♂️👷🏼‍♀️ \n If you have feedback please write to: outdoorsyclient@gmail.com", imageName: "", extraOption: "Send email", sendEmail)
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            
            // Configure the fields of the interface.
            composeVC.setToRecipients(["caminoclient@gmail.com"])
            composeVC.setSubject("Feedback")
            composeVC.setMessageBody("Hi Camino!", isHTML: false)
            
            // Present the view controller modally.
            self.present(composeVC, animated: true, completion: nil)
            //UIApplication.shared.keyWindow?.rootViewController?.present(composeVC, animated: true, completion: nil)
            //self.navigationController?.present(composeVC, animated: true, completion: nil)
            return
        }else{
            print("Mail services are not available")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
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
        let systemVersion = UIDevice.current.systemVersion
        print("iOS version: \(systemVersion)")
        print(modelIdentifier()) //https://www.theiphonewiki.com/wiki/Models
    }
    
    //////////////////////
    // User Location SERVICES
    /////////////////////
    

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
    /////////////////////
    
   
    
  
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
        if hike.difficulty == "Challenging" {
            cell.backgroundColor = #colorLiteral(red: 0.9289702773, green: 0.2271019816, blue: 0.2684154212, alpha: 1)
        }else if hike.difficulty == "Intermediate" {
            cell.backgroundColor = #colorLiteral(red: 0.2642174363, green: 0.683486104, blue: 0.9940043092, alpha: 1)
        }
        cell.configCell(trail: hike)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 0 {
            
            (cell as! HikeTableViewCell).backgroundColor = #colorLiteral(red: 0.9289702773, green: 0.2271019816, blue: 0.2684154212, alpha: 1)
           
        }
        else {
            
            (cell as! HikeTableViewCell).backgroundColor = #colorLiteral(red: 0.2642174363, green: 0.683486104, blue: 0.9940043092, alpha: 1)
        }
        
      
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            checkLocationServices { () -> () in
            if self.userLocation != nil {
                guard let trailDescriptionVC = storyboard?.instantiateViewController(withIdentifier: "TrailDescriptionVC") as? HikeMapVC else {return}
                trailDescriptionVC.initData(hike: hikes[indexPath.row], userLocation: self.userLocation)
                
                presentDescription(trailDescriptionVC)
         
            
                } else {
                
                }
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

