//
//  ViewController.swift
//  Vanmino
//
//  Created by Gustavo Ferrufino on 2018-12-02.
//  Copyright © 2018 Gustavo Ferrufino. All rights reserved.
//

import UIKit

import Firebase
import FirebaseFirestore
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
    var user = User()
    var  locationManager = CLLocationManager()
    var hikes: [Hike] = []
    var coordinatesOfTrails: [String: Coordinates] = [:]
    let date = Date().addingTimeInterval(10)
    
    var db : Firestore! //firestore migration
    
    
    lazy var refreshControl: UIRefreshControl = {
        
        let refreshControl = UIRefreshControl()
        
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)
        
        refreshControl.tintColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        showAlertloading()
        
        db = Firestore.firestore()
        self.getTrailFromFirestore()
        setupLocationManager()
        
        setTableViewServices()
        
        
        //saveLocationOfUser() Uncomment for Prod
        tableView.refreshControl = refreshControl
        self.getUserSavedTrailsData()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Show loading as we get data
        if tableView.numberOfRows(inSection: 1) > 0 {
             stopAlertLoading()
        }
  
    }
    
    func showAlertloading(){
        let alert = UIAlertController(title: nil, message: "Getting hikes...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    func stopAlertLoading(){
        dismiss(animated: false, completion: nil)
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
                                   description: "Keep track of live conditions of trails, see details, and more!")
            
            let page2 = OnboardPage(title: "Live conditions of Hikes",
                                    imageName: "Onboarding2",
                                    description: "Swip up the drawer! \n See the live weather conditions of the hike, pet friendly or camping area, and typical info.")
            
            let page3 = OnboardPage(title: "Navigate, Save, Recenter",
                                    imageName: "Onboarding3",
                                    description: "Want Directions by Car to the start of a hike? Press on Navigate! \n Moved the map too much? Recenter it! \n Save your fav hike!")
            
            let page4 = OnboardPage(title: "Where are you?",
                                    imageName: "Onboarding4",
                                    description: "You can see your location during a Hike 🙃 \n \n Press on one of the pins if you want to get recommendations of sweet spots during the trail!")
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
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SideBarController,
            segue.identifier == "mainFeedToSideBar" {
            vc.delegate = self
        }
    }
    
    
    @IBAction func sideBarMenuTapped() {
        //print("Toggle Menu")
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
    //////////////////////
    // Navigation bar FUNCTIONS
    /////////////////////
    @IBAction func infoIconPressed(_ sender: Any) {
        notifyUser(title: "Yoo 😲", message: "Stay tuned for more trails and improvements on this app 👷🏼‍♂️👷🏼‍♀️ \n If you have feedback please write to: outdoorsyclient@gmail.com", imageName: "", extraOption: "Send email", handleComplete: sendEmail)
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
            
            print("Email Sent")
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
            }
        } else {
             notifyUser(title: "By the way.. 🙄", message: "Features from Outdoorsy won't work if we don't have access to your location. \n Please enable it at Settings>Outdoorsy>Location>While Using the App.",imageName: "", extraOption: "", handleComplete: {})
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
        //locationManager.stopMonitoringSignificantLocationChanges()
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
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
    func checkLocationOfUserToSave(){
        
        let timer = Timer(fireAt: date, interval: 86400, target: self, selector: #selector(saveUserData), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
        
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
       
        
        cell.trailCard.backgroundColor = getTrailCardBackgroundColor(difficulty: hike.difficulty)
        cell.configCell(trail: hike)
        
        //Calculate distance from User to Start of trail
        if self.userLocation != nil{
            // print("start location cell: \(coordinate!.startLocation)")
            let hikeLocations = 
                hikes[indexPath.row].distanceFromUser = setDistanceFromTwoLocations(hikeLocation: hike.startLocation!, userLocation: self.userLocation)
            cell.distanceFromUser.text =  hikes[indexPath.row].distanceFromUser
            
        }
        
        
        return cell
    }
    
    func getTrailCardBackgroundColor(difficulty: String?) -> UIColor{
        
        switch difficulty {
        case "Easy":
            return #colorLiteral(red: 0.2813360691, green: 0.5927771926, blue: 0.2168164253, alpha: 1)
        case "Intermediate":
            return #colorLiteral(red: 0.2328401208, green: 0.5419160128, blue: 0.8636065125, alpha: 1)
        case "Expert":
            return #colorLiteral(red: 0.768627451, green: 0.1058823529, blue: 0.1450980392, alpha: 1)
        default:
            return #colorLiteral(red: 0.2813360691, green: 0.5927771926, blue: 0.2168164253, alpha: 1)
        }
    }
    
    func setDistanceFromTwoLocations(hikeLocation: CLLocationCoordinate2D, userLocation: CLLocationCoordinate2D) -> String {
        let coordinate₀ = userLocation
        let coordinate₁ = hikeLocation
        let distanceInKms = Int(coordinate₀.distance(to: coordinate₁)/1000) // result is in kms
        
        return distanceInKms > 900 ? "You're too far" : String(distanceInKms) + "km away";
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        checkLocationServices { () -> () in
            if sideMenuOpen {
                sideBarMenuTapped()
            } else if self.userLocation != nil {
                guard let trailDescriptionVC = storyboard?.instantiateViewController(withIdentifier: "TrailDescriptionVC") as? HikeMapVC else {return}
                trailDescriptionVC.initTrailDescriptionData(hike: hikes[indexPath.row], userLocation: self.userLocation, user: self.user)
                print("saved trails: \(self.user.savedTrails)")
                
                presentDescription(trailDescriptionVC)
                
                
            }
        }
    }
    
    
    
    
    
}


//Firebase
extension HikesVC {
    
    @objc func saveUserData(){
        if self.userLocation != nil {
            let systemVersion = UIDevice.current.systemVersion
            //https://www.theiphonewiki.com/wiki/Models
            let phoneModel = modelIdentifier()
            print("Entered save data from user")
            let location:CLLocationCoordinate2D = self.userLocation
            let longitude :CLLocationDegrees = location.longitude
            let latitude :CLLocationDegrees = location.latitude
            let userLocation = CLLocation(latitude: latitude, longitude: longitude)
            print("coordinates: \(latitude) \(longitude)")
            var locality = "not loaded"
            var sublocality = "not loaded"
            var administrativeArea = "not loaded"
            var country = "not loaded"
            userLocation.geocode{ placemark, error in
                if let error = error as? CLError {
                    print("CLError:", error)
                    return
                } else if let placemark = placemark?.first {
                    // you should always update your UI in the main thread
                    DispatchQueue.main.async {
                        
                        locality = placemark.locality ?? "unknown"
                        sublocality = placemark.subLocality ?? "unknown"
                        administrativeArea = placemark.administrativeArea ?? "unknown"
                        country = placemark.country ?? "unknown"
                        let post = [
                            "locality":  locality,
                            "sublocality": sublocality,
                            "administrativeArea":  administrativeArea,
                            "country": country,
                            "iOSversion": systemVersion,
                            "phoneModel": phoneModel
                        ]
                        
                        print("Locality: \(post)")
                        if(self.user.locality != post["locality"]){
                            self.user.locality = post["locality"]!
                            
                            self.db.collection("users").document(self.user.userId).setData(["userInfo": post], merge: true) { err in
                                if let err = err {
                                    print("Error writing document: \(err)")
                                } else {
                                    print("Document successfully written!")
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func getTrailFromFirestore(){
        self.db.collection("trails").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    //Get coordinate of Start Location
                    let hike = Hike()
                    hike.initVariables(trailId: document.documentID, hikeDetails: document.data() as AnyObject)
                    self.hikes.removeAll(where: { hike.id == $0.id })
                    self.hikes.append(hike)
                    
                }
                
                //Order hikes closes to you
                self.hikes.sort(by: { $0.name! < $1.name! })
                self.tableView.reloadData()
                
            }
        }
        
        
        
    }
    
    func updateUserData( user: User){
        self.user = user
        print(self.user.savedTrails)
    }
    
    func getUserSavedTrailsData(){
        Auth.auth().signInAnonymously() { (authResult, error) in
            
            let user = authResult!.user
            self.user.userId = user.uid
            print("Userid: \(self.user.userId)")
        
            //
            self.db.collection("users").document(self.user.userId).collection("savedTrails").getDocuments()
                {
                    (querySnapshot, err) in
                    
                    if let err = err
                    {
                        print("Documents dont exist: \(err)");
                        //make empty object
                    }
                    else
                    {
                        
                        for document in querySnapshot!.documents {
                            
                            print("Documents \(document.data())");
                            let trail = Hike()
                            trail.initVariables(trailId: document.documentID, hikeDetails: document.data() as AnyObject)
                            self.user.savedTrails.append(trail)
                           
                            //create trails objects
                        }
                        self.user.createSavedTrailStatus()
                        
                    }
            }
            //
            
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
        case "difficulty":
            difficultyOrder()
        default:
            hikeOrder()
            
        }
    }
    
    func closestOrder() {
        self.hikes.sort(by: { $0.distanceFromUser! < $1.distanceFromUser! })
        sideBarMenuTapped()
        self.tableView.reloadData()
        
    }
    
    func difficultyOrder() {
        self.hikes.sort(by: {
            switch ($0.difficulty, $1.difficulty){
            case ("Easy", "Expert"):
                return true //"Easy" < "Expert"
                
            case ("Easy", "Intermediate"):
                return true //"Easy" < "Intermediate"
                
            case ("Intermediate", "Expert"):
                return true ///"Intermediate" < "Expert"
                
            case ("Intermediate", "Easy"):
                return false //"Intermediate" > "Easy"
                
            case ("Easy", "Easy"):
                return $0.distance! < $1.distance!
                
            case ("Intermediate", "Intermediate"):
                return $0.distance! < $1.distance!
                
            case ("Expert", "Expert"):
                return $0.distance! < $1.distance!
                
            case ("Expert", "Easy"):
                return false//"Expert" > "Easy"
                
            case ("Expert", "Intermediate"):
                return false//"Expert" > "Intermediate"
                
            default:
                return $0.distance! < $1.distance!
            }
            
        })
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
    }
}

