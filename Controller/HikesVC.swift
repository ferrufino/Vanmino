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
import OnboardKit


class HikesVC: UIViewController, CLLocationManagerDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView! // Table of Hikes
    var sideMenuOpen = false
    @IBOutlet var sideMenuConstraint: NSLayoutConstraint!
    
    var userLocation: CLLocationCoordinate2D!
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var uuid: String = ""
    var  locationManager = CLLocationManager()
    var hikes: [Hike] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationManager()
        self.readhikesFromFirebase()
        setTableViewServices()
        
       
        
        Auth.auth().signInAnonymously() { (authResult, error) in
            
                let user = authResult!.user
                self.uuid = user.uid
                print("Userid: \(self.uuid)") //TSsob6UFfONjjdXznKXsbnAWMkx2
          
        }
        
      
        //self.hikeDot.isHidden = false
        //self.regionDot.isHidden = true
        //self.distanceDot.isHidden = true
       
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SideBarController,
            segue.identifier == "mainFeedToSideBar" {
            vc.delegate = self
        }
    }
   
    
    @IBAction func sideBarMenuTapped() {
        print("Toggle Menu")
        if sideMenuOpen {
            
            sideMenuConstraint.constant = -240
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }else{
            sideMenuConstraint.constant = 0
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
        sideMenuOpen = !sideMenuOpen
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            print("Not first launch.")
        } else {
           // notifyUser(title: "Welcome to ", message: "Here you can keep track of live trail conditions, save favorite trails and more!", imageName: "intro", extraOption: "", handleComplete:{} )
            print("First launch, setting UserDefault.")
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            
            let page = OnboardPage(title: "Welcome to Outdoorsy 🤯",
                                   imageName: "intro",
                                   description: "Here you can keep track of live conditions of trails, see details, and more! \n You can order the hike list by: Hikes, Region, Distance. \n Press on Saved Hikes to see the ones you've saved.")
            
            let page2 = OnboardPage(title: "Live conditions of Hikes",
                                   imageName: "Onboarding2",
                                   description: "Swip up the drawer! Updated every 4hrs, you'll see the live conditions of the hike and typical info. \n You can also see how far away you are from the Start of the hike, bring a dog or camp!")
            
            let page3 = OnboardPage(title: "Navigate, Save, Recenter",
                                    imageName: "Onboarding3",
                                    description: "Want Directions by Car to start of the hike? Press on Navigate! \n Save your fav hike! \n Moved the map too much? Recenter it!")
            
            let page4 = OnboardPage(title: "Where are you?",
                                    imageName: "Onboarding4",
                                    description: "You can see your location during a Hike 🙃 \n Press on one of the pins if you want to get recommendations of sweet spots during the trail!")
            let onboardingViewController = OnboardViewController(pageItems: [page, page2, page3, page4])
            onboardingViewController.presentFrom(self, animated: true)
            
        }
        
    }
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    //////////////////////
    // Navigation bar FUNCTIONS
    /////////////////////
    @IBAction func infoIconPressed(_ sender: Any) {
        notifyUser(title: "Hey!😁", message: "Stay tune for more trails and improvements on this app 👷🏼‍♂️👷🏼‍♀️ \n If you have feedback please write to: outdoorsyclient@gmail.com", imageName: "", extraOption: "Send email", handleComplete: sendEmail)
    }
    
    func mailComposeController( _ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismissDetail()
    }
    func createMailComposeViewController() -> MFMailComposeViewController {
        let mailComposeViewController = MFMailComposeViewController()
        mailComposeViewController.mailComposeDelegate = self
        mailComposeViewController.setToRecipients(["outdoorsyclient@gmail.com"])
        mailComposeViewController.setSubject("Feedback")
        mailComposeViewController.setMessageBody("Hey mate,", isHTML: false)
        return mailComposeViewController
    }
    
    func sendEmail() -> () {
        let composeVC = createMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            
            print("yey")
            // Present the view controller modally.
            self.present(composeVC, animated: true, completion: nil)
            //UIApplication.shared.keyWindow?.rootViewController?.present(composeVC, animated: true, completion: nil)
            //self.navigationController?.present(composeVC, animated: true, completion: nil)
            return
        }else{
            print("Mail services are not available")
        }
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
           notifyUser(title: "By the way.. 🙄", message: "Features from Outdoorsy won't work if we don't have access to your location. We don't save your location! \n Please enable it at Settings>Outdoorsy>Location>While Using the App.",imageName: "", extraOption: "", handleComplete: {})
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
        cell.configCell(trail: hike)
        let hikeLocation = hike.coordinates?[0].components(separatedBy: ",")
        hikes[indexPath.row].distanceFromUser = setDistanceFromTwoLocations(hikeLocation: hikeLocation!, userLocation: self.userLocation)
        cell.distanceFromUser.text =  hikes[indexPath.row].distanceFromUser
        return cell
    }
    
    func setDistanceFromTwoLocations(hikeLocation: [String], userLocation: CLLocationCoordinate2D) -> String {
        let coordinate₀ = userLocation
        let coordinate₁ = CLLocationCoordinate2D(latitude: Double(hikeLocation[0])!, longitude: Double(hikeLocation[1])!)
        let distanceInKms = Int(coordinate₀.distance(to: coordinate₁)/1000) // result is in kms
        
        
        return distanceInKms > 900 ? "You're too far" : String(distanceInKms) + "km away";
    }
  
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            checkLocationServices { () -> () in
                if sideMenuOpen {
                    sideBarMenuTapped()
                } else if self.userLocation != nil {
                guard let trailDescriptionVC = storyboard?.instantiateViewController(withIdentifier: "TrailDescriptionVC") as? HikeMapVC else {return}
                trailDescriptionVC.initData(hike: hikes[indexPath.row], userLocation: self.userLocation, userid: self.uuid)
                
                presentDescription(trailDescriptionVC)
         
            
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

extension HikesVC: ChildToParentProtocol {
    
    func OrderHikeListBy(Order: String){
        print(Order)
        switch Order {
        case "region":
            regionOrder()
        case "name":
            hikeOrder()
        case "distance":
            distanceOrder()
        case "closest":
            closestOrder()
        default:
            hikeOrder()
            
        }
    }
    
    func closestOrder() {
        self.hikes.sort(by: { $0.distanceFromUser! < $1.distanceFromUser! })
        sideBarMenuTapped()
        self.tableView.reloadData()
        
    }
    
   func hikeOrder() {
    self.hikes.sort(by: { $0.name! < $1.name! })
    sideBarMenuTapped()
    self.tableView.reloadData()
    
    }
    
   func regionOrder() {
    
    self.hikes.sort(by: { $0.region! < $1.region! })
    sideBarMenuTapped()
    self.tableView.reloadData()
    }
    
   func distanceOrder() {
    self.hikes.sort(by: { Float($0.distance!)! < Float($1.distance!)! })
    sideBarMenuTapped()
    self.tableView.reloadData()
    
        //Data from phone to use for comments?
        //let systemVersion = UIDevice.current.systemVersion
        //print("iOS version: \(systemVersion)")
        //print(modelIdentifier()) //https://www.theiphonewiki.com/wiki/Models
    }
}

